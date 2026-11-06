import SwiftUI

struct HomeView: View {

    @ObservedObject private var buggyManager = BuggyManager.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var geminiService = GeminiAPIService.shared

    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @AppStorage("currentUserName") private var currentUserName = ""
    @State private var showLogoutConfirmation = false
    @State private var showingClassNavigation = false
    @State private var showingProfileSettings = false

    private var activeBooking: BuggyBooking? {
        buggyManager.bookings.first(where: {
            $0.status != .completed
        })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: - Top Header
                        headerSection

                        // MARK: - Campus Live Status Ticker
                        campusStatusTicker

                        // MARK: - CampusBuddy AI Floating Banner
                        campusBuddyAIBanner

                        // MARK: - Active Buggy Ride (if any)
                        if let booking = activeBooking {
                            activeRideBanner(booking)
                        }

                        // MARK: - Smart Student Dashboard: Next Class Card
                        currentClassCard

                        // MARK: - Quick Search Bar
                        searchBarSection

                        // MARK: - Smart Campus Services (Timetable, Events, QR Check-In, Lost & Found, Helpdesk)
                        campusServicesGrid

                        // MARK: - Quick Navigation Shortcuts (Block to Cafeteria, Accounts Office, etc.)
                        quickRoutesSection

                        // MARK: - Campus Blocks Carousel
                        campusBlocksSection

                        // MARK: - Explore Map Preview
                        mapPreviewSection

                        // MARK: - Key Destinations & Offices
                        popularDestinationsSection

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 44)
                }
                .scrollBounceBehavior(.always)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingProfileSettings) {
                ProfileSettingsSheet()
            }
            .confirmationDialog(
                "Log out of CampusNavigator?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    withAnimation {
                        isLoggedIn = false
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(currentUserName.isEmpty ? "Hi, Student 👋" : "Hi, \(currentUserName) 👋")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)

                Text("CampusNavigator")
                    .font(.system(size: 23, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text("Smart campus companion & mobility")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            HStack(spacing: 8) {
                // Quick Theme Switcher Button (1-tap cycle Light/Dark/System)
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        themeManager.toggleNext()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 38, height: 38)
                        Image(systemName: themeManager.currentTheme.iconName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(themeManager.currentTheme == .dark ? .indigo : (themeManager.currentTheme == .light ? .orange : .blue))
                    }
                }
                
                // Saved Favorites Button
                NavigationLink {
                    FavoritesView()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 38, height: 38)
                        Image(systemName: "star.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.yellow)
                    }
                }

                // Profile & Settings Modal Button
                Button {
                    showingProfileSettings = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 38, height: 38)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Campus Live Status Ticker

    private var campusStatusTicker: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)

            Text("Buggy shuttle running • Library open till 10 PM • Accounts Office open")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - CampusBuddy AI Banner

    private var campusBuddyAIBanner: some View {
        NavigationLink {
            CampusBuddyChatView()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("CampusBuddy AI Assistant")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        if geminiService.isKeyConfigured {
                            Text("GEMINI 1.5")
                                .font(.system(size: 8, weight: .heavy))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.15))
                                .foregroundStyle(.purple)
                                .clipShape(Capsule())
                        } else {
                            Text("AI ONLINE")
                                .font(.system(size: 8, weight: .heavy))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.15))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        }
                    }

                    Text(geminiService.isKeyConfigured ? "Powered by Google Gemini • Ask about rooms, fees, routes" : "Ask about fee clearance, room directions, bus/buggy timings...")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient(colors: [.blue.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Next Class Card (Smart Student Dashboard)

    private var currentClassCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color.green).frame(width: 7, height: 7)
                    Text("NOW HAPPENING")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.15))
                .clipShape(Capsule())

                Spacer()

                NavigationLink {
                    TimetableView()
                } label: {
                    Text("Full Timetable →")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
            }

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("CS401: Artificial Intelligence & Neural Nets")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("09:00 AM – 10:30 AM • Dr. Ananya Roy")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                        Text("Block B • Room B-102 (AI Lab)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.top, 2)
                }

                Spacer()

                NavigationLink {
                    if let lab = samplePlaces.first(where: { $0.name.contains("Computer") }) {
                        CampusNavigationView(destination: lab)
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.title3)
                        Text("Navigate")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Smart Campus Services Grid

    private var campusServicesGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Campus Hub")
                .font(.headline)
                .fontWeight(.bold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                
                // Timetable
                NavigationLink {
                    TimetableView()
                } label: {
                    serviceIconCard(
                        icon: "calendar.badge.clock",
                        title: "Timetable",
                        badge: "87%",
                        color: .blue
                    )
                }

                // Events & Notice Board
                NavigationLink {
                    CampusEventsView()
                } label: {
                    serviceIconCard(
                        icon: "ticket.fill",
                        title: "Events & Fests",
                        badge: "New",
                        color: .purple
                    )
                }

                // QR Check-In
                NavigationLink {
                    QRScannerView()
                } label: {
                    serviceIconCard(
                        icon: "qrcode.viewfinder",
                        title: "QR Check-In",
                        badge: "Scan",
                        color: .cyan
                    )
                }

                // Lost & Found
                NavigationLink {
                    LostAndFoundView()
                } label: {
                    serviceIconCard(
                        icon: "bag.badge.questionmark",
                        title: "Lost & Found",
                        badge: nil,
                        color: .orange
                    )
                }

                // Campus Helpdesk
                NavigationLink {
                    CampusHelpdeskView()
                } label: {
                    serviceIconCard(
                        icon: "wrench.and.screwdriver.fill",
                        title: "Helpdesk",
                        badge: nil,
                        color: .red
                    )
                }

                // CampusBuddy AI
                NavigationLink {
                    CampusBuddyChatView()
                } label: {
                    serviceIconCard(
                        icon: "sparkles",
                        title: "AI Buddy",
                        badge: "AI",
                        color: .indigo
                    )
                }
            }
        }
    }

    private func serviceIconCard(icon: String, title: String, badge: String?, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 52, height: 52)

                if let b = badge {
                    Text(b)
                        .font(.system(size: 7, weight: .heavy))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(color)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -4)
                }
            }

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Active Buggy Ride Banner

    private func activeRideBanner(_ booking: BuggyBooking) -> some View {
        NavigationLink {
            BuggyTrackingView(booking: booking)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 50, height: 50)
                    Text("🛺")
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Active Buggy Ride")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text(booking.status.rawValue)
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                    }

                    Text("\(booking.pickup) → \(booking.destination)")
                        .font(.caption)
                        .opacity(0.9)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("Track")
                        .font(.caption)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
            }
            .foregroundStyle(.white)
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .blue.opacity(0.25), radius: 8, y: 4)
        }
    }

    // MARK: - Search Bar

    private var searchBarSection: some View {
        NavigationLink {
            NavigationSearchView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.subheadline)
                    .foregroundStyle(.blue)

                Text("Search Accounts Office, Cafeteria, Labs...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "mic.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
    }

    // MARK: - Quick Routes Section

    private var quickRoutesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Navigation")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink {
                    RoutePlannerView()
                } label: {
                    Text("Plan Custom Route →")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                // Route to Cafeteria
                NavigationLink {
                    if let dBlock = findBlock(named: "Block D") {
                        RoutePlannerView(
                            initialOrigin: .currentLocation,
                            initialDestination: CampusNavPoint.fromBlock(dBlock)
                        )
                    } else {
                        RoutePlannerView()
                    }
                } label: {
                    quickActionCard(
                        icon: "fork.knife",
                        color: .orange,
                        title: "To Cafeteria",
                        subtitle: "Food Court & Dining"
                    )
                }

                // Route to Accounts Office
                NavigationLink {
                    if let accountsPlace = samplePlaces.first(where: { $0.name.contains("Accounts") }) {
                        CampusNavigationView(destination: accountsPlace)
                    } else {
                        RoutePlannerView()
                    }
                } label: {
                    quickActionCard(
                        icon: "creditcard.fill",
                        color: .blue,
                        title: "Accounts Office",
                        subtitle: "Room A-002 • Fee Desk"
                    )
                }

                // Block to Block Router
                NavigationLink {
                    RoutePlannerView()
                } label: {
                    quickActionCard(
                        icon: "arrow.triangle.swap",
                        color: .purple,
                        title: "Block to Block",
                        subtitle: "Walking path"
                    )
                }

                // Book Buggy
                NavigationLink {
                    BuggyBookingView()
                } label: {
                    quickActionCard(
                        icon: "car.fill",
                        color: .indigo,
                        title: "Book Buggy",
                        subtitle: "Campus EV Shuttle"
                    )
                }
            }
        }
    }

    private func quickActionCard(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Campus Blocks Section

    private var campusBlocksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Campus Blocks & Directories")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Tap to view floor plans & room numbers")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                NavigationLink {
                    NavigationSearchView()
                } label: {
                    Text("All Blocks")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(allCampusBlocks) { block in
                        NavigationLink {
                            BlockDetailView(block: block)
                        } label: {
                            blockCarouselCard(block)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func blockCarouselCard(_ block: CampusBlock) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(block.color.gradient)
                        .frame(width: 38, height: 38)
                    Image(systemName: block.iconName)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }

                Spacer()

                Text("\(block.floors) Floors")
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(block.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text(block.title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            HStack {
                Text("\(block.rooms.count) Offices & Labs")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(block.color)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .frame(width: 175, height: 160)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 5, y: 2)
    }

    // MARK: - Map Preview Section

    private var mapPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Interactive Campus Map")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Full view with real-time GPS positioning")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                NavigationLink {
                    MapView()
                } label: {
                    HStack(spacing: 3) {
                        Text("Full Map")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                }
            }

            ZStack(alignment: .topTrailing) {
                UIKitMapView()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .allowsHitTesting(false)

                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                    Text("Chandigarh Campus")
                }
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .padding(10)
            }
        }
    }

    // MARK: - Popular Destinations Section

    private var popularDestinationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Key Locations")
                .font(.headline)
                .fontWeight(.bold)

            VStack(spacing: 10) {
                ForEach(samplePlaces.prefix(5)) { place in
                    NavigationLink {
                        CampusNavigationView(destination: place)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorFor(place.type).opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: iconFor(place.type))
                                    .font(.subheadline)
                                    .foregroundStyle(colorFor(place.type))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(place.name)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)

                                    if let room = place.roomNumber {
                                        Text(room)
                                            .font(.system(size: 9, weight: .bold))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.12))
                                            .foregroundStyle(.blue)
                                            .clipShape(Capsule())
                                    }
                                }

                                Text("\(place.building) • Floor \(place.floor)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Icon Helpers

    private func iconFor(_ type: String) -> String {
        switch type {
        case "Library": return "books.vertical.fill"
        case "Laboratory": return "desktopcomputer"
        case "Auditorium": return "theatermasks.fill"
        case "Food": return "fork.knife"
        case "Offices & Admin": return "briefcase.fill"
        case "Medical & Health": return "cross.case.fill"
        default: return "mappin.circle.fill"
        }
    }

    private func colorFor(_ type: String) -> Color {
        switch type {
        case "Library": return .teal
        case "Laboratory": return .purple
        case "Auditorium": return .red
        case "Food": return .orange
        case "Offices & Admin": return .blue
        case "Medical & Health": return .pink
        default: return .blue
        }
    }
}

#Preview {
    HomeView()
}
