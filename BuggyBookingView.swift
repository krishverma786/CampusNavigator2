import SwiftUI

struct BuggyBookingView: View {

    @StateObject private var manager = BuggyManager.shared

    @State private var pickup: String
    @State private var destination: String
    @State private var passengers = 1
    @State private var selectedTier: BuggyTier = .standard
    @State private var activeTabSegment = 0 // 0: Book, 1: My Rides
    
    @State private var bookedRideForTracking: BuggyBooking? = nil
    @State private var showBookingConfirmation = false
    @State private var showUPIPaymentSheet = false
    
    var onViewRides: (() -> Void)? = nil

    init(
        pickup: String = "Main Gate 1",
        destination: String = "Block D (Cafeteria & Food Court)",
        onViewRides: (() -> Void)? = nil
    ) {
        _pickup = State(initialValue: pickup)
        _destination = State(initialValue: destination)
        self.onViewRides = onViewRides
    }

    private var distance: Double {
        buggyDistance(from: pickup, to: destination)
    }

    private var fare: Double {
        buggyFare(distance: distance, passengers: passengers, tier: selectedTier)
    }

    private var estimatedTime: Int {
        buggyETA(distance: distance, tier: selectedTier)
    }
    
    private var isSameLocation: Bool {
        pickup == destination
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    
                    // Top Segmented Control (Book vs My Rides)
                    Picker("Buggy Mode", selection: $activeTabSegment) {
                        Text("Book Buggy").tag(0)
                        Text(activeRidesBadgeText).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    if activeTabSegment == 0 {
                        bookingScrollView
                    } else {
                        MyRidesView(embeddedMode: true)
                    }
                }
            }
            .navigationTitle("Campus Buggy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $bookedRideForTracking) { booking in
                BuggyTrackingView(booking: booking)
            }
            .sheet(isPresented: $showUPIPaymentSheet) {
                UPIPaymentSheet(amount: fare, description: "\(selectedTier.rawValue): \(pickup) → \(destination)") {
                    let booking = BuggyBooking(
                        pickup: pickup,
                        destination: destination,
                        passengers: passengers,
                        distance: distance,
                        fare: fare,
                        estimatedTime: estimatedTime,
                        tier: selectedTier
                    )
                    manager.addBooking(booking)
                    bookedRideForTracking = booking
                }
            }
        }
    }
    
    private var activeRidesBadgeText: String {
        let activeCount = manager.bookings.filter { $0.status != .completed }.count
        return activeCount > 0 ? "My Rides (\(activeCount))" : "My Rides"
    }
    
    // MARK: - Booking Scroll View
    
    private var bookingScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header Banner
                headerBanner

                // Quick Presets
                quickPresetsSection

                // Route Picker Card
                routeCard

                // Service Tier Selection
                tierSelector

                // Passenger Count
                passengerSelector

                // Fare Summary Card
                fareSummaryCard

                // Book Button
                bookButton

                Color.clear.frame(height: 30)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Header Banner

    private var headerBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 58, height: 58)

                Text("🛺")
                    .font(.system(size: 30))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Campus Mobility")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("ECO-EV")
                        .font(.system(size: 9, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }

                Text("Safe, zero-emission campus buggy transit across all blocks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Quick Presets

    private var quickPresetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Popular Buggy Routes")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    presetRouteChip("Gate 1 → Cafeteria", from: "Main Gate 1", to: "Block D (Cafeteria & Food Court)")
                    presetRouteChip("Hostel → Block B", from: "Hostel Gate & Residencies", to: "Block B (Engineering)")
                    presetRouteChip("Block A → Sports Complex", from: "Block A (Admin & Library)", to: "Sports Complex & Gym")
                }
            }
        }
    }

    private func presetRouteChip(_ title: String, from p: String, to d: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.35)) {
                pickup = p
                destination = d
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.orange)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
            .clipShape(Capsule())
        }
    }

    // MARK: - Route Card

    private var routeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Select Stops")
                .font(.headline)
                .fontWeight(.bold)

            // Pickup Row
            VStack(alignment: .leading, spacing: 6) {
                Text("PICKUP POINT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)

                HStack {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.blue)

                    Picker("Pickup", selection: $pickup) {
                        ForEach(buggyPickupPoints, id: \.self) { point in
                            Text(point).tag(point)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Swap Route Button
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: 18)
                    .padding(.leading, 18)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35)) {
                        let temp = pickup
                        pickup = destination
                        destination = temp
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption2)
                        Text("Swap")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.12))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                }
            }

            // Destination Row
            VStack(alignment: .leading, spacing: 6) {
                Text("DROP-OFF POINT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)

                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(.red)

                    Picker("Destination", selection: $destination) {
                        ForEach(buggyDestinationPoints, id: \.self) { point in
                            Text(point).tag(point)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if isSameLocation {
                Label("Pickup and destination must be different", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Service Tier Selector

    private var tierSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Service Tier")
                .font(.headline)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                ForEach(BuggyTier.allCases) { tier in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTier = tier
                        }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedTier == tier ? Color.blue : Color(.tertiarySystemBackground))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: tier.iconName)
                                    .foregroundStyle(selectedTier == tier ? .white : .blue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(tier.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)

                                Text(tier.subtitle)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(tier == .accessible ? "FREE" : "₹\(Int(buggyFare(distance: distance, passengers: passengers, tier: tier)))")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(selectedTier == tier ? .blue : .primary)
                            }
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedTier == tier ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Passenger Count

    private var passengerSelector: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Passengers")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text("Up to 6 seats")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 14) {
                Button {
                    if passengers > 1 { passengers -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(passengers > 1 ? .blue : .gray.opacity(0.4))
                }
                .disabled(passengers <= 1)

                Text("\(passengers)")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .frame(width: 24)

                Button {
                    if passengers < 6 { passengers += 1 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(passengers < 6 ? .blue : .gray.opacity(0.4))
                }
                .disabled(passengers >= 6)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Fare Summary

    private var fareSummaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("ESTIMATED FARE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(selectedTier == .accessible ? "FREE" : "₹\(Int(fare))")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)

                    Text("•  \(estimatedTime) min ETA  •  \(distance, specifier: "%.1f") km")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Book Button

    private var bookButton: some View {
        VStack(spacing: 10) {
            if fare > 0 {
                Button {
                    guard !isSameLocation else { return }
                    showUPIPaymentSheet = true
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.title3)
                        Text("Pay ₹\(Int(fare)) via Google Pay UPI")
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.white)
                    .padding(15)
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .disabled(isSameLocation)
            }

            Button {
                guard !isSameLocation else { return }

                let booking = BuggyBooking(
                    pickup: pickup,
                    destination: destination,
                    passengers: passengers,
                    distance: distance,
                    fare: fare,
                    estimatedTime: estimatedTime,
                    tier: selectedTier
                )

                manager.addBooking(booking)
                bookedRideForTracking = booking
            } label: {
                HStack {
                    Text("🛺")
                    Text(fare == 0 ? "Book Free Shuttle Ride" : "Cash / ID Card Tap on Board")
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(fare == 0 ? .white : .primary)
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(isSameLocation ? Color.gray.opacity(0.3) : (fare == 0 ? Color.green : Color(.tertiarySystemBackground)))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .disabled(isSameLocation)
        }
    }
}
