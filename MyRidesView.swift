import SwiftUI

struct MyRidesView: View {

    var embeddedMode: Bool = false
    @ObservedObject private var manager = BuggyManager.shared

    var body: some View {
        Group {
            if embeddedMode {
                ridesContent
            } else {
                NavigationStack {
                    ridesContent
                        .navigationTitle("My Rides")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            if !manager.bookings.isEmpty {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Clear All") {
                                        manager.clearAllBookings()
                                    }
                                    .foregroundStyle(.red)
                                }
                            }
                        }
                }
            }
        }
    }

    private var ridesContent: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if manager.bookings.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 16) {

                        HStack {
                            Text("Ride History & Live Trips")
                                .font(.headline)
                                .fontWeight(.bold)

                            Spacer()

                            Text("\(manager.bookings.count) Total")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }

                        ForEach(manager.bookings) { booking in
                            NavigationLink {
                                BuggyTrackingView(booking: booking)
                            } label: {
                                rideCard(booking)
                            }
                            .buttonStyle(.plain)
                        }

                        Color.clear.frame(height: 30)
                    }
                    .padding(16)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)

                Text("🛺")
                    .font(.system(size: 38))
            }

            Text("No Buggy Rides Yet")
                .font(.title3)
                .fontWeight(.bold)

            Text("Book an electric campus buggy to easily travel between academic blocks, hostels, and cafeteria.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    // MARK: - Ride Card

    private func rideCard(_ booking: BuggyBooking) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack {
                HStack(spacing: 8) {
                    Text("🛺")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(booking.tier.rawValue)
                            .font(.subheadline)
                            .fontWeight(.bold)

                        Text("Plate: \(booking.driver.vehicleNumber)")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                statusBadge(booking.status)
            }

            Divider()

            // Route
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text(booking.pickup)
                        .font(.caption)
                        .fontWeight(.medium)
                }

                HStack(spacing: 8) {
                    Circle().fill(Color.red).frame(width: 8, height: 8)
                    Text(booking.destination)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }

            // Footer
            HStack {
                Text(booking.fare == 0 ? "FREE" : "₹\(Int(booking.fare))")
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.blue)

                Text("•  \(booking.distance, specifier: "%.1f") km  •  \(booking.passengers) rider(s)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 3) {
                    Text(booking.status == .completed ? "Receipt" : "Track Live")
                        .font(.caption2)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9))
                }
                .foregroundStyle(.blue)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statusBadge(_ status: BuggyStatus) -> some View {
        let (color, text) = badgeStyle(status)
        return Text(text)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func badgeStyle(_ status: BuggyStatus) -> (Color, String) {
        switch status {
        case .booked: return (.orange, "Booked")
        case .assigned: return (.blue, "Assigned")
        case .arriving: return (.indigo, "Arriving")
        case .started: return (.purple, "En Route")
        case .completed: return (.green, "Completed")
        }
    }
}
