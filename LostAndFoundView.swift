import SwiftUI

struct LostAndFoundView: View {
    
    @State private var items: [LostFoundItem] = sampleLostItems
    @State private var selectedCategory: LostItemCategory = .all
    @State private var showingReportSheet = false
    @State private var reportedSuccess = false
    
    // New Report Fields
    @State private var newTitle = ""
    @State private var newCategory: LostItemCategory = .electronics
    @State private var newLocation = ""
    @State private var newPhone = ""
    
    private var filteredItems: [LostFoundItem] {
        if selectedCategory == .all {
            return items
        }
        return items.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 18) {
                
                // Top Banner with "Report Lost Item" Button
                headerBanner
                
                // Categories
                categoryFilter
                
                // Items List
                VStack(spacing: 12) {
                    ForEach(filteredItems) { item in
                        itemCard(item)
                    }
                }
                
                Color.clear.frame(height: 30)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Lost & Found Hub")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingReportSheet = true
                } label: {
                    Label("Report Item", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
        }
        .sheet(isPresented: $showingReportSheet) {
            reportItemSheet
        }
    }
    
    // MARK: - Header Banner
    
    private var headerBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lost Something on Campus?")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Check real-time recovered items or file a student lost report.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                showingReportSheet = true
            } label: {
                Text("Report")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LostItemCategory.allCases) { cat in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = cat
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: cat.iconName)
                            Text(cat.rawValue)
                        }
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
        }
    }
    
    // MARK: - Item Card
    
    private func itemCard(_ item: LostFoundItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.color.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: item.iconName)
                        .font(.title3)
                        .foregroundStyle(item.color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(item.status.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(item.status == .claimed ? Color.gray.opacity(0.2) : Color.green.opacity(0.15))
                            .foregroundStyle(item.status == .claimed ? Color.secondary : Color.green)
                            .clipShape(Capsule())
                        
                        Text(item.dateReported)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                        Text(item.locationFound)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text("Handed to: \(item.contactPerson)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if item.status != .claimed {
                    Button {
                        // Phone call simulation
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                            Text("Claim")
                        }
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Report Item Sheet
    
    private var reportItemSheet: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("What was lost? (e.g. Black HP Laptop Bag)", text: $newTitle)
                    Picker("Category", selection: $newCategory) {
                        ForEach(LostItemCategory.allCases.filter { $0 != .all }) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }
                
                Section("Where was it lost/found?") {
                    TextField("Location (e.g. Block B, 2nd Floor Corridor)", text: $newLocation)
                    TextField("Your Contact Phone Number", text: $newPhone)
                }
                
                Section {
                    Button("Submit Report") {
                        if !newTitle.isEmpty {
                            let newItem = LostFoundItem(
                                title: newTitle,
                                category: newCategory,
                                locationFound: newLocation.isEmpty ? "Campus Grounds" : newLocation,
                                dateReported: "Just now",
                                contactPerson: "Student Reporter",
                                contactPhone: newPhone.isEmpty ? "+91 98765-00000" : newPhone,
                                status: .lost,
                                iconName: newCategory.iconName,
                                color: .purple
                            )
                            items.insert(newItem, at: 0)
                            newTitle = ""
                            newLocation = ""
                            newPhone = ""
                            showingReportSheet = false
                        }
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Report Belonging")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingReportSheet = false
                    }
                }
            }
        }
    }
}
