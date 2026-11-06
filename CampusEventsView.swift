import SwiftUI

struct CampusEventsView: View {
    
    @State private var events: [CampusEvent] = sampleCampusEvents
    @State private var selectedCategory: EventCategory = .all
    @State private var registeredAlertEvent: CampusEvent? = nil
    @State private var selectedNavPlace: CampusPlace? = nil
    @State private var showingNavigation = false
    
    private var filteredEvents: [CampusEvent] {
        if selectedCategory == .all {
            return events
        }
        return events.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 18) {
                
                // Category Filter
                categoryFilterBar
                
                // Events Cards
                VStack(spacing: 16) {
                    ForEach(filteredEvents) { event in
                        eventCard(event)
                    }
                }
                
                Color.clear.frame(height: 30)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Events & Notice Board")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $registeredAlertEvent) { event in
            Alert(
                title: Text("Registration Confirmed! 🎉"),
                message: Text("You have successfully registered for \(event.title). See you at \(event.venue)!"),
                dismissButton: .default(Text("Awesome"))
            )
        }
        .navigationDestination(isPresented: $showingNavigation) {
            if let place = selectedNavPlace {
                CampusNavigationView(destination: place)
            }
        }
    }
    
    // MARK: - Category Filter Bar
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EventCategory.allCases) { cat in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = cat
                        }
                    } label: {
                        Text(cat.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedCategory == cat ? Color.blue : Color(.secondarySystemBackground))
                            .foregroundStyle(selectedCategory == cat ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - Event Card
    
    private func eventCard(_ event: CampusEvent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(event.bannerColor.gradient)
                        .frame(width: 50, height: 50)
                    Image(systemName: event.iconName)
                        .font(.title3)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(event.category.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(event.bannerColor.opacity(0.15))
                            .foregroundStyle(event.bannerColor)
                            .clipShape(Capsule())
                        
                        if let prize = event.prizePool {
                            Text(prize)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
            }
            
            Text(event.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            Divider()
            
            // Venue & Date Info
            VStack(spacing: 6) {
                HStack {
                    Label(event.dateRange, systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Label(event.timeString, systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label(event.venue, systemImage: "mappin.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(event.feeString)
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundStyle(.green)
                }
            }
            
            // Action Buttons
            HStack(spacing: 10) {
                Button {
                    if let idx = events.firstIndex(where: { $0.id == event.id }) {
                        events[idx].isRegistered.toggle()
                        if events[idx].isRegistered {
                            registeredAlertEvent = events[idx]
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: event.isRegistered ? "checkmark.circle.fill" : "ticket.fill")
                        Text(event.isRegistered ? "Registered" : "Register Now")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(event.isRegistered ? Color.green : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    selectedNavPlace = CampusPlace(
                        name: event.title,
                        type: "Event Venue",
                        building: event.block,
                        floor: 0,
                        latitude: 30.7677,
                        longitude: 76.5748
                    )
                    showingNavigation = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                        Text("Venue")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
