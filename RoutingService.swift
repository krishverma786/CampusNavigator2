import Foundation
import CoreLocation
import SwiftUI

// MARK: - Route Transport Mode

enum RouteMode: String, CaseIterable, Identifiable {
    case walking = "Walking"
    case buggy = "Buggy Shuttle"
    case accessible = "Accessible (Elevators)"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .walking: return "figure.walk"
        case .buggy: return "car.fill"
        case .accessible: return "figure.roll"
        }
    }
}

// MARK: - Navigation Point

struct CampusNavPoint: Identifiable, Hashable, Equatable {
    let id: String
    let name: String
    let building: String
    let floor: Int
    let roomNumber: String?
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: CampusNavPoint, rhs: CampusNavPoint) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static var currentLocation: CampusNavPoint {
        CampusNavPoint(
            id: "current_gps",
            name: "My Current Location",
            building: "Near Main Plaza",
            floor: 0,
            roomNumber: nil,
            coordinate: CLLocationCoordinate2D(latitude: 30.7672, longitude: 76.5742)
        )
    }
    
    static func fromPlace(_ place: CampusPlace) -> CampusNavPoint {
        CampusNavPoint(
            id: place.id.uuidString,
            name: place.name,
            building: place.building,
            floor: place.floor,
            roomNumber: place.roomNumber,
            coordinate: place.coordinate
        )
    }
    
    static func fromBlock(_ block: CampusBlock) -> CampusNavPoint {
        CampusNavPoint(
            id: block.id,
            name: "\(block.name) Entrance",
            building: block.name,
            floor: 0,
            roomNumber: nil,
            coordinate: block.coordinate
        )
    }
    
    static func fromRoom(_ room: CampusRoom) -> CampusNavPoint {
        let blockCoord = findBlock(named: room.block)?.coordinate ?? CLLocationCoordinate2D(latitude: 30.7681, longitude: 76.5754)
        return CampusNavPoint(
            id: room.id,
            name: room.name,
            building: room.block,
            floor: room.floor,
            roomNumber: room.roomNumber,
            coordinate: blockCoord
        )
    }
}

// MARK: - Route Step

struct RouteStep: Identifiable {
    let id = UUID()
    let stepNumber: Int
    let instruction: String
    let iconName: String
    let distanceMeters: Int
}

// MARK: - Route Information

struct CampusRouteInfo {
    let origin: CampusNavPoint
    let destination: CampusNavPoint
    let mode: RouteMode
    let distanceMeters: Int
    let walkingTimeMinutes: Int
    let caloriesEstimate: Int
    let steps: [RouteStep]
    let coordinates: [CLLocationCoordinate2D]
    
    // Backward-compatible initializer
    init(
        distanceMeters: Int,
        walkingTimeMinutes: Int,
        steps: [RouteStep]
    ) {
        self.origin = .currentLocation
        self.destination = CampusNavPoint(
            id: "default_dest",
            name: "Destination",
            building: "Campus",
            floor: 0,
            roomNumber: nil,
            coordinate: CLLocationCoordinate2D(latitude: 30.7681, longitude: 76.5754)
        )
        self.mode = .walking
        self.distanceMeters = distanceMeters
        self.walkingTimeMinutes = walkingTimeMinutes
        self.caloriesEstimate = Int(Double(walkingTimeMinutes) * 4.2)
        self.steps = steps
        self.coordinates = [origin.coordinate, destination.coordinate]
    }
    
    init(
        origin: CampusNavPoint,
        destination: CampusNavPoint,
        mode: RouteMode,
        distanceMeters: Int,
        walkingTimeMinutes: Int,
        caloriesEstimate: Int,
        steps: [RouteStep],
        coordinates: [CLLocationCoordinate2D]
    ) {
        self.origin = origin
        self.destination = destination
        self.mode = mode
        self.distanceMeters = distanceMeters
        self.walkingTimeMinutes = walkingTimeMinutes
        self.caloriesEstimate = caloriesEstimate
        self.steps = steps
        self.coordinates = coordinates
    }
}

// MARK: - Routing Service

final class RoutingService {
    
    static let shared = RoutingService()
    
    private init() {}
    
    // MARK: - Primary Point-to-Point Route Generator
    
