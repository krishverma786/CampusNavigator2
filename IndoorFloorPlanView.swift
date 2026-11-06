import SwiftUI

struct IndoorFloorPlanView: View {
    
    let block: CampusBlock
    @State private var selectedFloor: Int
    @State private var selectedRoom: CampusRoom?
    var targetRoomNumber: String? = nil
    var onSelectRoomForNavigation: ((CampusRoom) -> Void)? = nil
    
    init(
        block: CampusBlock,
        initialFloor: Int = 0,
        targetRoomNumber: String? = nil,
        onSelectRoomForNavigation: ((CampusRoom) -> Void)? = nil
    ) {
        self.block = block
        _selectedFloor = State(initialValue: initialFloor)
        self.targetRoomNumber = targetRoomNumber
        self.onSelectRoomForNavigation = onSelectRoomForNavigation
    }
    
    private var roomsOnCurrentFloor: [CampusRoom] {
        block.roomsOnFloor(selectedFloor)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            // Floor Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<block.floors, id: \.self) { fl in
                        Button {
                            withAnimation(.spring(response: 0.35)) {
                                selectedFloor = fl
                                selectedRoom = nil
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: fl == 0 ? "door.left.hand.open" : "stairs")
                                    .font(.caption2)
                                Text(floorTitle(fl))
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedFloor == fl ? Color.blue : Color(.tertiarySystemBackground))
                            .foregroundStyle(selectedFloor == fl ? .white : .primary)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            
            // Vector Architectural Canvas
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                
                VStack(spacing: 8) {
                    // Top architectural wing
                    HStack(spacing: 6) {
                        ForEach(roomsForWing(top: true)) { room in
                            roomCell(room)
                        }
                    }
                    .frame(height: 72)
                    
                    // Central Hallway Corridor
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.08))
                            .frame(height: 34)
                        
                        HStack {
                            Label("Central Corridor", systemImage: "arrow.left.and.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 10) {
                                Label("Elevator", systemImage: "arrow.up.square.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.blue)
                                Label("Stairs", systemImage: "stairs")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.indigo)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    
                    // Bottom architectural wing
                    HStack(spacing: 6) {
                        ForEach(roomsForWing(top: false)) { room in
                            roomCell(room)
                        }
                    }
                    .frame(height: 72)
                }
                .padding(10)
            }
            .frame(height: 220)
            
            // Selected Room Details Pop-up / Drawer
            if let room = selectedRoom {
                roomDetailCard(room)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption2)
                    Text("Tap any room on the floor plan to view office hours & services")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(Color(.tertiarySystemBackground).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .onAppear {
            if let target = targetRoomNumber,
               let found = block.rooms.first(where: { $0.roomNumber == target }) {
                selectedFloor = found.floor
                selectedRoom = found
            }
        }
    }
    
    // MARK: - Room Cell
    
    private func roomCell(_ room: CampusRoom) -> some View {
        let isSelected = selectedRoom?.id == room.id
        let isTarget = targetRoomNumber == room.roomNumber
        
        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedRoom = room
            }
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? room.category.color.opacity(0.25) : Color(.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isTarget ? Color.red : (isSelected ? room.category.color : Color.primary.opacity(0.12)),
                                lineWidth: isTarget || isSelected ? 2.5 : 1
                            )
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(room.roomNumber)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(isTarget ? .red : room.category.color)
                        
                        Spacer()
                        
                        Image(systemName: room.category.iconName)
                            .font(.system(size: 8))
                            .foregroundStyle(room.category.color)
                    }
                    
                    Text(room.name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(6)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Room Detail Card
    
    private func roomDetailCard(_ room: CampusRoom) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(room.roomNumber)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(room.category.color.opacity(0.15))
                            .foregroundStyle(room.category.color)
                            .clipShape(Capsule())
                        
                        Text(room.floorName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(room.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        selectedRoom = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            // In-charge and timings
            HStack(spacing: 12) {
                Label(room.inCharge, systemImage: "person.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Label(room.timings, systemImage: "clock.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            // Key services tags
            if !room.services.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(room.services.prefix(3), id: \.self) { svc in
                            Text(svc)
                                .font(.system(size: 9, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 10) {
                if let action = onSelectRoomForNavigation {
                    Button {
                        action(room)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            Text("Navigate to this Room")
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    // MARK: - Helpers
    
    private func floorTitle(_ floor: Int) -> String {
        switch floor {
        case 0: return "Ground Floor"
        case 1: return "1st Floor"
        case 2: return "2nd Floor"
        case 3: return "3rd Floor"
        default: return "Floor \(floor)"
        }
    }
    
    private func roomsForWing(top: Bool) -> [CampusRoom] {
        let current = roomsOnCurrentFloor
        if current.isEmpty {
            // Generate fallback schematic layout rooms if none defined
            let prefix = "\(block.code)-\(selectedFloor)0"
            if top {
                return [
                    CampusRoom(id: "\(prefix)1", roomNumber: "Room \(prefix)1", name: "\(block.name) Office", block: block.name, floor: selectedFloor, category: .office, inCharge: "Faculty In-Charge", contactNumber: "+91 172-555-0100", email: "info@campus.edu", timings: "9 AM - 5 PM", services: ["Student Inquiries"], description: "Faculty & Staff Administrative Office"),
                    CampusRoom(id: "\(prefix)2", roomNumber: "Room \(prefix)2", name: "Lecture Hall \(selectedFloor)1", block: block.name, floor: selectedFloor, category: .academic, inCharge: "Academic Section", contactNumber: "+91 172-555-0101", email: "classes@campus.edu", timings: "8 AM - 6 PM", services: ["Smart Projector", "Mic System"], description: "Smart Multimedia Lecture Theater")
                ]
            } else {
                return [
                    CampusRoom(id: "\(prefix)3", roomNumber: "Room \(prefix)3", name: "Technical Lab \(selectedFloor)", block: block.name, floor: selectedFloor, category: .lab, inCharge: "Lab Superintendent", contactNumber: "+91 172-555-0102", email: "lab@campus.edu", timings: "9 AM - 5 PM", services: ["High-speed LAN", "Workstations"], description: "Specialized departmental laboratory"),
                    CampusRoom(id: "\(prefix)4", roomNumber: "Room \(prefix)4", name: "Seminar Room \(selectedFloor)", block: block.name, floor: selectedFloor, category: .auditorium, inCharge: "Event Coordinator", contactNumber: "+91 172-555-0103", email: "seminar@campus.edu", timings: "On Schedule", services: ["Video Conferencing"], description: "Discussion and presentation room")
                ]
            }
        }
        
        let half = max(1, current.count / 2)
        return top ? Array(current.prefix(half)) : Array(current.dropFirst(half))
    }
}
