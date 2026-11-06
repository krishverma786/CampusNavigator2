import SwiftUI
import MapKit

struct BuggyTrackingView: View {

    let booking: BuggyBooking
    @ObservedObject private var manager = BuggyManager.shared
    @Environment(\.dismiss) private var dismiss

    private var currentBooking: BuggyBooking? {
        manager.bookings.first(where: { $0.id == booking.id })
    }

    private var currentStatus: BuggyStatus {
        currentBooking?.status ?? booking.status
    }
    
    private var buggyCoordinate: CLLocationCoordinate2D {
        if let b = currentBooking {
            return CLLocationCoordinate2D(latitude: b.currentLatitude, longitude: b.currentLongitude)
        }
        let pCoord = campusLocationPoints[booking.pickup] ?? CLLocationCoordinate2D(latitude: 30.7670, longitude: 76.5740)
        return pCoord
    }
    
    private var pickupCoordinate: CLLocationCoordinate2D {
        campusLocationPoints[booking.pickup] ?? CLLocationCoordinate2D(latitude: 30.7670, longitude: 76.5740)
    }
    
    private var destinationCoordinate: CLLocationCoordinate2D {
        campusLocationPoints[booking.destination] ?? CLLocationCoordinate2D(latitude: 30.7681, longitude: 76.5754)
    }

    private var statusText: String {
        switch currentStatus {
        case .booked: return "Booking Confirmed"
        case .assigned: return "Driver Assigned"
        case .arriving: return "Buggy is Arriving"
        case .started: return "Ride En Route"
        case .completed: return "Ride Completed!"
        }
    }

    private var statusDescription: String {
        switch currentStatus {
        case .booked: return "Dispatching closest electric shuttle to your pickup"
        case .assigned: return "\(booking.driver.name) has accepted your ride"
        case .arriving: return "Buggy is approaching \(booking.pickup)"
        case .started: return "Heading towards \(booking.destination)"
        case .completed: return "You have safely arrived at \(booking.destination)"
        }
    }

    private var statusIcon: String {
        switch currentStatus {
        case .booked: return "checkmark.circle.fill"
        case .assigned: return "person.badge.shield.checkmark.fill"
        case .arriving: return "location.fill"
        case .started: return "bolt.car.fill"
        case .completed: return "flag.checkered"
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {

                    // Status Header
                    statusHeader

                    // Live Interactive Map with moving Buggy
                    liveMapCard

                    // Driver Profile & Contact
                    driverProfileCard

                    // Route Summary
                    routeDetailsCard

                    // Cancel or Done Action
                    if currentStatus != .completed {
                        cancelButton
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }

                    Color.clear.frame(height: 20)
                }
                .padding(16)
            }
        }
        .navigationTitle("Live Buggy Tracking")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: statusIcon)
                        .font(.title2)
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(statusText)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(statusDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            // Progress Timeline Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)

                    Capsule()
                        .fill(LinearGradient(colors: [.blue, .green], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * progressFraction, height: 6)
                        .animation(.easeInOut(duration: 0.5), value: progressFraction)
                }
            }
            .frame(height: 6)
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var progressFraction: CGFloat {
        switch currentStatus {
        case .booked: return 0.2
        case .assigned: return 0.4
        case .arriving: return 0.65
        case .started: return 0.85
        case .completed: return 1.0
        }
    }

    // MARK: - Live Map Card

    private var liveMapCard: some View {
        ZStack(alignment: .topTrailing) {
            Map {
                // Pickup Pin
                Annotation(booking.pickup, coordinate: pickupCoordinate) {
                    Circle().fill(Color.green).frame(width: 12, height: 12)
                }

                // Destination Pin
                Annotation(booking.destination, coordinate: destinationCoordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }

                // Moving Buggy Vehicle Annotation
                Annotation("Buggy", coordinate: buggyCoordinate) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.25))
                            .frame(width: 44, height: 44)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 26, height: 26)
                        Text("🛺")
                            .font(.system(size: 14))
                    }
                }

                // Route Line
                MapPolyline(coordinates: [pickupCoordinate, buggyCoordinate, destinationCoordinate])
                    .stroke(Color.blue, lineWidth: 4)
            }
            .frame(height: 230)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .allowsHitTesting(false)

            // Live Pulse Pill
            HStack(spacing: 5) {
                Circle().fill(Color.red).frame(width: 7, height: 7)
                Text("LIVE GPS")
                    .font(.system(size: 9, weight: .heavy))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .padding(10)
        }
    }

    // MARK: - Driver Profile Card

    private var driverProfileCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.indigo.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.indigo)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(booking.driver.name)
                            .font(.headline)
                            .fontWeight(.bold)

                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                            Text("\(booking.driver.rating, specifier: "%.1f")")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                    }

                    Text("\(booking.driver.vehicleModel) • \(booking.driver.vehicleNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Call Driver
                Button {
                    // Action simulation
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 42, height: 42)
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.green)
                    }
                }
            }

            Divider()

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "battery.100.bolt")
                        .foregroundStyle(.green)
                    Text("EV Battery 92%")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "shield.checkmark.fill")
                        .foregroundStyle(.blue)
                    Text("Campus Verified Driver")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Route Details Card

    private var routeDetailsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ride Summary")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text(booking.pickup)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    HStack(spacing: 10) {
                        Circle().fill(Color.red).frame(width: 8, height: 8)
                        Text(booking.destination)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(booking.fare == 0 ? "FREE" : "₹\(Int(booking.fare))")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("\(booking.passengers) \(booking.passengers > 1 ? "riders" : "rider")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Cancel Button

    private var cancelButton: some View {
        Button(role: .destructive) {
            manager.cancelBooking(booking)
            dismiss()
        } label: {
            HStack {
                Image(systemName: "xmark.circle")
                Text("Cancel Buggy Request")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
