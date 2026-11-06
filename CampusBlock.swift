import Foundation
import CoreLocation
import SwiftUI

// MARK: - Room Category

enum RoomCategory: String, CaseIterable, Codable, Identifiable {
    case office = "Offices & Admin"
    case academic = "Academic & Classrooms"
    case lab = "Laboratories"
    case food = "Food & Cafeteria"
    case library = "Library & Study"
    case auditorium = "Auditorium & Events"
    case health = "Medical & Health"
    case utility = "Services & Utility"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .office: return "briefcase.fill"
        case .academic: return "book.closed.fill"
        case .lab: return "desktopcomputer"
        case .food: return "fork.knife"
        case .library: return "books.vertical.fill"
        case .auditorium: return "theatermasks.fill"
        case .health: return "cross.case.fill"
        case .utility: return "wrench.and.screwdriver.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .office: return .blue
        case .academic: return .indigo
        case .lab: return .purple
        case .food: return .orange
        case .library: return .teal
        case .auditorium: return .red
        case .health: return .pink
        case .utility: return .green
        }
    }
}

// MARK: - Campus Room

struct CampusRoom: Identifiable, Hashable {
    let id: String
    let roomNumber: String
    let name: String
    let block: String
    let floor: Int
    let category: RoomCategory
    let inCharge: String
    let contactNumber: String
    let email: String
    let timings: String
    let services: [String]
    let description: String
    
    var floorName: String {
        switch floor {
        case 0: return "Ground Floor"
        case 1: return "1st Floor"
        case 2: return "2nd Floor"
        case 3: return "3rd Floor"
        default: return "Floor \(floor)"
        }
    }
}

// MARK: - Campus Block

struct CampusBlock: Identifiable, Hashable {
    let id: String
    let name: String
    let title: String
    let code: String
    let floors: Int
    let latitude: Double
    let longitude: Double
    let description: String
    let facilities: [String]
    let rooms: [CampusRoom]
    let iconName: String
    let color: Color
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var totalRooms: Int {
        rooms.count
    }
    
    func roomsOnFloor(_ floor: Int) -> [CampusRoom] {
        rooms.filter { $0.floor == floor }
    }
}
