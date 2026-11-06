import Foundation
import SwiftUI

// MARK: - Event Category

enum EventCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case tech = "Hackathons & Tech"
    case cultural = "Cultural & Fests"
    case sports = "Sports & Games"
    case academic = "Workshops & Seminars"
    
    var id: String { rawValue }
}

// MARK: - Campus Event Model

struct CampusEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let category: EventCategory
    let dateRange: String
    let timeString: String
    let venue: String
    let block: String
    let organizer: String
    let feeString: String
    let prizePool: String?
    let description: String
    var isRegistered: Bool = false
    let iconName: String
    let bannerColor: Color
}

// MARK: - Sample Campus Events

var sampleCampusEvents: [CampusEvent] = [
    CampusEvent(
        id: "evt-01",
        title: "CU HackSprint 2026 (36-Hour Hackathon)",
        category: .tech,
        dateRange: "Nov 14 – 15, 2026",
        timeString: "09:00 AM Onwards",
        venue: "Block B, AI & Cloud Computing Lab",
        block: "Block B",
        organizer: "Google Developer Student Club & CSE Dept",
        feeString: "Free Entry",
        prizePool: "₹1,50,000 Cash Pool",
        description: "Build cutting-edge AI agents, mobile solutions, and web platforms in 36 sleepless hours of intense coding.",
        isRegistered: false,
        iconName: "laptopcomputer.and.arrow.down",
        bannerColor: .blue
    ),
    CampusEvent(
        id: "evt-02",
        title: "Aura 2026: Annual University Cultural Fest",
        category: .cultural,
        dateRange: "Nov 20 – 22, 2026",
        timeString: "04:00 PM – 10:00 PM",
        venue: "Main University Auditorium (Block C)",
        block: "Block C",
        organizer: "Directorate of Student Welfare",
        feeString: "Free for Students",
        prizePool: "Star Night with Celebrity Artist",
        description: "The grandest annual cultural extravaganza with music battles, street plays, flash mobs, and celebrity musical concerts.",
        isRegistered: true,
        iconName: "guitars.fill",
        bannerColor: .purple
    ),
    CampusEvent(
        id: "evt-03",
        title: "Inter-Department Badminton & Futsal Cup",
        category: .sports,
        dateRange: "Nov 08 – 10, 2026",
        timeString: "05:00 PM Daily",
        venue: "Sports Complex Indoor Arena",
        block: "Sports Complex",
        organizer: "University Sports Council",
        feeString: "Free Registration",
        prizePool: "Trophies + Medals",
        description: "Annual university tournament with men's and women's singles, doubles, and mixed badminton matches.",
        isRegistered: false,
        iconName: "figure.badminton",
        bannerColor: .orange
    ),
    CampusEvent(
        id: "evt-04",
        title: "Hands-on Workshop: Deep Learning with PyTorch",
        category: .academic,
        dateRange: "Nov 07, 2026",
        timeString: "10:00 AM – 01:00 PM",
        venue: "Block B, Seminar Hall B-315",
        block: "Block B",
        organizer: "AI Research Cell",
        feeString: "Free",
        prizePool: "Certificate of Participation",
        description: "Step-by-step introduction to transformer architectures, model training, and generative computer vision.",
        isRegistered: false,
        iconName: "brain.head.profile",
        bannerColor: .teal
    )
]
