import SwiftUI

enum HelpdeskCategory: String, CaseIterable, Identifiable {
    case it = "IT, Projectors & Wi-Fi"
    case infra = "Air Conditioning & Lighting"
    case cleanliness = "Cleanliness & Sanitation"
    case buggy = "Buggy Service Issue"
    case admin = "Academic / Fee Desk"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .it: return "wifi.exclamationmark"
        case .infra: return "fan.fill"
        case .cleanliness: return "sparkles"
        case .buggy: return "car.fill"
        case .admin: return "person.badge.shield.checkmark.fill"
        }
    }
}

enum TicketStatus: String {
    case submitted = "Submitted"
    case inProgress = "Tech Team Assigned"
    case resolved = "Resolved"
    
    var color: Color {
        switch self {
        case .submitted: return .orange
        case .inProgress: return .blue
        case .resolved: return .green
        }
    }
}

struct HelpdeskTicket: Identifiable {
    let id: String
    let subject: String
    let category: HelpdeskCategory
    let location: String
    let description: String
    let dateSubmitted: String
    var status: TicketStatus
    let resolutionNote: String?
}

struct CampusHelpdeskView: View {
    
    @State private var tickets: [HelpdeskTicket] = [
        HelpdeskTicket(
            id: "TKT-8421",
            subject: "Lab B-102 HDMI Projector Flickering",
            category: .it,
            location: "Block B, AI Lab (Room B-102)",
            description: "Center display projector disconnects during slide presentations.",
            dateSubmitted: "Today, 09:15 AM",
            status: .inProgress,
            resolutionNote: "Technician Mr. Rajesh dispatched to replace HDMI cable."
        ),
        HelpdeskTicket(
            id: "TKT-7910",
            subject: "Library 2nd Floor High-Speed Wi-Fi Reconnection",
            category: .it,
            location: "Central Library Floor 2",
            description: "SSID CU-Student-5G drops connection intermittently.",
            dateSubmitted: "Yesterday",
            status: .resolved,
            resolutionNote: "Access Point firmware rebooted and re-calibrated."
        ),
        HelpdeskTicket(
            id: "TKT-6502",
            subject: "Water Dispenser Sensor Malfunction",
            category: .cleanliness,
            location: "Block A, 1st Floor Foyer",
            description: "Cold water dispenser sensor not triggering automatic pour.",
            dateSubmitted: "Oct 29",
            status: .resolved,
            resolutionNote: "Optical sensor cleaned and tested operational."
        )
    ]
    
    @State private var showingNewTicketSheet = false
    @State private var newSubject = ""
    @State private var newCategory: HelpdeskCategory = .it
    @State private var newLocation = ""
    @State private var newDescription = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 18) {
                
                // Top Banner with "File Ticket" Action
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Campus Helpdesk & Repairs")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Report classroom equipment issues or campus maintenance.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingNewTicketSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("New Ticket")
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                // Tickets List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Support Tickets")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(tickets) { ticket in
                        ticketCard(ticket)
                    }
                }
                
                Color.clear.frame(height: 30)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Feedback & Helpdesk")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNewTicketSheet) {
            newTicketSheet
        }
    }
    
    private func ticketCard(_ ticket: HelpdeskTicket) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(ticket.id)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text(ticket.status.rawValue)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(ticket.status.color.opacity(0.15))
                    .foregroundStyle(ticket.status.color)
                    .clipShape(Capsule())
            }
            
            Text(ticket.subject)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            HStack(spacing: 8) {
                Label(ticket.location, systemImage: "mappin.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(ticket.dateSubmitted)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if let note = ticket.resolutionNote {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.blue)
                        .padding(.top, 2)
                    Text(note)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var newTicketSheet: some View {
        NavigationStack {
            Form {
                Section("Issue Information") {
                    TextField("Subject (e.g. Broken Mic in Room B-201)", text: $newSubject)
                    Picker("Category", selection: $newCategory) {
                        ForEach(HelpdeskCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    TextField("Room / Location (e.g. Block B, 2nd Floor)", text: $newLocation)
                }
                
                Section("Detailed Description") {
                    TextEditor(text: $newDescription)
                        .frame(height: 90)
                }
                
                Section {
                    Button("Submit Ticket") {
                        if !newSubject.isEmpty {
                            let ticket = HelpdeskTicket(
                                id: "TKT-\(Int.random(in: 1000...9999))",
                                subject: newSubject,
                                category: newCategory,
                                location: newLocation.isEmpty ? "Campus Block" : newLocation,
                                description: newDescription,
                                dateSubmitted: "Just now",
                                status: .submitted,
                                resolutionNote: "Ticket logged. Assigned to University Engineering Services."
                            )
                            tickets.insert(ticket, at: 0)
                            newSubject = ""
                            newLocation = ""
                            newDescription = ""
                            showingNewTicketSheet = false
                        }
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("New Maintenance Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingNewTicketSheet = false
                    }
                }
            }
        }
    }
}
