import SwiftUI

struct FavoritesView: View {
    
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if favoritesManager.favoritePlaces.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(favoritesManager.favoritePlaces) { place in
                                favoriteCard(place)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue)
            }
            
            Text("No Favorites Saved")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Save your frequently visited campus locations for quick navigation and buggy booking.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }
    
    // MARK: - Favorite Card
    
    private func favoriteCard(_ place: CampusPlace) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconFor(place.type))
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(place.building) • Floor \(place.floor)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    favoritesManager.toggleFavorite(place)
                } label: {
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                NavigationLink {
                    CampusNavigationView(destination: place)
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Navigate")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                NavigationLink {
                    BuggyBookingView(destination: place.name)
                } label: {
                    HStack {
                        Text("🛺")
                        Text("Book Buggy")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func iconFor(_ type: String) -> String {
        switch type {
        case "Library": return "books.vertical.fill"
        case "Laboratory": return "desktopcomputer"
        case "Auditorium": return "building.columns.fill"
        case "Food": return "fork.knife"
        default: return "mappin.circle.fill"
        }
    }
}

#Preview {
    FavoritesView()
}
