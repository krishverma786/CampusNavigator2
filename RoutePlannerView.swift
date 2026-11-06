import SwiftUI
import MapKit

struct RoutePlannerView: View {
    
    @State private var originPoint: CampusNavPoint = .currentLocation
    @State private var destinationPoint: CampusNavPoint
    @State private var selectedMode: RouteMode = .walking
    @State private var isLiveNavigating = false
    @State private var currentStepIndex = 0
    @State private var showingOriginPicker = false
    @State private var showingDestPicker = false
    
    // Preset starting destination
    init(
        initialOrigin: CampusNavPoint = .currentLocation,
        initialDestination: CampusNavPoint? = nil
    ) {
        _originPoint = State(initialValue: initialOrigin)
        if let dest = initialDestination {
            _destinationPoint = State(initialValue: dest)
        } else {
            // Default to Cafeteria
            let cafPlace = samplePlaces.first(where: { $0.name.contains("Cafeteria") }) ?? samplePlaces[3]
            _destinationPoint = State(initialValue: CampusNavPoint.fromPlace(cafPlace))
        }
    }
    
    private var routeInfo: CampusRouteInfo {
        RoutingService.shared.generateRoute(
            from: originPoint,
            to: destinationPoint,
            mode: selectedMode
        )
    }
    
    private var mapRegion: MKCoordinateRegion {
        let p1 = originPoint.coordinate
        let p2 = destinationPoint.coordinate
        let center = CLLocationCoordinate2D(
            latitude: (p1.latitude + p2.latitude) / 2.0,
            longitude: (p1.longitude + p2.longitude) / 2.0
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.004, abs(p1.latitude - p2.latitude) * 1.6),
            longitudeDelta: max(0.004, abs(p1.longitude - p2.longitude) * 1.6)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 18) {
                    
                    // Route Selection Card (Origin + Destination + Swap)
                    routeSelectorCard
                    
                    // Quick Route Presets
                    presetsRow
                    
                    // Transport Mode Selector
                    modeSelector
                    
                    // Route Map Preview Card
                    routeMapCard
                    
                    // Key Metrics (Time, Distance, Calories, Mode)
                    metricsRow
                    
                    // Turn-by-Turn Steps or Active Navigation
                    turnByTurnSection
                    
                    Color.clear.frame(height: 40)
                }
                .padding(16)
            }
        }
        .navigationTitle("Route Planner")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingOriginPicker) {
            pointSelectionSheet(isOrigin: true)
        }
        .sheet(isPresented: $showingDestPicker) {
            pointSelectionSheet(isOrigin: false)
        }
    }
    
    // MARK: - Route Selector Card
    
    private var routeSelectorCard: some View {
        VStack(spacing: 12) {
            
            // Origin Row
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                
                Button {
                    showingOriginPicker = true
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("FROM")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text(originPoint.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Swap Button & Connector
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: 16)
                    .padding(.leading, 17)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.35)) {
                        let temp = originPoint
                        originPoint = destinationPoint
                        destinationPoint = temp
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
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.red)
                
                Button {
                    showingDestPicker = true
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TO")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text(destinationPoint.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: - Quick Presets
    
    private var presetsRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Popular Campus Routes")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    
                    // Block to Cafeteria
                    presetChip(
                        title: "Block B → Cafeteria",
                        icon: "fork.knife",
                        action: {
                            if let bBlock = findBlock(named: "Block B"),
                               let dBlock = findBlock(named: "Block D") {
                                originPoint = CampusNavPoint.fromBlock(bBlock)
                                destinationPoint = CampusNavPoint.fromBlock(dBlock)
                            }
                        }
                    )
                    
                    // Block to Block
                    presetChip(
                        title: "Block A → Block B",
                        icon: "arrow.right.arrow.left",
                        action: {
                            if let aBlock = findBlock(named: "Block A"),
                               let bBlock = findBlock(named: "Block B") {
                                originPoint = CampusNavPoint.fromBlock(aBlock)
                                destinationPoint = CampusNavPoint.fromBlock(bBlock)
                            }
                        }
                    )
                    
                    // Accounts Office
                    presetChip(
                        title: "Gate 1 → Accounts Office",
                        icon: "creditcard.fill",
                        action: {
                            if let gate = findBlock(named: "Main Gate"),
                               let accounts = allRooms().first(where: { $0.id == "A-002" }) {
                                originPoint = CampusNavPoint.fromBlock(gate)
                                destinationPoint = CampusNavPoint.fromRoom(accounts)
                            }
                        }
                    )
                    
                    // Hostel to Library
                    presetChip(
                        title: "Hostel → Central Library",
                        icon: "books.vertical.fill",
                        action: {
                            if let host = findBlock(named: "Hostel Zone"),
                               let lib = samplePlaces.first(where: { $0.name.contains("Library") }) {
                                originPoint = CampusNavPoint.fromBlock(host)
                                destinationPoint = CampusNavPoint.fromPlace(lib)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private func presetChip(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Mode Selector
    
    private var modeSelector: some View {
        HStack(spacing: 8) {
            ForEach(RouteMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedMode = mode
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.iconName)
                        Text(mode.rawValue)
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedMode == mode ? Color.blue : Color(.secondarySystemBackground))
                    .foregroundStyle(selectedMode == mode ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Route Map Card
    
    private var routeMapCard: some View {
        ZStack(alignment: .topTrailing) {
            Map(initialPosition: .region(mapRegion)) {
                // Origin Pin
                Annotation(originPoint.name, coordinate: originPoint.coordinate) {
                    ZStack {
                        Circle().fill(Color.green.opacity(0.2)).frame(width: 36, height: 36)
                        Circle().fill(Color.green).frame(width: 14, height: 14)
                        Circle().stroke(Color.white, lineWidth: 2).frame(width: 14, height: 14)
                    }
                }
                
                // Destination Pin
                Annotation(destinationPoint.name, coordinate: destinationPoint.coordinate) {
                    VStack(spacing: 2) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                        Text(destinationPoint.name)
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.regularMaterial)
                            .clipShape(Capsule())
                    }
                }
                
                // Polyline Connecting Start and End
                MapPolyline(coordinates: routeInfo.coordinates)
                    .stroke(selectedMode == .buggy ? Color.indigo : Color.blue, lineWidth: 5)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .allowsHitTesting(false)
            
            // Badge
            Text(selectedMode.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.regularMaterial)
                .clipShape(Capsule())
                .padding(10)
        }
    }
    
    // MARK: - Metrics Row
    
    private var metricsRow: some View {
        HStack(spacing: 10) {
            metricBox(
                icon: selectedMode.iconName,
                value: "\(routeInfo.walkingTimeMinutes) min",
                title: selectedMode == .buggy ? "Buggy Ride" : "Estimated Time"
            )
            
            metricBox(
                icon: "arrow.triangle.turn.up.right.diamond.fill",
                value: "\(routeInfo.distanceMeters) m",
                title: "Total Distance"
            )
            
            metricBox(
                icon: "flame.fill",
                value: "\(routeInfo.caloriesEstimate) kcal",
                title: "Calorie Burn"
            )
        }
    }
    
    private func metricBox(icon: String, value: String, title: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    // MARK: - Turn-by-Turn Steps
    
    private var turnByTurnSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack {
                Text(isLiveNavigating ? "Live Guidance Active" : "Turn-by-Turn Directions")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    withAnimation {
                        isLiveNavigating.toggle()
                        if isLiveNavigating {
                            currentStepIndex = 0
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isLiveNavigating ? "stop.fill" : "location.fill")
                        Text(isLiveNavigating ? "End Nav" : "Start Navigation")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(isLiveNavigating ? Color.red : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                }
            }
            
            if isLiveNavigating {
                // Active Live Step Prominent Box
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Step \(currentStepIndex + 1) of \(routeInfo.steps.count)", systemImage: "figure.walk.motion")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        Spacer()
                        Text("\(routeInfo.steps[currentStepIndex].distanceMeters) m")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.12))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: routeInfo.steps[currentStepIndex].iconName)
                            .font(.title)
                            .foregroundStyle(.blue)
                            .frame(width: 44)
                        
                        Text(routeInfo.steps[currentStepIndex].instruction)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    // Step controls
                    HStack {
                        Button {
                            if currentStepIndex > 0 {
                                withAnimation { currentStepIndex -= 1 }
                            }
                        } label: {
                            Text("Previous")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .disabled(currentStepIndex == 0)
                        
                        Spacer()
                        
                        Button {
                            if currentStepIndex < routeInfo.steps.count - 1 {
                                withAnimation { currentStepIndex += 1 }
                            } else {
                                withAnimation { isLiveNavigating = false }
                            }
                        } label: {
                            Text(currentStepIndex == routeInfo.steps.count - 1 ? "Arrived!" : "Next Step →")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18).stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                )
            }
            
            // Full Step List
            VStack(spacing: 10) {
                ForEach(routeInfo.steps) { step in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isLiveNavigating && step.stepNumber == currentStepIndex + 1 ? Color.blue : Color(.tertiarySystemBackground))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: step.iconName)
                                .font(.caption)
                                .foregroundStyle(isLiveNavigating && step.stepNumber == currentStepIndex + 1 ? .white : .blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(step.instruction)
                                .font(.subheadline)
                                .fontWeight(isLiveNavigating && step.stepNumber == currentStepIndex + 1 ? .bold : .regular)
                                .foregroundStyle(.primary)
                            
                            Text("\(step.distanceMeters) meters")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
    
    // MARK: - Point Selection Sheet
    
    private func pointSelectionSheet(isOrigin: Bool) -> some View {
        NavigationStack {
            List {
                if isOrigin {
                    Section("Quick Location") {
                        Button {
                            originPoint = .currentLocation
                            showingOriginPicker = false
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.blue)
                                Text("My Current GPS Location")
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                Section("Campus Blocks & Entrances") {
                    ForEach(allCampusBlocks) { block in
                        Button {
                            let p = CampusNavPoint.fromBlock(block)
                            if isOrigin { originPoint = p } else { destinationPoint = p }
                            showingOriginPicker = false
                            showingDestPicker = false
                        } label: {
                            HStack {
                                Image(systemName: block.iconName)
                                    .foregroundStyle(block.color)
                                    .frame(width: 24)
                                VStack(alignment: .leading) {
                                    Text(block.name)
                                        .fontWeight(.semibold)
                                    Text(block.title)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Section("Key Offices & Destinations") {
                    ForEach(samplePlaces) { place in
                        Button {
                            let p = CampusNavPoint.fromPlace(place)
                            if isOrigin { originPoint = p } else { destinationPoint = p }
                            showingOriginPicker = false
                            showingDestPicker = false
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .frame(width: 24)
                                VStack(alignment: .leading) {
                                    Text(place.name)
                                        .fontWeight(.semibold)
                                    Text("\(place.building) • Floor \(place.floor)\(place.roomNumber != nil ? " • \(place.roomNumber!)" : "")")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(isOrigin ? "Select Starting Point" : "Select Destination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        showingOriginPicker = false
                        showingDestPicker = false
                    }
                }
            }
        }
    }
}
