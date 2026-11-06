import Foundation
import SwiftUI

// MARK: - Class Schedule Item

struct ClassSession: Identifiable, Hashable {
    let id = UUID()
    let subjectCode: String
    let subjectName: String
    let timeRange: String
    let block: String
    let roomNumber: String
    let facultyName: String
    let type: SessionType
    let isCurrent: Bool
    
    enum SessionType: String {
        case lecture = "Lecture"
        case lab = "Practical Lab"
        case tutorial = "Tutorial"
        case breakTime = "Break"
    }
}

// MARK: - Upcoming Exam

struct UpcomingExam: Identifiable, Hashable {
    let id = UUID()
    let subjectCode: String
    let subjectName: String
    let dateString: String
    let timeRange: String
    let venue: String
    let seatNumber: String
}

// MARK: - Sample Student Academic Data

let sampleTodayClasses: [ClassSession] = [
    ClassSession(
        subjectCode: "CS401",
        subjectName: "Artificial Intelligence & Neural Nets",
        timeRange: "09:00 AM – 10:30 AM",
        block: "Block B",
        roomNumber: "Room B-102",
        facultyName: "Dr. Ananya Roy",
        type: .lab,
        isCurrent: true
    ),
    ClassSession(
        subjectCode: "CS404",
        subjectName: "Cloud Computing & DevOps",
        timeRange: "10:45 AM – 12:15 PM",
        block: "Block B",
        roomNumber: "Room B-201",
        facultyName: "Prof. Rajesh Bawa",
        type: .lecture,
        isCurrent: false
    ),
    ClassSession(
        subjectCode: "LUNCH",
        subjectName: "Cafeteria Lunch Break",
        timeRange: "12:15 PM – 01:15 PM",
        block: "Block D",
        roomNumber: "Ground Hall",
        facultyName: "Campus Food Court",
        type: .breakTime,
        isCurrent: false
    ),
    ClassSession(
        subjectCode: "CS408",
        subjectName: "Robotics & Cyber-Physical Systems",
        timeRange: "01:30 PM – 03:00 PM",
        block: "Block B",
        roomNumber: "Room B-004",
        facultyName: "Prof. Vikram Malhotra",
        type: .lab,
        isCurrent: false
    ),
    ClassSession(
        subjectCode: "HS201",
        subjectName: "Professional Communication & Ethics",
        timeRange: "03:15 PM – 04:30 PM",
        block: "Block A",
        roomNumber: "Room A-105",
        facultyName: "Ms. Shalini Gupta",
        type: .tutorial,
        isCurrent: false
    )
]

let sampleUpcomingExams: [UpcomingExam] = [
    UpcomingExam(
        subjectCode: "CS401",
        subjectName: "Mid-Term: Artificial Intelligence",
        dateString: "Nov 12, 2026",
        timeRange: "10:00 AM – 12:00 PM",
        venue: "Block B, Room B-215",
        seatNumber: "Desk B-42"
    ),
    UpcomingExam(
        subjectCode: "CS404",
        subjectName: "Practical: Cloud Deployment",
        dateString: "Nov 16, 2026",
        timeRange: "02:00 PM – 04:00 PM",
        venue: "Block B, Lab B-102",
        seatNumber: "Terminal 18"
    )
]
