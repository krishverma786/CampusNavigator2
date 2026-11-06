import SwiftUI

struct BlockDetailView: View {
    
    let block: CampusBlock
    @State private var selectedFilter: RoomCategory? = nil
    @State private var searchText = ""
    @State private var selectedRoomForSheet: CampusRoom?
    @State private var showingNavigation = false
    @State private var selectedDestinationPlace: CampusPlace?
    
    private var filteredRooms: [CampusRoom] {
        var list = block.rooms
        if let cat = selectedFilter {
            list = list.filter { $0.category == cat }
        }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(q) ||
                $0.roomNumber.localizedCaseInsensitiveContains(q) ||
                $0.services.contains(where: { $0.localizedCaseInsensitiveContains(q) }) ||
                $0.inCharge.localizedCaseInsensitiveContains(q)
            }
        }
        return list
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 20) {
                
                // Block Hero Header
                blockHeroHeader
                
                // Facilities Chips
                facilitiesSection
                
                // Interactive Floor Plan Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Interactive Floor Plan", systemImage: "map.fill")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(block.floors) Floors")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    IndoorFloorPlanView(
                        block: block,
                        initialFloor: 0,
                        onSelectRoomForNavigation: { room in
                            selectedRoomForSheet = room
                        }
                    )
                }
                
                // Room & Office Directory
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Offices & Rooms Directory")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("\(filteredRooms.count) locations in \(block.name)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Category Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button {
                                selectedFilter = nil
                            } label: {
                                Text("All Rooms")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(selectedFilter == nil ? Color.blue : Color(.tertiarySystemBackground))
                                    .foregroundStyle(selectedFilter == nil ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            
                            ForEach(RoomCategory.allCases) { cat in
                                if block.rooms.contains(where: { $0.category == cat }) {
                                    Button {
                                        selectedFilter = cat
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: cat.iconName)
                                            Text(cat.rawValue)
                                        }
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(selectedFilter == cat ? cat.color : Color(.tertiarySystemBackground))
                                        .foregroundStyle(selectedFilter == cat ? .white : .primary)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    
                    // Room List Rows
                    VStack(spacing: 12) {
                        ForEach(filteredRooms) { room in
                            roomRowCard(room)
                        }
                    }
                }
                
                Color.clear.frame(height: 30)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(block.name)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search rooms (e.g. Accounts, Lab, 002)...")
        .sheet(item: $selectedRoomForSheet) { room in
            roomDetailSheet(room)
        }
        .navigationDestination(isPresented: $showingNavigation) {
            if let dest = selectedDestinationPlace {
                CampusNavigationView(destination: dest)
            }
        }
    }
    
    // MARK: - Block Hero Header
    
    private var blockHeroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(block.color.gradient)
                        .frame(width: 58, height: 58)
                    
                    Image(systemName: block.iconName)
                        .font(.title)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(block.name)
                            .font(.title2)
                            .fontWeight(.heavy)
                        
                        Text(block.code)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(block.color.opacity(0.15))
                            .foregroundStyle(block.color)
                            .clipShape(Capsule())
                    }
                    
                    Text(block.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            Text(block.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Facilities
    
    private var facilitiesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(block.facilities, id: \.self) { fac in
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                        Text(fac)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    // MARK: - Room Row Card
    
    private func roomRowCard(_ room: CampusRoom) -> some View {
        Button {
            selectedRoomForSheet = room
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(room.category.color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: room.category.iconName)
                        .font(.title3)
                        .foregroundStyle(room.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(room.roomNumber)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(room.category.color)
                        
                        Text("•  \(room.floorName)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    
                    Text(room.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(room.inCharge)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if let firstService = room.services.first {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.blue)
                            Text(firstService)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.top, 2)
                    }
                }
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Room Detail Sheet
    
    private func roomDetailSheet(_ room: CampusRoom) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Room Top Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(room.category.color.opacity(0.15))
                                .frame(width: 54, height: 54)
                            Image(systemName: room.category.iconName)
                                .font(.title2)
                                .foregroundStyle(room.category.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(room.roomNumber)
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(room.category.color.opacity(0.15))
                                    .foregroundStyle(room.category.color)
                                    .clipShape(Capsule())
                                
                                Text(room.block)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(room.name)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Info Grid
                    VStack(spacing: 12) {
                        detailRow(title: "In-Charge", value: room.inCharge, icon: "person.fill")
                        detailRow(title: "Office Timings", value: room.timings, icon: "clock.fill")
                        detailRow(title: "Contact", value: room.contactNumber, icon: "phone.fill")
                        detailRow(title: "Email", value: room.email, icon: "envelope.fill")
                        detailRow(title: "Location", value: "\(room.floorName), \(room.block)", icon: "mappin.and.ellipse")
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Services & Facilities Provided
                    if !room.services.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Services & Clearance Provided")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(room.services, id: \.self) { svc in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                            .font(.caption)
                                            .padding(.top, 2)
                                        Text(svc)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("About this Location")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(room.description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 10) {
                        Button {
                            selectedRoomForSheet = nil
                            selectedDestinationPlace = CampusPlace(
                                name: room.name,
                                type: room.category.rawValue,
                                building: room.block,
                                floor: room.floor,
                                latitude: block.latitude,
                                longitude: block.longitude,
                                roomNumber: room.roomNumber,
                                blockId: block.id
                            )
                            showingNavigation = true
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Navigate to \(room.roomNumber)")
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Room Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        selectedRoomForSheet = nil
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
    }
}
