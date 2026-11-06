import Foundation
import CoreLocation
import SwiftUI

// MARK: - Stable UUIDs for Persistence

private let idCentralLibrary = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
private let idAccountsOffice = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
private let idComputerLab    = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
private let idAuditorium     = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
private let idCafeteria      = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!
private let idHealthCenter   = UUID(uuidString: "66666666-6666-6666-6666-666666666666")!
private let idPlacementCell  = UUID(uuidString: "77777777-7777-7777-7777-777777777777")!
private let idRoboticsLab    = UUID(uuidString: "88888888-8888-8888-8888-888888888888")!
private let idSportsComplex  = UUID(uuidString: "99999999-9999-9999-9999-999999999999")!
private let idAdmissions     = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
private let idExamsCell      = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!
private let idMainGate       = UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!
private let idStudentLounge  = UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!

// MARK: - Campus Blocks & Room Directory

let allCampusBlocks: [CampusBlock] = [
    
    // MARK: Block A - Admin & Central Library
    CampusBlock(
        id: "block-a",
        name: "Block A",
        title: "Administrative & Central Academic Block",
        code: "A",
        floors: 4,
        latitude: 30.7675,
        longitude: 76.5746,
        description: "Main administrative heart of the campus housing the Central Library, Accounts Office, Admissions, and VC Secretariat.",
        facilities: ["Central Library", "Elevators", "ATM Kiosk", "Restrooms", "Free Wi-Fi", "Wheelchair Ramp"],
        rooms: [
            CampusRoom(
                id: "A-002",
                roomNumber: "Room A-002",
                name: "Accounts & Fee Office",
                block: "Block A",
                floor: 0,
                category: .office,
                inCharge: "Mr. Ramesh Sharma (Finance Officer)",
                contactNumber: "+91 172-555-0142",
                email: "accounts@campus.edu",
                timings: "9:00 AM – 5:00 PM (Mon–Fri)",
                services: [
                    "Semester Fee Payment & Challan Verification",
                    "Scholarship & Concession Disbursement",
                    "No-Dues Clearance Certificates",
                    "Caution Money Refund Processing",
                    "Hostel & Mess Fee Billing"
                ],
                description: "Primary student finance desk for all tuition, exam fees, hostel payments, and administrative financial clearance."
            ),
            CampusRoom(
                id: "A-005",
                roomNumber: "Room A-005",
                name: "Admissions & Verification Cell",
                block: "Block A",
                floor: 0,
                category: .office,
                inCharge: "Dr. P. K. Verma (Dean Admissions)",
                contactNumber: "+91 172-555-0145",
                email: "admissions@campus.edu",
                timings: "8:30 AM – 5:30 PM (Mon–Sat)",
                services: ["Document Verification", "Seat Allocation", "Migration & Transfer Verification"],
                description: "Central processing hub for new student enrolments, degree verifications, and transfer approvals."
            ),
            CampusRoom(
                id: "A-008",
                roomNumber: "Room A-008",
                name: "Student Helpdesk & Grievance Cell",
                block: "Block A",
                floor: 0,
                category: .office,
                inCharge: "Ms. Shalini Gupta",
                contactNumber: "+91 172-555-0148",
                email: "helpdesk@campus.edu",
                timings: "9:00 AM – 6:00 PM",
                services: ["ID Card Re-issue", "General Inquiries", "Lost & Found Desk"],
                description: "First stop for campus inquiries, identity credentials, and general student queries."
            ),
            CampusRoom(
                id: "A-101",
                roomNumber: "Room A-101",
                name: "Central University Library",
                block: "Block A",
                floor: 1,
                category: .library,
                inCharge: "Dr. S. K. Mahajan (Chief Librarian)",
                contactNumber: "+91 172-555-0150",
                email: "library@campus.edu",
                timings: "8:00 AM – 10:00 PM (All 7 Days)",
                services: ["Book Borrowing & Returns", "Digital Research Portal", "Silent Study Cabins", "Printing & Scanning"],
                description: "Over 120,000 volumes, international journals, digital thesis repositories, and quiet study halls."
            ),
            CampusRoom(
                id: "A-201",
                roomNumber: "Room A-201",
                name: "Vice Chancellor Secretariat",
                block: "Block A",
                floor: 2,
                category: .office,
                inCharge: "Prof. (Dr.) A. K. Singh",
                contactNumber: "+91 172-555-0100",
                email: "vc@campus.edu",
                timings: "10:00 AM – 4:00 PM (By Appointment)",
                services: ["Executive Approvals", "Senate Meetings", "Distinguished Guest Delegations"],
                description: "Executive offices of the University Vice Chancellor and apex academic governing bodies."
            ),
            CampusRoom(
                id: "A-301",
                roomNumber: "Room A-301",
                name: "Controller of Examinations (COE)",
                block: "Block A",
                floor: 3,
                category: .office,
                inCharge: "Dr. Manpreet Kaur (COE)",
                contactNumber: "+91 172-555-0160",
                email: "coe@campus.edu",
                timings: "9:30 AM – 4:30 PM (Mon–Fri)",
                services: ["Hall Ticket Issues", "Official Transcripts", "Degree Certificates", "Re-evaluation Requests"],
                description: "Confidential and official examination record center, degree printing, and transcript issuance."
            )
        ],
        iconName: "building.columns.fill",
        color: .blue
    ),
    
    // MARK: Block B - Engineering & CS
    CampusBlock(
        id: "block-b",
        name: "Block B",
        title: "Engineering & Computer Sciences",
        code: "B",
        floors: 4,
        latitude: 30.7685,
        longitude: 76.5760,
        description: "State-of-the-art technological hub hosting high-performance computing labs, AI research centers, and Placement Cell.",
        facilities: ["High-Speed Wi-Fi", "AI Supercomputing Cluster", "Smart Classrooms", "Elevators", "Maker Space"],
        rooms: [
            CampusRoom(
                id: "B-004",
                roomNumber: "Room B-004",
                name: "Robotics & IoT Innovation Lab",
                block: "Block B",
                floor: 0,
                category: .lab,
                inCharge: "Prof. Vikram Malhotra",
                contactNumber: "+91 172-555-0204",
                email: "robotics.lab@campus.edu",
                timings: "8:30 AM – 6:30 PM",
                services: ["Drone Testing", "Embedded Systems", "3D Printing & Prototyping"],
                description: "Cutting-edge robotics facility with ROS workstations, sensor benches, and rapid prototyping tools."
            ),
            CampusRoom(
                id: "B-102",
                roomNumber: "Room B-102",
                name: "Artificial Intelligence & Cloud Lab",
                block: "Block B",
                floor: 1,
                category: .lab,
                inCharge: "Dr. Ananya Roy",
                contactNumber: "+91 172-555-0210",
                email: "ai.lab@campus.edu",
                timings: "8:00 AM – 8:00 PM",
                services: ["GPU Compute Workstations", "Deep Learning R&D", "Cloud Certifications"],
                description: "Equipped with NVIDIA Tensor Core workstations for machine learning, NLP, and vision computing."
            ),
            CampusRoom(
                id: "B-201",
                roomNumber: "Room B-201",
                name: "HOD Computer Science & Engineering",
                block: "Block B",
                floor: 2,
                category: .office,
                inCharge: "Prof. (Dr.) Rajesh Bawa",
                contactNumber: "+91 172-555-0220",
                email: "hod.cse@campus.edu",
                timings: "9:00 AM – 5:00 PM",
                services: ["Academic Counseling", "Course Registrations", "Project Approvals"],
                description: "Head of Department office for Computer Science and Engineering students and faculty."
            ),
            CampusRoom(
                id: "B-301",
                roomNumber: "Room B-301",
                name: "Corporate Resource & Placement Cell (CRC)",
                block: "Block B",
                floor: 3,
                category: .office,
                inCharge: "Mr. Deepinder Sood (Head - Placements)",
                contactNumber: "+91 172-555-0250",
                email: "placements@campus.edu",
                timings: "9:00 AM – 6:00 PM",
                services: ["Campus Drive Scheduling", "Internship NOC Approval", "Mock Interviews & Resume Reviews"],
                description: "Liaison with 500+ corporate recruiting partners, placement drives, and career advisory."
            )
        ],
        iconName: "desktopcomputer",
        color: .purple
    ),
    
    // MARK: Block C - Auditorium & Health
    CampusBlock(
        id: "block-c",
        name: "Block C",
        title: "Main Auditorium & Health Care",
        code: "C",
        floors: 3,
        latitude: 30.7677,
        longitude: 76.5748,
        description: "University cultural amphitheater, convention center, and 24x7 student health dispensary.",
        facilities: ["1200-Seat Auditorium", "24/7 Dispensary", "Ambulance Bay", "Acoustic Stage", "Pharmacy"],
        rooms: [
            CampusRoom(
                id: "C-001",
                roomNumber: "Hall C-001",
                name: "Main University Auditorium",
                block: "Block C",
                floor: 0,
                category: .auditorium,
                inCharge: "Cultural Affairs Directorate",
                contactNumber: "+91 172-555-0301",
                email: "events@campus.edu",
                timings: "Event-Based Schedule",
                services: ["Convocations", "National Conferences", "Cultural Festivals", "TEDx Events"],
                description: "Fully air-conditioned auditorium with theatrical Dolby surround sound, LED video walls, and green rooms."
            ),
            CampusRoom(
                id: "C-004",
                roomNumber: "Room C-004",
                name: "Campus Health Center & Emergency Care",
                block: "Block C",
                floor: 0,
                category: .health,
                inCharge: "Dr. Neha Kapoor (Chief Medical Officer)",
                contactNumber: "+91 172-555-0310",
                email: "health@campus.edu",
                timings: "Open 24/7 (Emergency Service)",
                services: [
                    "Doctor Consultations (Free for Students)",
                    "Emergency First Aid & Trauma Care",
                    "On-Campus Ambulance Service (Dial 102)",
                    "Subsidized Pharmacy & Generic Medicines",
                    "Mental Health & Counseling Clinic"
                ],
                description: "Round-the-clock medical care with qualified physicians, nursing staff, observation beds, and emergency triage."
            ),
            CampusRoom(
                id: "C-102",
                roomNumber: "Room C-102",
                name: "Dean Student Welfare (DSW) Office",
                block: "Block C",
                floor: 1,
                category: .office,
                inCharge: "Prof. Jasleen Sandhu",
                contactNumber: "+91 172-555-0320",
                email: "dsw@campus.edu",
                timings: "9:00 AM – 5:00 PM",
                services: ["Student Club Registrations", "Fest Passes & Permissions", "Sports Council Approvals"],
                description: "Apex authority supporting student student welfare, cultural bodies, leadership clubs, and extracurriculars."
            )
        ],
        iconName: "cross.case.fill",
        color: .red
    ),
    
    // MARK: Block D - Cafeteria & Food Court
    CampusBlock(
        id: "block-d",
        name: "Block D",
        title: "Student Center & Multi-Cuisine Food Court",
        code: "D",
        floors: 2,
        latitude: 30.7683,
        longitude: 76.5745,
        description: "The primary dining and social hub with multi-cuisine dining options, convenience retail, and recreation.",
        facilities: ["Multi-Cuisine Food Court", "Outdoor Seating Patio", "Stationery & Xerox", "Banking ATMs", "Juice Bars"],
        rooms: [
            CampusRoom(
                id: "D-001",
                roomNumber: "Ground Hall",
                name: "Central Cafeteria & Food Court",
                block: "Block D",
                floor: 0,
                category: .food,
                inCharge: "Campus Hospitality Management",
                contactNumber: "+91 172-555-0401",
                email: "cafeteria@campus.edu",
                timings: "7:30 AM – 11:00 PM (Daily)",
                services: [
                    "Breakfast, Lunch & Dinner Buffets",
                    "Branded Outlets (Subway, Domino's, Nescafe)",
                    "Beverages & Fresh Juice Counters",
                    "Hygienic Organic Salad Bar"
                ],
                description: "Spacious multi-level dining hall catering to 1,500+ students simultaneously with hygienic quality standards."
            ),
            CampusRoom(
                id: "D-003",
                roomNumber: "Shop D-003",
                name: "Stationery, Xerox & Book Depot",
                block: "Block D",
                floor: 0,
                category: .utility,
                inCharge: "Mr. Amarjit Singh",
                contactNumber: "+91 172-555-0403",
                email: "stationery@campus.edu",
                timings: "8:00 AM – 9:00 PM",
                services: ["Color Printing & Spiral Binding", "Academic Textbooks", "Project Drafting Supplies"],
                description: "One-stop shop for student project binding, blueprints, notebooks, and academic drafting supplies."
            ),
            CampusRoom(
                id: "D-101",
                roomNumber: "Room D-101",
                name: "Student Recreation & Gaming Lounge",
                block: "Block D",
                floor: 1,
                category: .utility,
                inCharge: "Student Activity Board",
                contactNumber: "+91 172-555-0410",
                email: "rec@campus.edu",
                timings: "10:00 AM – 9:30 PM",
                services: ["Table Tennis & Foosball", "Board Games Arena", "Acoustic Jamming Room", "Chill Pods"],
                description: "Relaxed social zone for study breaks, recreational sports, and student collaboration."
            )
        ],
        iconName: "fork.knife",
        color: .orange
    ),
    
    // MARK: Block E - BioSciences & Research
    CampusBlock(
        id: "block-e",
        name: "Block E",
        title: "BioSciences & Research Complex",
        code: "E",
        floors: 3,
        latitude: 30.7690,
        longitude: 76.5765,
        description: "Dedicated science and chemical engineering complex with precision laboratories and clean rooms.",
        facilities: ["Clean Rooms", "Chemical Waste Neutralization", "Autoclave Bays", "Bio-Incubator"],
        rooms: [
            CampusRoom(
                id: "E-002",
                roomNumber: "Room E-002",
                name: "Pharmaceutical Formulation Lab",
                block: "Block E",
                floor: 0,
                category: .lab,
                inCharge: "Dr. Sunita Bansal",
                contactNumber: "+91 172-555-0502",
                email: "pharma.lab@campus.edu",
                timings: "9:00 AM – 5:00 PM",
                services: ["Drug Synthesis Equipment", "HPLC & Spectrophotometry", "Cleanroom Access"],
                description: "Advanced pharmaceutical development laboratory for undergraduate and doctoral research."
            )
        ],
        iconName: "flask.fill",
        color: .teal
    ),
    
    // MARK: Sports Complex
    CampusBlock(
        id: "sports-complex",
        name: "Sports Complex",
        title: "Olympic Sports & Fitness Arena",
        code: "SC",
        floors: 2,
        latitude: 30.7705,
        longitude: 76.5780,
        description: "World-class athletics center featuring an Olympic pool, fitness gym, synthetic tracks, and indoor courts.",
        facilities: ["Olympic Pool", "Cardio & Strength Gym", "Wooden Badminton Courts", "Locker Rooms", "Physiotherapy"],
        rooms: [
            CampusRoom(
                id: "SC-001",
                roomNumber: "Ground Arena",
                name: "Cardio & Strength Gymnasium",
                block: "Sports Complex",
                floor: 0,
                category: .utility,
                inCharge: "Coach Balbir Singh",
                contactNumber: "+91 172-555-0601",
                email: "sports@campus.edu",
                timings: "6:00 AM – 9:00 PM",
                services: ["Weight Training", "Certified Personal Trainers", "Cardio Zone", "Steam & Sauna"],
                description: "State-of-the-art gym equipped with LifeFitness gear, crossfit rigs, and locker facilities."
            )
        ],
        iconName: "figure.run",
        color: .green
    ),
    
    // MARK: Hostel Zone
    CampusBlock(
        id: "hostel-zone",
        name: "Hostel Zone",
        title: "Student Residences & Dining Halls",
        code: "HZ",
        floors: 5,
        latitude: 30.7700,
        longitude: 76.5775,
        description: "Residential campus quarters accommodating over 8,000 students with dedicated dining, gyms, and 24x7 security.",
        facilities: ["Mess Halls", "Laundry Service", "Night Canteens", "Study Rooms", "Biometric Access"],
        rooms: [
            CampusRoom(
                id: "HZ-001",
                roomNumber: "Warden Office H-1",
                name: "Boys Hostel Warden & Admin Desk",
                block: "Hostel Zone",
                floor: 0,
                category: .office,
                inCharge: "Mr. Gurpreet Singh (Chief Warden)",
                contactNumber: "+91 172-555-0701",
                email: "hostel1@campus.edu",
                timings: "24/7 Gate / Office: 8:00 AM – 8:00 PM",
                services: ["Leave Applications & Out-Passes", "Room Allocation", "Maintenance Complaints", "Night Gate Registrations"],
                description: "Administrative control center for hostel resident services, safety, and amenities."
            )
        ],
        iconName: "bed.double.fill",
        color: .indigo
    ),
    
    // MARK: Main Gate & Transit
    CampusBlock(
        id: "main-gate",
        name: "Main Gate",
        title: "Campus Entrance & Transit Terminal",
        code: "MG",
        floors: 1,
        latitude: 30.7670,
        longitude: 76.5740,
        description: "Primary vehicular and pedestrian entrance with visitor registration desks and central Buggy dispatch station.",
        facilities: ["Security Post", "Visitor Passes", "Buggy Dispatch Terminal", "EV Fast Chargers", "Bus Bay"],
        rooms: [
            CampusRoom(
                id: "MG-001",
                roomNumber: "Gate 1 Desk",
                name: "Security Post & Visitor Reception",
                block: "Main Gate",
                floor: 0,
                category: .office,
                inCharge: "Col. D. S. Brar (Chief Security Officer)",
                contactNumber: "+91 172-555-0801",
                email: "security@campus.edu",
                timings: "24/7 Operations",
                services: ["Visitor Passes", "Parking Permits", "Emergency Dispatch", "Buggy Stand #1"],
                description: "24-hour campus security station, RFID vehicle gate control, and visitor credential verification."
            )
        ],
        iconName: "shield.lefthalf.filled",
        color: .cyan
    )
]

