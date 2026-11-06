import Foundation
import CoreLocation
import SwiftUI

// MARK: - Buggy Tier / Service Type

enum BuggyTier: String, CaseIterable, Codable, Identifiable {
    case standard = "Campus Shuttle"
    case express = "Express Buggy"
    case accessible = "Accessible Buggy"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .standard: return "car.fill"
        case .express: return "bolt.car.fill"
        case .accessible: return "figure.roll"
        }
    }
    
    var subtitle: String {
        switch self {
        case .standard: return "Eco-friendly 6-seater • Regular stops"
        case .express: return "Direct non-stop • Priority dispatch"
        case .accessible: return "Equipped with wheelchair access ramp"
        }
    }
    
    var baseRate: Double {
        switch self {
        case .standard: return 10.0
        case .express: return 25.0
        case .accessible: return 0.0 // Free service for students with accessibility needs
        }
    }
}

// MARK: - Buggy Status

enum BuggyStatus: String, Codable {
    case booked = "Booked"
    case assigned = "Driver Assigned"
    case arriving = "Buggy Arriving"
    case started = "Ride En Route"
    case completed = "Ride Completed"
}

// MARK: - Driver Info

struct BuggyDriver: Codable, Equatable, Hashable {
    let name: String
    let phone: String
    let rating: Double
    let vehicleNumber: String
    let vehicleModel: String
    let totalRides: Int
    
    static let sample = BuggyDriver(
        name: "Rajinder Singh",
        phone: "+91 98765-43210",
        rating: 4.9,
        vehicleNumber: "CU-EV-04",
        vehicleModel: "ClubCar EcoTrans 6",
        totalRides: 1420
    )
}

// MARK: - Buggy Booking Model

struct BuggyBooking: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let pickup: String
    let destination: String
    let passengers: Int
    let distance: Double
    let fare: Double
    let estimatedTime: Int
    let tier: BuggyTier
    var status: BuggyStatus
    let bookingTime: Date
    let driver: BuggyDriver
    var currentLatitude: Double
    var currentLongitude: Double

    init(
        id: UUID = UUID(),
        pickup: String,
        destination: String,
        passengers: Int,
        distance: Double,
        fare: Double,
        estimatedTime: Int,
        tier: BuggyTier = .standard,
        status: BuggyStatus = .booked,
        bookingTime: Date = Date(),
        driver: BuggyDriver = .sample,
        currentLatitude: Double? = nil,
        currentLongitude: Double? = nil
    ) {
        self.id = id
        self.pickup = pickup
        self.destination = destination
        self.passengers = passengers
        self.distance = distance
        self.fare = fare
        self.estimatedTime = estimatedTime
        self.tier = tier
        self.status = status
        self.bookingTime = bookingTime
        self.driver = driver
        
        let pCoord = campusLocationPoints[pickup] ?? CLLocationCoordinate2D(latitude: 30.7670, longitude: 76.5740)
        self.currentLatitude = currentLatitude ?? pCoord.latitude
        self.currentLongitude = currentLongitude ?? pCoord.longitude
    }
}

// MARK: - Campus Buggy Stops

let campusLocationPoints: [String: CLLocationCoordinate2D] = [
    "Main Gate 1": CLLocationCoordinate2D(latitude: 30.7670, longitude: 76.5740),
    "Block A (Admin & Library)": CLLocationCoordinate2D(latitude: 30.7675, longitude: 76.5746),
    "Block B (Engineering)": CLLocationCoordinate2D(latitude: 30.7685, longitude: 76.5760),
    "Block C (Auditorium & Medical)": CLLocationCoordinate2D(latitude: 30.7677, longitude: 76.5748),
    "Block D (Cafeteria & Food Court)": CLLocationCoordinate2D(latitude: 30.7683, longitude: 76.5745),
    "Block E (BioSciences)": CLLocationCoordinate2D(latitude: 30.7690, longitude: 76.5765),
    "Hostel Gate & Residencies": CLLocationCoordinate2D(latitude: 30.7700, longitude: 76.5775),
    "Sports Complex & Gym": CLLocationCoordinate2D(latitude: 30.7705, longitude: 76.5780)
]

let buggyPickupPoints: [String] = Array(campusLocationPoints.keys).sorted()
let buggyDestinationPoints: [String] = Array(campusLocationPoints.keys).sorted()

// MARK: - Distance Calculation

func buggyDistance(from pickup: String, to destination: String) -> Double {
    if pickup == destination { return 0.0 }
    
    guard let pickupCoord = campusLocationPoints[pickup],
          let destCoord = campusLocationPoints[destination] else {
        return 1.2
    }

    let pLoc = CLLocation(latitude: pickupCoord.latitude, longitude: pickupCoord.longitude)
    let dLoc = CLLocation(latitude: destCoord.latitude, longitude: destCoord.longitude)

    let meters = pLoc.distance(from: dLoc)
    let km = max(0.2, (meters / 1000.0) * 1.35)
    return (km * 10).rounded() / 10
}

// MARK: - Fare Calculation

func buggyFare(distance: Double, passengers: Int, tier: BuggyTier = .standard) -> Double {
    if distance == 0 { return 0.0 }
    if tier == .accessible { return 0.0 } // Accessible rides free for students

    let base = tier.baseRate
    let distanceFare = distance * (tier == .express ? 15.0 : 8.0)
    let passengerSurcharge = passengers > 1 ? Double(passengers - 1) * 5.0 : 0.0

    return (base + distanceFare + passengerSurcharge).rounded()
}

// MARK: - ETA Calculation

func buggyETA(distance: Double, tier: BuggyTier = .standard) -> Int {
    if distance == 0 { return 0 }
    let speed = tier == .express ? 18.0 : 12.0 // km/h
    let minutes = (distance / speed) * 60.0
    return max(2, Int(ceil(minutes)))
}
