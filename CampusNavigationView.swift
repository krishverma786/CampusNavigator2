import SwiftUI

struct CampusNavigationView: View {
    
    let destination: CampusPlace
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    @State private var navigationStarted = false
    @State private var currentStepIndex = 0
    @State private var showCustomRoutePlanner = false
    
    private var routeInfo: CampusRouteInfo {
        RoutingService.shared.generateRoute(to: destination)
    }
    
    var body: some View {
        
        ZStack {
            
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    // Destination Header Card
                    VStack(spacing: 12) {
                        
                        HStack {
                            if let roomNum = destination.roomNumber {
                                Text(roomNum)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }
                            
                            Spacer()
                            
                            Button {
                                favoritesManager.toggleFavorite(destination)
                            } label: {
                                Image(systemName: favoritesManager.isFavorite(destination) ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(favoritesManager.isFavorite(destination) ? .yellow : .gray)
                            }
                        }
                        
                        Image(systemName: iconFor(destination.type))
                            .font(.system(size: 46))
                            .foregroundStyle(.blue)
                        
                        Text(destination.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("\(destination.building) • Floor \(destination.floor)\(destination.roomNumber != nil ? " • \(destination.roomNumber!)" : "")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    
                    // Interactive Indoor Floor Map View Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Floor Layout & Rooms", systemImage: "square.split.bottomrightquarter")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Spacer()
                            Text("Floor \(destination.floor)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                        
                        IndoorMapView(
                            floor: destination.floor,
                            buildingName: destination.building,
                            targetRoom: destination.roomNumber
                        )
                    }
                    
                    // Dynamic Route Metrics
                    HStack(spacing: 12) {
                        RouteInfo(
                            icon: "figure.walk",
                            title: "\(routeInfo.walkingTimeMinutes) min",
                            subtitle: "Walking Time"
                        )
                        
                        RouteInfo(
                            icon: "arrow.triangle.turn.up.right.diamond.fill",
                            title: "\(routeInfo.distanceMeters) m",
                            subtitle: "Distance"
                        )
                        
                        RouteInfo(
                            icon: "flame.fill",
                            title: "\(routeInfo.caloriesEstimate) kcal",
                            subtitle: "Energy"
                        )
                    }
                    
                    // Start Navigation Button
                    Button {
                        withAnimation(.spring(response: 0.35)) {
                            navigationStarted.toggle()
                            if !navigationStarted {
                                currentStepIndex = 0
                            }
                        }
                    } label: {
                        HStack {
                            Image(
                                systemName: navigationStarted
                                ? "stop.fill"
                                : "location.fill"
                            )
                            
                            Text(
                                navigationStarted
                                ? "End Navigation"
                                : "Start Turn-by-Turn Guidance"
                            )
                            .fontWeight(.bold)
                            
                            Spacer()
                            
                            Image(systemName: navigationStarted ? "xmark" : "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            navigationStarted
                            ? Color.red
                            : Color.blue
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    
                    // Live Navigation Steps Box
                    if navigationStarted {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("Step \(currentStepIndex + 1) of \(routeInfo.steps.count)", systemImage: "figure.walk.motion")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                                
                                Spacer()
                                
                                Text("\(routeInfo.steps[currentStepIndex].distanceMeters) m")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            HStack(spacing: 14) {
                                Image(systemName: routeInfo.steps[currentStepIndex].iconName)
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                    .frame(width: 40)
                                
                                Text(routeInfo.steps[currentStepIndex].instruction)
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            
                            Divider()
                            
                            HStack {
                                Button("Previous") {
                                    if currentStepIndex > 0 {
                                        currentStepIndex -= 1
                                    }
                                }
                                .disabled(currentStepIndex == 0)
                                
                                Spacer()
                                
                                Button(currentStepIndex < routeInfo.steps.count - 1 ? "Next Step →" : "Arrived!") {
                                    if currentStepIndex < routeInfo.steps.count - 1 {
                                        currentStepIndex += 1
                                    } else {
                                        navigationStarted = false
                                    }
                                }
                                .fontWeight(.bold)
                            }
                        }
                        .padding(18)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Customize Starting Point & Multi-Point Planner Link
                    NavigationLink {
                        RoutePlannerView(
                            initialOrigin: .currentLocation,
                            initialDestination: CampusNavPoint.fromPlace(destination)
                        )
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.swap")
                                .foregroundStyle(.blue)
                            Text("Change Starting Point / Choose Mode")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Option to Book Buggy Instead
                    NavigationLink {
                        BuggyBookingView(destination: destination.building)
                    } label: {
                        HStack {
                            Text("🛺")
                            Text("Need a ride? Book a Buggy to \(destination.building)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.primary)
                        .padding()
                        .background(Color.indigo.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
        }
        .navigationTitle(destination.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func iconFor(_ type: String) -> String {
        switch type {
        case "Library": return "books.vertical.fill"
        case "Laboratory": return "desktopcomputer"
        case "Auditorium": return "building.columns.fill"
        case "Food": return "fork.knife"
        case "Offices & Admin": return "briefcase.fill"
        case "Medical & Health": return "cross.case.fill"
        default: return "mappin.circle.fill"
        }
    }
}

struct RouteInfo: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(title)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        CampusNavigationView(
            destination: samplePlaces[0]
        )
    }
}
