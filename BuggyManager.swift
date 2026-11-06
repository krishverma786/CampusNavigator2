import Foundation
import Combine
import CoreLocation

final class BuggyManager: ObservableObject {

    static let shared = BuggyManager()

    @Published var bookings: [BuggyBooking] = [] {
        didSet {
            saveBookings()
        }
    }

    private var timers: [UUID: Timer] = [:]
    private let storageKey = "campus_buggy_bookings_v2"

    private init() {
        loadBookings()
    }

    // MARK: - Add Booking

    func addBooking(_ booking: BuggyBooking) {
        bookings.insert(booking, at: 0)
        startLiveTracking(for: booking.id)
    }

    // MARK: - Live Tracking Simulation

    private func startLiveTracking(for bookingID: UUID) {
        timers[bookingID]?.invalidate()

        guard let booking = bookings.first(where: { $0.id == bookingID }) else { return }
        
        let pCoord = campusLocationPoints[booking.pickup] ?? CLLocationCoordinate2D(latitude: 30.7670, longitude: 76.5740)
        let dCoord = campusLocationPoints[booking.destination] ?? CLLocationCoordinate2D(latitude: 30.7681, longitude: 76.5754)

        var step = 0
        let totalSteps = 4

        let timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            DispatchQueue.main.async {
                guard let index = self.bookings.firstIndex(where: { $0.id == bookingID }) else {
                    timer.invalidate()
                    return
                }

                step += 1
                let progressFraction = min(1.0, Double(step) / Double(totalSteps))
                
                // Interpolate current latitude & longitude
                let currentLat = pCoord.latitude + (dCoord.latitude - pCoord.latitude) * progressFraction
                let currentLon = pCoord.longitude + (dCoord.longitude - pCoord.longitude) * progressFraction
                self.bookings[index].currentLatitude = currentLat
                self.bookings[index].currentLongitude = currentLon

                switch step {
                case 1:
                    self.bookings[index].status = .assigned
                case 2:
                    self.bookings[index].status = .arriving
                case 3:
                    self.bookings[index].status = .started
                case 4:
                    self.bookings[index].status = .completed
                    timer.invalidate()
                    self.timers.removeValue(forKey: bookingID)
                default:
                    timer.invalidate()
                }
            }
        }

        timers[bookingID] = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    // MARK: - Cancel Booking

    func cancelBooking(_ booking: BuggyBooking) {
        timers[booking.id]?.invalidate()
        timers.removeValue(forKey: booking.id)
        bookings.removeAll { $0.id == booking.id }
    }

    // MARK: - Clear All Bookings

    func clearAllBookings() {
        for timer in timers.values {
            timer.invalidate()
        }
        timers.removeAll()
        bookings.removeAll()
    }

    // MARK: - Persistence

    private func saveBookings() {
        if let encoded = try? JSONEncoder().encode(bookings) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadBookings() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([BuggyBooking].self, from: data) {
            bookings = decoded
            // Resume any uncompleted rides
            for b in bookings where b.status != .completed {
                startLiveTracking(for: b.id)
            }
        }
    }

    deinit {
        for timer in timers.values {
            timer.invalidate()
        }
    }
}
