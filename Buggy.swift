import Foundation

// MARK: - Buggy Information

struct BuggyInfo: Identifiable {

    let id = UUID()
    let name: String
    let number: String
    let capacity: Int
    let isAvailable: Bool
}

// MARK: - Available Buggies

let campusBuggies: [BuggyInfo] = [

    BuggyInfo(
        name: "Campus Buggy 01",
        number: "BUG-01",
        capacity: 6,
        isAvailable: true
    ),

    BuggyInfo(
        name: "Campus Buggy 02",
        number: "BUG-02",
        capacity: 6,
        isAvailable: true
    ),

    BuggyInfo(
        name: "Campus Buggy 03",
        number: "BUG-03",
        capacity: 6,
        isAvailable: true
    )
]
