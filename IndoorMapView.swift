import SwiftUI

struct IndoorMapView: View {
    
    let floor: Int
    var buildingName: String = "Block A"
    var targetRoom: String? = nil
    
    private var block: CampusBlock {
        findBlock(named: buildingName) ?? allCampusBlocks[0]
    }
    
    var body: some View {
        IndoorFloorPlanView(
            block: block,
            initialFloor: floor,
            targetRoomNumber: targetRoom
        )
    }
}

#Preview {
    IndoorMapView(floor: 0, buildingName: "Block A")
        .padding()
}
