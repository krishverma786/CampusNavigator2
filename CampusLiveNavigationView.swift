import SwiftUI
import MapKit

struct CampusLiveNavigationView: View {
    
    let destinationName: String
    
    @State private var cameraPosition: MapCameraPosition
    @State private var route: MKRoute?
    @State private var isLoading = true
    @State private var routeError = false
    
    // Demo starting point
    private let startCoordinate = CLLocationCoordinate2D(
        latitude: 30.7697,
        longitude: 76.5754
    )
    
    init(destinationName: String) {
        self.destinationName = destinationName
        
        let start = CLLocationCoordinate2D(
            latitude: 30.7697,
            longitude: 76.5754
        )
        
        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: start,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.008,
                        longitudeDelta: 0.008
                    )
                )
            )
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Map(position: $cameraPosition) {
                
                // Demo starting location
                Annotation(
                    "Your Location",
                    coordinate: startCoordinate
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.20))
                            .frame(width: 52, height: 52)
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 20, height: 20)
                    }
                }
                
                // Destination
                if let destination = destinationCoordinate {
                    Annotation(
                        destinationName,
                        coordinate: destination
                    ) {
                        VStack(spacing: 3) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.red)
                            
                            Text(destinationName)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(.regularMaterial)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Road route
                if let route = route {
                    MapPolyline(route.polyline)
                        .stroke(
                            Color.blue,
                            lineWidth: 7
                        )
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea(edges: .bottom)
            
            bottomCard
        }
        .navigationTitle("Live Navigation")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await calculateRoute()
        }
    }
    
    // MARK: - Destination
    
    private var destinationCoordinate: CLLocationCoordinate2D? {
        switch destinationName {
            
        case "Main Gate":
            return CLLocationCoordinate2D(
                latitude: 30.7697,
                longitude: 76.5754
            )
            
        case "Central Library":
            return CLLocationCoordinate2D(
                latitude: 30.7708,
                longitude: 76.5766
            )
            
        case "D Block":
            return CLLocationCoordinate2D(
                latitude: 30.7715,
                longitude: 76.5772
            )
            
        case "Student Center":
            return CLLocationCoordinate2D(
                latitude: 30.7699,
                longitude: 76.5777
            )
            
        case "Hostel":
            return CLLocationCoordinate2D(
                latitude: 30.7722,
                longitude: 76.5780
            )
            
        default:
            return CLLocationCoordinate2D(
                latitude: 30.7708,
                longitude: 76.5766
            )
        }
    }
    
    // MARK: - Bottom Card
    
    private var bottomCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Navigate to")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(destinationName)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: "location.fill")
                        .foregroundStyle(.blue)
                }
            }
            
            Divider()
            
            if isLoading {
                
                HStack(spacing: 10) {
                    ProgressView()
                    
                    Text("Finding the best route...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
            } else if routeError {
                
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    
                    Text("Unable to find a road route.")
                        .font(.subheadline)
                }
                
            } else if let route = route {
                
                HStack(spacing: 28) {
                    
                    infoItem(
                        icon: "road.lanes",
                        value: formatDistance(route.distance),
                        title: "Distance"
                    )
                    
                    infoItem(
                        icon: "clock.fill",
                        value: formatTime(route.expectedTravelTime),
                        title: "ETA"
                    )
                    
                    infoItem(
                        icon: "car.fill",
                        value: "Campus",
                        title: "Mode"
                    )
                }
                
                Divider()
                
                HStack(spacing: 10) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .foregroundStyle(.blue)
                    
                    Text("Follow the blue road route")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
            }
        }
        .padding(18)
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
        .shadow(
            color: .black.opacity(0.15),
            radius: 12,
            y: 5
        )
    }
    
    // MARK: - Information Item
    
    private func infoItem(
        icon: String,
        value: String,
        title: String
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 5) {
            
            Image(systemName: icon)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Calculate Road Route
    
    private func calculateRoute() async {
        
        guard let destination = destinationCoordinate else {
            await MainActor.run {
                isLoading = false
                routeError = true
            }
            return
        }
        
        let request = MKDirections.Request()
        
        // Fixed campus starting point.
        // This does NOT request the user's GPS location.
        request.source = MKMapItem(
            placemark: MKPlacemark(
                coordinate: startCoordinate
            )
        )
        
        request.destination = MKMapItem(
            placemark: MKPlacemark(
                coordinate: destination
            )
        )
        
        request.transportType = .automobile
        
        do {
            let directions = MKDirections(
                request: request
            )
            
            let response = try await directions.calculate()
            
            guard let calculatedRoute = response.routes.first else {
                await MainActor.run {
                    isLoading = false
                    routeError = true
                }
                return
            }
            
            await MainActor.run {
                route = calculatedRoute
                isLoading = false
                routeError = false
                
                let rect = calculatedRoute.polyline.boundingMapRect
                
                cameraPosition = .rect(
                    rect.insetBy(
                        dx: -500,
                        dy: -500
                    )
                )
            }
            
        } catch {
            
            print(
                "Route Error: \(error.localizedDescription)"
            )
            
            await MainActor.run {
                isLoading = false
                routeError = true
            }
        }
    }
    
    // MARK: - Distance
    
    private func formatDistance(
        _ meters: CLLocationDistance
    ) -> String {
        
        if meters < 1000 {
            return "\(Int(meters)) m"
        }
        
        return String(
            format: "%.1f km",
            meters / 1000
        )
    }
    
    // MARK: - Time
    
    private func formatTime(
        _ seconds: TimeInterval
    ) -> String {
        
        let minutes = max(
            1,
            Int(ceil(seconds / 60))
        )
        
        if minutes < 60 {
            return "\(minutes) min"
        }
        
        let hours = minutes / 60
        let remaining = minutes % 60
        
        return "\(hours)h \(remaining)m"
    }
}

#Preview {
    NavigationStack {
        CampusLiveNavigationView(
            destinationName: "Central Library"
        )
    }
}
