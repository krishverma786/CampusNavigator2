import SwiftUI
import Combine

public enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .system: return "Matches iOS device appearance"
        case .light: return "Always crisp & clear light mode"
        case .dark: return "OLED battery-saving dark mode"
        }
    }
    
    public var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.stars.fill"
        }
    }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @Published public var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: "appTheme") ?? AppTheme.system.rawValue
        self.currentTheme = AppTheme(rawValue: saved) ?? .system
    }
    
    public var currentThemeRaw: String {
        get { currentTheme.rawValue }
        set {
            if let theme = AppTheme(rawValue: newValue) {
                currentTheme = theme
            }
        }
    }
    
    public func toggleNext() {
        switch currentTheme {
        case .system:
            currentTheme = .light
        case .light:
            currentTheme = .dark
        case .dark:
            currentTheme = .system
        }
    }
}
