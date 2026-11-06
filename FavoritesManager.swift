import Foundation
import Combine

final class FavoritesManager: ObservableObject {
    
    static let shared = FavoritesManager()
    
    @Published var favoriteIDs: Set<UUID> = [] {
        didSet {
            saveFavorites()
        }
    }
    
    private let userDefaultsKey = "campus_favorite_place_ids"
    
    private init() {
        loadFavorites()
    }
    
    func isFavorite(_ place: CampusPlace) -> Bool {
        favoriteIDs.contains(place.id)
    }
    
    func toggleFavorite(_ place: CampusPlace) {
        if isFavorite(place) {
            favoriteIDs.remove(place.id)
        } else {
            favoriteIDs.insert(place.id)
        }
    }
    
    var favoritePlaces: [CampusPlace] {
        samplePlaces.filter { favoriteIDs.contains($0.id) }
    }
    
    private func saveFavorites() {
        let strings = favoriteIDs.map { $0.uuidString }
        UserDefaults.standard.set(strings, forKey: userDefaultsKey)
    }
    
    private func loadFavorites() {
        if let saved = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
            let uuids = saved.compactMap { UUID(uuidString: $0) }
            favoriteIDs = Set(uuids)
        } else {
            // Default favorite Computer Lab (samplePlaces[1]) for demo
            if samplePlaces.count > 1 {
                favoriteIDs.insert(samplePlaces[1].id)
            }
        }
    }
}
