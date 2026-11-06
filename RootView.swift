import SwiftUI

struct RootView: View {

    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @AppStorage("debug_initial_view") private var debugInitialView = ""
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        Group {
            if debugInitialView == "chat" {
                CampusBuddyChatView()
            } else if debugInitialView == "gemini_settings" {
                GeminiSettingsSheet()
            } else if debugInitialView == "profile" {
                ProfileSettingsSheet()
            } else if isLoggedIn {
                ContentView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .animation(.easeInOut(duration: 0.35), value: isLoggedIn)
    }
}

#Preview {
    RootView()
}