    func generateRoute(
        from origin: CampusNavPoint,
        to destination: CampusNavPoint,
        mode: RouteMode = .walking
    ) -> CampusRouteInfo {
        
        let startLoc = CLLocation(latitude: origin.coordinate.latitude, longitude: origin.coordinate.longitude)
        let endLoc = CLLocation(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
        let geoDistance = startLoc.distance(from: endLoc)
        
        // Base campus outdoor walking distance (multiplying by 1.25 for campus walkways)
        var outdoorMeters = Int(max(40, geoDistance * 1.25))
        if origin.id == destination.id {
            outdoorMeters = 0
        }
        
        let floorDiff = abs(destination.floor - origin.floor)
        let indoorMeters = 40 + (floorDiff * 35)
        let totalDistance = outdoorMeters + (origin.building != destination.building ? indoorMeters : (floorDiff * 30 + 25))
        
        // Speed calculation based on mode
        let speedMetersPerMinute: Double
        switch mode {
        case .walking:
            speedMetersPerMinute = 75.0
        case .buggy:
            speedMetersPerMinute = 200.0
        case .accessible:
            speedMetersPerMinute = 60.0
        }
        
        let minutes = max(1, Int(ceil(Double(totalDistance) / speedMetersPerMinute)))
        let calories = max(3, Int(Double(minutes) * (mode == .buggy ? 0.8 : 4.5)))
        
        var steps: [RouteStep] = []
        var stepCount = 1
        
        // Step 1: Departure
        if origin.building == destination.building {
            // Same building navigation
            steps.append(
                RouteStep(
                    stepNumber: stepCount,
                    instruction: origin.roomNumber != nil
                        ? "Depart from \(origin.roomNumber!) in \(origin.building)."
                        : "Start at \(origin.name) in \(origin.building).",
                    iconName: "figure.walk",
                    distanceMeters: 15
                )
            )
            stepCount += 1
            
            if floorDiff > 0 {
                let transition = mode == .accessible
                    ? "Take the accessible elevator from Floor \(origin.floor) to Floor \(destination.floor)."
                    : "Take the central stairs or elevator to Floor \(destination.floor)."
                let icon = mode == .accessible ? "figure.roll" : (destination.floor > origin.floor ? "arrow.up.square.fill" : "stairs")
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: transition,
                        iconName: icon,
                        distanceMeters: floorDiff * 20
                    )
                )
                stepCount += 1
            }
            
            steps.append(
                RouteStep(
                    stepNumber: stepCount,
                    instruction: "Walk along the corridor. \(destination.name) will be on your right.",
                    iconName: "mappin.circle.fill",
                    distanceMeters: 25
                )
            )
        } else {
            // Cross-building / Outdoor navigation
            if mode == .buggy {
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: "Board campus buggy at \(origin.building) Buggy Station.",
                        iconName: "car.fill",
                        distanceMeters: 30
                    )
                )
                stepCount += 1
                
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: "Ride along the Main Campus Ring Road towards \(destination.building).",
                        iconName: "arrow.triangle.turn.up.right.diamond.fill",
                        distanceMeters: outdoorMeters
                    )
                )
                stepCount += 1
                
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: "Alight at \(destination.building) Drop-off Stand.",
                        iconName: "figure.walk",
                        distanceMeters: 20
                    )
                )
                stepCount += 1
            } else {
                // Walking / Accessible
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: "Head towards the main exit of \(origin.building).",
                        iconName: "door.left.hand.open",
                        distanceMeters: 35
                    )
                )
                stepCount += 1
                
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: "Follow the paved central promenade toward \(destination.building).",
                        iconName: mode == .accessible ? "figure.roll" : "figure.walk",
                        distanceMeters: outdoorMeters
                    )
                )
                stepCount += 1
                
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: "Enter \(destination.building) via the \(mode == .accessible ? "wheelchair ramp and " : "")main glass entrance.",
                        iconName: "door.right.hand.open",
                        distanceMeters: 20
                    )
                )
                stepCount += 1
            }
            
            // Floor transition in destination building
            if destination.floor == 0 {
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: "Proceed straight along the Ground Floor foyer.",
                        iconName: "arrow.up.and.down.and.arrow.left.and.right",
                        distanceMeters: 25
                    )
                )
                stepCount += 1
            } else {
                let trans = mode == .accessible
                    ? "Use the main lift lobby to go to Floor \(destination.floor)."
                    : "Take the central stairs or elevator to Floor \(destination.floor)."
                steps.append(
                    RouteStep(
                        stepNumber: stepCount,
                        instruction: trans,
                        iconName: mode == .accessible ? "figure.roll" : "stairs",
                        distanceMeters: destination.floor * 20
                    )
                )
                stepCount += 1
            }
            
            // Arrival
            let destRoomStr = destination.roomNumber != nil ? " (\(destination.roomNumber!))" : ""
            steps.append(
                RouteStep(
                    stepNumber: stepCount,
                    instruction: "Turn left into the corridor. \(destination.name)\(destRoomStr) is directly ahead.",
                    iconName: "mappin.circle.fill",
                    distanceMeters: 20
                )
            )
        }
        
        // Generate realistic intermediate coordinates for map polyline
        let waypoints = generateWaypoints(from: origin.coordinate, to: destination.coordinate)
        
        return CampusRouteInfo(
            origin: origin,
            destination: destination,
            mode: mode,
            distanceMeters: totalDistance,
            walkingTimeMinutes: minutes,
            caloriesEstimate: calories,
            steps: steps,
            coordinates: waypoints
        )
    }
    
    // MARK: - Backward-Compatible Single Destination Method
    
    func generateRoute(to destination: CampusPlace) -> CampusRouteInfo {
        let origin = CampusNavPoint.currentLocation
        let destPoint = CampusNavPoint.fromPlace(destination)
        return generateRoute(from: origin, to: destPoint, mode: .walking)
    }
    
    // MARK: - Waypoints Generator
    
    private func generateWaypoints(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> [CLLocationCoordinate2D] {
        
        var points: [CLLocationCoordinate2D] = [start]
        
        // Add realistic intermediate curve on campus
        let midLat = (start.latitude + end.latitude) / 2.0
        let midLon = (start.longitude + end.longitude) / 2.0
        
        // Slight offset to mimic actual campus roads/walkways
        let curveLat = midLat + (end.longitude - start.longitude) * 0.12
        let curveLon = midLon - (end.latitude - start.latitude) * 0.12
        
        points.append(CLLocationCoordinate2D(latitude: curveLat, longitude: curveLon))
        points.append(end)
        
        return points
    }
}
