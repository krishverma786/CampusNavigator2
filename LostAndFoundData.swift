import Foundation
import SwiftUI

enum LostItemCategory: String, CaseIterable, Identifiable {
    case all = "All Items"
    case electronics = "Electronics"
    case ids = "IDs & Wallets"
    case accessories = "Bags & Keys"
    case books = "Books & Notes"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .electronics: return "laptopcomputer"
        case .ids: return "person.text.rectangle.fill"
        case .accessories: return "bag.fill"
        case .books: return "book.closed.fill"
        }
    }
}

enum ItemStatus: String {
    case found = "Found by Good Samaritan"
    case lost = "Reported Lost"
    case claimed = "Safely Returned"
}

struct LostFoundItem: Identifiable {
    let id = UUID()
    let title: String
    let category: LostItemCategory
    let locationFound: String
    let dateReported: String
    let contactPerson: String
    let contactPhone: String
    let status: ItemStatus
    let iconName: String
    let color: Color
}

var sampleLostItems: [LostFoundItem] = [
    LostFoundItem(
        title: "Apple AirPods Pro (2nd Gen)",
        category: .electronics,
        locationFound: "Central Library 1st Floor (Reading Desk 14)",
        dateReported: "Today, 11:20 AM",
        contactPerson: "Librarian Desk (Block A)",
        contactPhone: "+91 172-555-0150",
        status: .found,
        iconName: "airpodspro",
        color: .blue
    ),
    LostFoundItem(
        title: "Student ID Card & Metro Pass",
        category: .ids,
        locationFound: "Block D Food Court (Subway Counter)",
        dateReported: "Today, 01:15 PM",
        contactPerson: "Student Helpdesk A-008",
        contactPhone: "+91 172-555-0148",
        status: .found,
        iconName: "person.text.rectangle.fill",
        color: .green
    ),
    LostFoundItem(
        title: "Blue Nike Gym Duffel Bag",
        category: .accessories,
        locationFound: "Sports Complex Badminton Court #2",
        dateReported: "Yesterday, 06:45 PM",
        contactPerson: "Coach Balbir Singh",
        contactPhone: "+91 172-555-0601",
        status: .found,
        iconName: "bag.fill",
        color: .orange
    ),
    LostFoundItem(
        title: "HP Spectre 65W USB-C Charger",
        category: .electronics,
        locationFound: "Block B, Room B-102 (AI Lab)",
        dateReported: "Oct 31, 04:30 PM",
        contactPerson: "Lab Attendant (Block B)",
        contactPhone: "+91 172-555-0210",
        status: .claimed,
        iconName: "powerplug.fill",
        color: .purple
    )
]
