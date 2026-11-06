import Foundation
import CoreLocation

struct CampusPlace: Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: String
    let building: String
    let floor: Int
    let latitude: Double
    let longitude: Double
    let roomNumber: String?
    let blockId: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        type: String,
        building: String,
        floor: Int,
        latitude: Double,
        longitude: Double,
        roomNumber: String? = nil,
        blockId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.building = building
        self.floor = floor
        self.latitude = latitude
        self.longitude = longitude
        self.roomNumber = roomNumber
        self.blockId = blockId
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
