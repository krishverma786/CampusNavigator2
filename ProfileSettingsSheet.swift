import SwiftUI

struct ProfileSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var geminiService = GeminiAPIService.shared
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var buggyManager = BuggyManager.shared
    
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @AppStorage("currentUserName") private var currentUserName = "Ayush Rana"
    
    @State private var showingGeminiSettings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                
                // MARK: - Student Identity Card
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 64, height: 64)
                            
                            Text(currentUserName.prefix(2).uppercased())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentUserName.isEmpty ? "Student Member" : currentUserName)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("B.Tech • Computer Science & Engg.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 8) {
                                Text("ID: CU-2024-8842")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                                
                                Text("Semester 6")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.12))
                                    .foregroundStyle(.green)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                // MARK: - Appearance & Theme Switching
                Section(
                    header: Text("Appearance & Theme"),
                    footer: Text("Choose between automatic system appearance, crisp daylight mode, or OLED battery-friendly dark mode.")
                ) {
                    Picker("Appearance", selection: $themeManager.currentThemeRaw) {
                        ForEach(AppTheme.allCases) { theme in
                            HStack {
                                Image(systemName: theme.iconName)
                                Text(theme.title)
                            }
                            .tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                    
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Active Theme")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(themeManager.currentTheme.subtitle)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: themeManager.currentTheme.iconName)
                                .foregroundStyle(themeManager.currentTheme == .dark ? .indigo : (themeManager.currentTheme == .light ? .orange : .blue))
                        }
                        
                        Spacer()
                        
                        Text(themeManager.currentTheme.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                }
                
                // MARK: - Gemini AI Chatbot Settings
                Section(
                    header: Text("AI Campus Assistant"),
                    footer: Text("Powered by Google Gemini 1.5 Flash for natural multi-turn campus navigation, fee inquiries, and hours lookup.")
                ) {
                    Button {
                        showingGeminiSettings = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "sparkles")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gemini AI API Configuration")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                
                                if geminiService.isKeyConfigured {
                                    Text("\(geminiService.selectedModel.shortName) • Connected")
                                        .font(.caption2)
                                        .foregroundStyle(.green)
                                } else {
                                    Text("Using Built-in Smart Engine • Tap to add API Key")
                                        .font(.caption2)
                                        .foregroundStyle(.orange)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // MARK: - Campus Activity Stats
                Section(header: Text("Campus Activity")) {
                    HStack {
                        Label("Saved Favorite Places", systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                        Spacer()
                        Text("\(favoritesManager.favoritePlaces.count)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Buggy Rides Booked", systemImage: "car.fill")
                            .foregroundStyle(.blue)
                        Spacer()
                        Text("\(buggyManager.bookings.count)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Attendance Record", systemImage: "chart.bar.fill")
                            .foregroundStyle(.green)
                        Spacer()
                        Text("87% (Good)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                }
                
                // MARK: - App Version & About
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.4.0 (Enterprise)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Campus Data Engine")
                        Spacer()
                        Text("Offline Capable + Gemini 1.5")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - Sign Out Button
                Section {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingGeminiSettings) {
                GeminiSettingsSheet()
            }
            .confirmationDialog(
                "Are you sure you want to sign out?",
                isPresented: $showingLogoutAlert,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    isLoggedIn = false
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
