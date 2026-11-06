import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 30.7681,
                longitude: 76.5754
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.006,
                longitudeDelta: 0.006
            )
        )
    )
    
    @State private var selectedPlace: CampusPlace? = nil
    @State private var selectedMapFilter = "All"
    
    private let mapFilterOptions = ["All", "Blocks", "Food", "Admin", "Labs"]
    
    private var displayedPlaces: [CampusPlace] {
        switch selectedMapFilter {
        case "Food":
            return samplePlaces.filter { $0.type.contains("Food") }
        case "Admin":
            return samplePlaces.filter { $0.type.contains("Admin") || $0.name.contains("Account") }
        case "Labs":
            return samplePlaces.filter { $0.type.contains("Labor") }
        default:
            return samplePlaces
        }
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack(alignment: .bottom) {
                
                Map(position: $position, selection: selectedPlaceID) {
                    
                    UserAnnotation()
                    
                    // Display Campus Places
                    ForEach(displayedPlaces) { place in
                        Marker(
                            place.name,
                            systemImage: iconFor(place.type),
                            coordinate: place.coordinate
                        )
                        .tint(colorFor(place.type))
                        .tag(place.id)
                    }
                    
                    // Display Blocks
                    if selectedMapFilter == "All" || selectedMapFilter == "Blocks" {
                        ForEach(allCampusBlocks) { block in
                            Annotation(block.name, coordinate: block.coordinate) {
                                VStack(spacing: 2) {
                                    ZStack {
                                        Circle().fill(block.color).frame(width: 32, height: 32)
                                        Image(systemName: block.iconName)
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                    }
                                    Text(block.code)
                                        .font(.system(size: 8, weight: .heavy))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(.regularMaterial)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                
                // Top Overlay: Filter Chips
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(mapFilterOptions, id: \.self) { opt in
                                Button {
                                    withAnimation { selectedMapFilter = opt }
                                } label: {
                                    Text(opt)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedMapFilter == opt ? Color.blue : Color(.systemBackground).opacity(0.85))
                                        .foregroundStyle(selectedMapFilter == opt ? .white : .primary)
                                        .clipShape(Capsule())
                                        .shadow(color: .black.opacity(0.08), radius: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                
                // Floating Action Buttons (Recenter)
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Button {
                                locationManager.requestPermission()
                                position = .userLocation(fallback: .region(campusRegion))
                            } label: {
                                Image(systemName: "location.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                    .frame(width: 42, height: 42)
                                    .background(.regularMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Button {
                                withAnimation { position = .region(campusRegion) }
                            } label: {
                                Image(systemName: "building.2.crop.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                    .frame(width: 42, height: 42)
                                    .background(.regularMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 56)
                    }
                    Spacer()
                }
                
                // Selected Place Bottom Card
                if let place = selectedPlace {
                    placeCard(place)
                        .padding(14)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Interactive Campus Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestPermission()
            }
        }
    }
    
    private var selectedPlaceID: Binding<UUID?> {
        Binding(
            get: { selectedPlace?.id },
            set: { newID in
                selectedPlace = samplePlaces.first(where: { $0.id == newID })
            }
        )
    }
    
    private var campusRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30.7681, longitude: 76.5754),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }
    
    // MARK: - Selected Place Card
    
    private func placeCard(_ place: CampusPlace) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(colorFor(place.type).opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconFor(place.type))
                        .foregroundStyle(colorFor(place.type))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(place.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if let roomNum = place.roomNumber {
                            Text(roomNum)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("\(place.building) • Floor \(place.floor)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    favoritesManager.toggleFavorite(place)
                } label: {
                    Image(systemName: favoritesManager.isFavorite(place) ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(favoritesManager.isFavorite(place) ? .yellow : .gray)
                }
                
                Button {
                    selectedPlace = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 8) {
                NavigationLink {
                    CampusNavigationView(destination: place)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                        Text("Walk Here")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                NavigationLink {
                    RoutePlannerView(
                        initialOrigin: .currentLocation,
                        initialDestination: CampusNavPoint.fromPlace(place)
                    )
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.swap")
                        Text("Plan Route")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                NavigationLink {
                    BuggyBookingView(destination: place.building)
                } label: {
                    HStack(spacing: 4) {
                        Text("🛺")
                        Text("Buggy")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.indigo)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.indigo.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(14)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
    }
    
    private func iconFor(_ type: String) -> String {
        switch type {
        case "Library": return "books.vertical.fill"
        case "Laboratory": return "desktopcomputer"
        case "Auditorium": return "theatermasks.fill"
        case "Food": return "fork.knife"
        case "Offices & Admin": return "briefcase.fill"
        case "Medical & Health": return "cross.case.fill"
        default: return "mappin.circle.fill"
        }
    }
    
    private func colorFor(_ type: String) -> Color {
        switch type {
        case "Library": return .teal
        case "Laboratory": return .purple
        case "Auditorium": return .red
        case "Food": return .orange
        case "Offices & Admin": return .blue
        case "Medical & Health": return .pink
        default: return .blue
        }
    }
}

#Preview {
    MapView()
}
