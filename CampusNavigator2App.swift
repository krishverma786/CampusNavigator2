import SwiftUI

@main
struct CampusNavigatorApp: App {
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
    }
}
