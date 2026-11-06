import SwiftUI

struct ChatMessage: Identifiable {
    let id: UUID = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date = Date()
    let actionButtonTitle: String?
    let actionTarget: String?
    var source: String? = nil
}

struct CampusBuddyChatView: View {
    
    @ObservedObject private var geminiService = GeminiAPIService.shared
    
    @State private var inputText = ""
    @State private var isThinking = false
    @State private var showingSettingsSheet = false
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            text: "Hello! 👋 I'm CampusBuddy, your smart AI campus assistant powered by Gemini. Ask me about classrooms, the Accounts Office, library hours, buggy booking, or turn-by-turn routes!",
            isUser: false,
            actionButtonTitle: nil,
            actionTarget: nil,
            source: "CampusBuddy AI"
        )
    ]
    
    @State private var selectedNavPlace: CampusPlace? = nil
    @State private var showingNavigation = false
    @State private var showingBuggyBooking = false
    @State private var showingRoutePlanner = false
    
    private let quickPrompts = [
        "Where is Accounts Office?",
        "When does Library close?",
        "How to book an EV Buggy?",
        "Where is Cafeteria?",
        "Where is AI & Cloud Lab?",
        "Where is Health Center?"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Top AI Status Banner Strip
                aiStatusBar
                
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(messages) { msg in
                                chatBubble(msg)
                            }
                            
                            if isThinking {
                                thinkingBubble
                            }
                        }
                        .padding(16)
                    }
                    .onChange(of: messages.count) { _ in
                        if let last = messages.last {
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isThinking) { thinking in
                        if thinking {
                            withAnimation {
                                proxy.scrollTo("thinking_bubble", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Quick Suggestion Chips
                quickPromptsBar
                
                Divider()
                
                // Input Bar
                inputBar
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("CampusBuddy AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: geminiService.isKeyConfigured ? "sparkles" : "key.fill")
                                .font(.caption2)
                            Text(geminiService.isKeyConfigured ? geminiService.selectedModel.shortName : "Setup Key")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(geminiService.isKeyConfigured ? Color.purple.opacity(0.15) : Color.orange.opacity(0.15))
                        .foregroundStyle(geminiService.isKeyConfigured ? Color.purple : Color.orange)
                        .clipShape(Capsule())
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                GeminiSettingsSheet()
            }
            .sheet(isPresented: $showingBuggyBooking) {
                BuggyBookingView()
            }
            .sheet(isPresented: $showingRoutePlanner) {
                NavigationStack {
                    RoutePlannerView()
                }
            }
            .navigationDestination(isPresented: $showingNavigation) {
                if let place = selectedNavPlace {
                    CampusNavigationView(destination: place)
                }
            }
        }
    }
    
    // MARK: - AI Status Bar
    
    private var aiStatusBar: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(geminiService.isKeyConfigured ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            if geminiService.isKeyConfigured {
                Text("Gemini Live Intelligence Active (\(geminiService.selectedModel.shortName))")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            } else {
                Text("Offline Smart Engine Active • Tap 'Setup Key' for Gemini AI")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                showingSettingsSheet = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Quick Prompts Bar
    
    private var quickPromptsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickPrompts, id: \.self) { prompt in
                    Button {
                        sendUserMessage(prompt)
                    } label: {
                        Text(prompt)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color(.secondarySystemBackground))
                            .foregroundStyle(.primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
                            )
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
        }
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask about campus rooms, fees, routes...", text: $inputText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .submitLabel(.send)
                .onSubmit {
                    triggerSend()
                }
            
            Button {
                triggerSend()
            } label: {
                ZStack {
                    Circle()
                        .fill(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isThinking)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private func triggerSend() {
        let cleaned = inputText.trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty else { return }
        inputText = ""
        sendUserMessage(cleaned)
    }
    
    // MARK: - Chat Bubble
    
    private func chatBubble(_ msg: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if msg.isUser {
                Spacer()
            } else {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 28, height: 28)
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 2)
            }
            
            VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 6) {
                Text(msg.text)
                    .font(.subheadline)
                    .foregroundStyle(msg.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(msg.isUser ? Color.blue : Color(.secondarySystemBackground))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                
                // Action Navigation Button (if detected)
                if let action = msg.actionButtonTitle, let target = msg.actionTarget {
                    Button {
                        handleActionTarget(target)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: actionIcon(for: target))
                            Text(action)
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(actionColor(for: target))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .shadow(color: actionColor(for: target).opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                }
                
                // Source / Timestamp tag
                if !msg.isUser, let source = msg.source {
                    HStack(spacing: 4) {
                        Image(systemName: source.contains("Gemini") ? "sparkle" : "cpu")
                            .font(.system(size: 8))
                        Text(source)
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                }
            }
            .frame(maxWidth: 290, alignment: msg.isUser ? .trailing : .leading)
            
            if !msg.isUser {
                Spacer()
            }
        }
    }
    
    // MARK: - Thinking Bubble
    
    private var thinkingBubble: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 28, height: 28)
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 2)
            
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.8)
                Text(geminiService.isKeyConfigured ? "Gemini is analyzing campus data..." : "CampusBuddy is searching...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .id("thinking_bubble")
            
            Spacer()
        }
    }
    
    // MARK: - Logic & Actions
    
    private func sendUserMessage(_ text: String) {
        messages.append(ChatMessage(text: text, isUser: true, actionButtonTitle: nil, actionTarget: nil))
        isThinking = true
        
        let historyTuples = messages.map { (text: $0.text, isUser: $0.isUser) }
        
        Task {
            do {
                let response = try await geminiService.sendMessage(prompt: text, history: historyTuples)
                
                await MainActor.run {
                    isThinking = false
                    messages.append(
                        ChatMessage(
                            text: response.reply,
                            isUser: false,
                            actionButtonTitle: response.actionTitle,
                            actionTarget: response.actionTarget,
                            source: response.source
                        )
                    )
                }
            } catch {
                // Graceful fallback to the built-in intelligent engine
                let fallback = geminiService.generateFallbackResponse(for: text)
                await MainActor.run {
                    isThinking = false
                    messages.append(
                        ChatMessage(
                            text: fallback.reply,
                            isUser: false,
                            actionButtonTitle: fallback.actionTitle,
                            actionTarget: fallback.actionTarget,
                            source: "CampusBuddy Engine (Offline Safe)"
                        )
                    )
                }
            }
        }
    }
    
    private func handleActionTarget(_ target: String) {
        let t = target.lowercased()
        
        if t == "buggy" {
            showingBuggyBooking = true
        } else if t == "route" {
            showingRoutePlanner = true
        } else if t == "accounts" {
            if let p = samplePlaces.first(where: { $0.name.contains("Accounts") }) {
                selectedNavPlace = p
                showingNavigation = true
            }
        } else if t == "cafeteria" {
            if let p = samplePlaces.first(where: { $0.name.contains("Cafeteria") }) {
                selectedNavPlace = p
                showingNavigation = true
            }
        } else if t == "library" {
            if let p = samplePlaces.first(where: { $0.name.contains("Library") }) {
                selectedNavPlace = p
                showingNavigation = true
            }
        } else if t == "ai_lab" {
            if let p = samplePlaces.first(where: { $0.name.contains("Computer") || $0.name.contains("AI") }) {
                selectedNavPlace = p
                showingNavigation = true
            }
        } else if t == "auditorium" {
            if let p = samplePlaces.first(where: { $0.name.contains("Auditorium") }) {
                selectedNavPlace = p
                showingNavigation = true
            }
        } else if t == "health_center" {
            if let p = samplePlaces.first(where: { $0.name.contains("Health") }) {
                selectedNavPlace = p
                showingNavigation = true
            }
        } else {
            showingRoutePlanner = true
        }
    }
    
    private func actionIcon(for target: String) -> String {
        switch target.lowercased() {
        case "buggy": return "car.fill"
        case "route": return "arrow.triangle.swap"
        case "cafeteria": return "fork.knife"
        case "library": return "book.fill"
        case "ai_lab": return "desktopcomputer"
        case "health_center": return "cross.case.fill"
        default: return "location.fill"
        }
    }
    
    private func actionColor(for target: String) -> Color {
        switch target.lowercased() {
        case "buggy": return .green
        case "route": return .indigo
        case "cafeteria": return .orange
        case "library": return .purple
        case "health_center": return .red
        default: return .blue
        }
    }
}
