import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - 0: Home
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // MARK: - 1: Map
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(1)
            
            // MARK: - 2: Directory & Blocks
            NavigationStack {
                NavigationSearchView()
            }
            .tabItem {
                Label("Directory", systemImage: "building.2.fill")
            }
            .tag(2)
            
            // MARK: - 3: Route Planner (Point-to-Point)
            NavigationStack {
                RoutePlannerView()
            }
            .tabItem {
                Label("Route", systemImage: "arrow.triangle.swap")
            }
            .tag(3)
            
            // MARK: - 4: Buggy & My Rides
            BuggyBookingView()
                .tabItem {
                    Label("Buggy", systemImage: "car.fill")
                }
                .tag(4)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
