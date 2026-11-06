import SwiftUI

struct NavigationSearchView: View {
    
    @State private var searchText = ""
    @State private var selectedTabSegment = 0 // 0: Blocks & Facilities, 1: Rooms & Offices
    @State private var selectedCategory = "All"
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    private let categories = ["All", "Offices & Admin", "Food", "Library", "Laboratory", "Auditorium", "Medical & Health"]
    
    private var filteredBlocks: [CampusBlock] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return allCampusBlocks }
        return allCampusBlocks.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.description.localizedCaseInsensitiveContains(q) ||
            $0.rooms.contains(where: {
                $0.name.localizedCaseInsensitiveContains(q) ||
                $0.roomNumber.localizedCaseInsensitiveContains(q) ||
                $0.services.contains(where: { $0.localizedCaseInsensitiveContains(q) })
            })
        }
    }
    
    private var filteredPlaces: [CampusPlace] {
        var result = samplePlaces
        
        if selectedCategory != "All" {
            result = result.filter { $0.type.localizedCaseInsensitiveContains(selectedCategory) }
        }
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            result = result.filter { place in
                place.name.localizedCaseInsensitiveContains(trimmed) ||
                place.type.localizedCaseInsensitiveContains(trimmed) ||
                place.building.localizedCaseInsensitiveContains(trimmed) ||
                (place.roomNumber?.localizedCaseInsensitiveContains(trimmed) ?? false)
            }
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Segment Picker: Blocks vs All Rooms
                Picker("Directory View", selection: $selectedTabSegment) {
                    Text("Campus Blocks").tag(0)
                    Text("Offices & Rooms").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                if selectedTabSegment == 0 {
                    // MARK: - Blocks Directory
                    blocksList
                } else {
                    // MARK: - Rooms & Destinations List
                    roomsList
                }
            }
        }
        .navigationTitle("Campus Directory")
        .searchable(
            text: $searchText,
            prompt: "Search Accounts Office, Cafeteria, Block..."
        )
    }
    
    // MARK: - Blocks Directory
    
    private var blocksList: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 14) {
                ForEach(filteredBlocks) { block in
                    NavigationLink {
                        BlockDetailView(block: block)
                    } label: {
                        blockDirectoryCard(block)
                    }
                    .buttonStyle(.plain)
                }
                Color.clear.frame(height: 30)
            }
            .padding(16)
        }
    }
    
    private func blockDirectoryCard(_ block: CampusBlock) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(block.color.gradient)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: block.iconName)
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(block.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text(block.code)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(block.color.opacity(0.15))
                            .foregroundStyle(block.color)
                            .clipShape(Capsule())
                    }
                    
                    Text(block.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Divider()
            
            // Highlighted rooms in this block
            VStack(alignment: .leading, spacing: 4) {
                ForEach(block.rooms.prefix(2)) { room in
                    HStack(spacing: 6) {
                        Text(room.roomNumber)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(block.color)
                        Text(room.name)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            HStack {
                Text("\(block.floors) Floors • \(block.totalRooms) Listed Offices")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("View Floor Plan →")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(block.color)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: - Rooms List
    
    private var roomsList: some View {
        VStack(spacing: 0) {
            // Category Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = cat
                            }
                        } label: {
                            Text(cat)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(selectedCategory == cat ? Color.blue : Color(.secondarySystemBackground))
                                .foregroundStyle(selectedCategory == cat ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            List {
                Section {
                    ForEach(filteredPlaces) { place in
                        placeRow(place)
                    }
                } header: {
                    Text("\(filteredPlaces.count) destinations found")
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    private func placeRow(_ place: CampusPlace) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconFor(place.type))
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
            
            NavigationLink {
                CampusNavigationView(destination: place)
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(place.name)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        if let roomNum = place.roomNumber {
                            Text(roomNum)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("\(place.building) • Floor \(place.floor)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                favoritesManager.toggleFavorite(place)
            } label: {
                Image(systemName: favoritesManager.isFavorite(place) ? "star.fill" : "star")
                    .foregroundStyle(favoritesManager.isFavorite(place) ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
    
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
}