// MARK: - Sample Places (Expanded & Backward-Compatible)

let samplePlaces: [CampusPlace] = [
    CampusPlace(
        id: idCentralLibrary,
        name: "Central Library",
        type: "Library",
        building: "Block A",
        floor: 1,
        latitude: 30.7681,
        longitude: 76.5754,
        roomNumber: "Room A-101",
        blockId: "block-a"
    ),
    CampusPlace(
        id: idAccountsOffice,
        name: "Accounts & Fee Office",
        type: "Offices & Admin",
        building: "Block A",
        floor: 0,
        latitude: 30.7675,
        longitude: 76.5746,
        roomNumber: "Room A-002",
        blockId: "block-a"
    ),
    CampusPlace(
        id: idComputerLab,
        name: "Computer Science & AI Lab",
        type: "Laboratory",
        building: "Block B",
        floor: 1,
        latitude: 30.7685,
        longitude: 76.5760,
        roomNumber: "Room B-102",
        blockId: "block-b"
    ),
    CampusPlace(
        id: idAuditorium,
        name: "Main Auditorium",
        type: "Auditorium",
        building: "Block C",
        floor: 0,
        latitude: 30.7677,
        longitude: 76.5748,
        roomNumber: "Hall C-001",
        blockId: "block-c"
    ),
    CampusPlace(
        id: idCafeteria,
        name: "Cafeteria & Food Court",
        type: "Food",
        building: "Block D",
        floor: 0,
        latitude: 30.7683,
        longitude: 76.5745,
        roomNumber: "Ground Hall",
        blockId: "block-d"
    ),
    CampusPlace(
        id: idHealthCenter,
        name: "Health Center & Dispensary",
        type: "Medical & Health",
        building: "Block C",
        floor: 0,
        latitude: 30.7677,
        longitude: 76.5749,
        roomNumber: "Room C-004",
        blockId: "block-c"
    ),
    CampusPlace(
        id: idPlacementCell,
        name: "Placement Cell (CRC)",
        type: "Offices & Admin",
        building: "Block B",
        floor: 3,
        latitude: 30.7685,
        longitude: 76.5760,
        roomNumber: "Room B-301",
        blockId: "block-b"
    ),
    CampusPlace(
        id: idRoboticsLab,
        name: "Robotics & IoT Lab",
        type: "Laboratory",
        building: "Block B",
        floor: 0,
        latitude: 30.7684,
        longitude: 76.5759,
        roomNumber: "Room B-004",
        blockId: "block-b"
    ),
    CampusPlace(
        id: idSportsComplex,
        name: "Sports Complex & Gym",
        type: "Services & Utility",
        building: "Sports Complex",
        floor: 0,
        latitude: 30.7705,
        longitude: 76.5780,
        roomNumber: "Ground Arena",
        blockId: "sports-complex"
    ),
    CampusPlace(
        id: idAdmissions,
        name: "Admissions & Registrar",
        type: "Offices & Admin",
        building: "Block A",
        floor: 0,
        latitude: 30.7675,
        longitude: 76.5746,
        roomNumber: "Room A-005",
        blockId: "block-a"
    ),
    CampusPlace(
        id: idExamsCell,
        name: "Controller of Examinations",
        type: "Offices & Admin",
        building: "Block A",
        floor: 3,
        latitude: 30.7675,
        longitude: 76.5746,
        roomNumber: "Room A-301",
        blockId: "block-a"
    ),
    CampusPlace(
        id: idStudentLounge,
        name: "Student Recreation Lounge",
        type: "Services & Utility",
        building: "Block D",
        floor: 1,
        latitude: 30.7683,
        longitude: 76.5745,
        roomNumber: "Room D-101",
        blockId: "block-d"
    ),
    CampusPlace(
        id: idMainGate,
        name: "Main Campus Gate 1",
        type: "Services & Utility",
        building: "Main Gate",
        floor: 0,
        latitude: 30.7670,
        longitude: 76.5740,
        roomNumber: "Gate 1 Desk",
        blockId: "main-gate"
    )
]

// MARK: - Helper Methods

func findBlock(named name: String) -> CampusBlock? {
    allCampusBlocks.first {
        $0.name.localizedCaseInsensitiveContains(name) ||
        $0.id.localizedCaseInsensitiveContains(name)
    }
}

func allRooms() -> [CampusRoom] {
    allCampusBlocks.flatMap { $0.rooms }
}

func searchRooms(matching query: String) -> [CampusRoom] {
    let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !q.isEmpty else { return allRooms() }
    return allRooms().filter {
        $0.name.localizedCaseInsensitiveContains(q) ||
        $0.roomNumber.localizedCaseInsensitiveContains(q) ||
        $0.block.localizedCaseInsensitiveContains(q) ||
        $0.services.contains(where: { $0.localizedCaseInsensitiveContains(q) }) ||
        $0.description.localizedCaseInsensitiveContains(q)
    }
}
