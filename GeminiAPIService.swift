import Foundation
import SwiftUI
import Combine

// MARK: - Gemini Models

public enum GeminiModel: String, CaseIterable, Identifiable {
    case flash15 = "gemini-1.5-flash"
    case flash20 = "gemini-2.0-flash"
    case pro15   = "gemini-1.5-pro"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .flash15: return "Gemini 1.5 Flash (Recommended - Fast & Lightweight)"
        case .flash20: return "Gemini 2.0 Flash (Next-Gen High Speed)"
        case .pro15:   return "Gemini 1.5 Pro (Deep Reasoning & Analysis)"
        }
    }
    
    public var shortName: String {
        switch self {
        case .flash15: return "Gemini 1.5 Flash"
        case .flash20: return "Gemini 2.0 Flash"
        case .pro15:   return "Gemini 1.5 Pro"
        }
    }
}

// MARK: - Gemini Request & Response Codables

fileprivate struct GeminiRequestPayload: Codable {
    let systemInstruction: GeminiContentPayload?
    let contents: [GeminiContentPayload]
    let generationConfig: GeminiGenerationConfigPayload?
}

fileprivate struct GeminiContentPayload: Codable {
    let role: String?
    let parts: [GeminiPartPayload]
}

fileprivate struct GeminiPartPayload: Codable {
    let text: String
}

fileprivate struct GeminiGenerationConfigPayload: Codable {
    let temperature: Double
    let maxOutputTokens: Int
}

fileprivate struct GeminiResponsePayload: Codable {
    let candidates: [GeminiCandidatePayload]?
    let error: GeminiErrorPayload?
}

fileprivate struct GeminiCandidatePayload: Codable {
    let content: GeminiContentPayload?
    let finishReason: String?
}

fileprivate struct GeminiErrorPayload: Codable {
    let code: Int?
    let message: String?
    let status: String?
}

// MARK: - Gemini API Service

public final class GeminiAPIService: ObservableObject {
    public static let shared = GeminiAPIService()
    
    @Published public var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "gemini_api_key") }
    }
    @Published public var selectedModelRaw: String {
        didSet { UserDefaults.standard.set(selectedModelRaw, forKey: "gemini_model") }
    }
    @Published public var useLiveAI: Bool {
        didSet { UserDefaults.standard.set(useLiveAI, forKey: "gemini_use_ai") }
    }
    
    private init() {
        self.apiKey = UserDefaults.standard.string(forKey: "gemini_api_key") ?? ""
        self.selectedModelRaw = UserDefaults.standard.string(forKey: "gemini_model") ?? GeminiModel.flash15.rawValue
        self.useLiveAI = UserDefaults.standard.object(forKey: "gemini_use_ai") as? Bool ?? true
    }
    
    public var selectedModel: GeminiModel {
        get { GeminiModel(rawValue: selectedModelRaw) ?? .flash15 }
        set { selectedModelRaw = newValue.rawValue }
    }
    
    public var isKeyConfigured: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private let systemGroundTruthPrompt = """
    You are CampusBuddy AI, an intelligent, helpful, and concise university campus assistant for students, faculty, and visitors.
    
    AUTHORITATIVE CAMPUS DATA:
    1. Block A (Administrative & Central Academic Block):
       - Room A-001: Main Reception & Visitor Information.
       - Room A-002: Accounts & Fee Office. Handled by Mr. Ramesh Sharma (Finance Officer). Open Mon-Fri, 9:00 AM - 5:00 PM. Services: Semester fee payment, challan verification, scholarship disbursement, no-dues certificate, caution money refund.
       - Room A-005: Admissions & Document Verification Cell. Open Mon-Sat 8:30 AM - 5:30 PM.
       - Room A-008: Student Helpdesk & Grievance Cell (Lost & found, ID re-issue).
       - Room A-101: Central University Library (120,000+ volumes, silent study cabins, digital portal). Open all 7 days, 8:00 AM - 10:00 PM.
       - Room A-201: Dean's Secretariat & Registrar's Office.
    
    2. Block B (Engineering, Computing & Innovation):
       - Room B-001: Embedded Systems & IoT Laboratory.
       - Room B-102: Artificial Intelligence & Cloud Computing Lab. High-performance GPU nodes, workstations. In-charge: Dr. Ananya Roy.
       - Room B-201: Robotics Research Wing.
       - Room B-301: Main Seminar Hall (300 seating capacity).
    
    3. Block C (Student Welfare, Amenities & Health):
       - Hall C-001: Central Auditorium (1,200 capacity, acoustics, stage lighting).
       - Room C-004: Campus Health Center & 24/7 Dispensary (Resident medical officer, emergency care, free basic medicines).
       - Room C-101: Student Clubs Council & Cultural Activity Center.
    
    4. Block D (Student Center & Food Court):
       - Ground Hall / Room D-001: Central Cafeteria & Multi-Cuisine Food Court (Subway, Domino's, Nescafe Corner, North/South Indian Thali). Open 7:30 AM - 11:00 PM.
       - Room D-101: Campus Stationary, Photocopy, Printing & Spiral Binding Shop.
    
    5. Block E: Sports Complex & Indoor Arena (Gymnasium, Olympic Swimming Pool, 4 Badminton Courts, Basketball).
    
    6. Campus Buggy Service:
       - Eco Shuttle (₹10) & Express Buggy (₹25) bookable in the app's Buggy tab with live GPS tracking and UPI payments.
       - Accessible rides for students with physical needs are 100% free.
       - Operational hours: 7:00 AM - 9:30 PM daily.
    
    7. Routing & Navigation:
       - Point-to-point indoor and outdoor routing is available in the Route tab (Walking, Buggy, Accessible elevators/ramps).
    
    INSTRUCTIONS:
    - Keep responses concise, friendly, student-focused, and under 100 words.
    - Provide exact room numbers, block names, and timings whenever asked.
    - If suggesting a destination, you may include a tag at the very end on its own line:
      [ACTION:accounts|Navigate to Room A-002]
      [ACTION:cafeteria|Navigate to Cafeteria]
      [ACTION:library|Navigate to Central Library]
      [ACTION:ai_lab|Navigate to AI Lab B-102]
      [ACTION:auditorium|Navigate to Auditorium]
      [ACTION:health_center|Navigate to Health Center]
      [ACTION:buggy|Book a Buggy]
      [ACTION:route|Open Route Planner]
    """
    
    // MARK: - Send Message to Gemini
    
    public func sendMessage(
        prompt: String,
        history: [(text: String, isUser: Bool)]
    ) async throws -> (reply: String, actionTitle: String?, actionTarget: String?, source: String) {
        
        let cleanedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If live AI is disabled or key is empty, use the built-in intelligent engine
        guard useLiveAI && !cleanedKey.isEmpty else {
            let fallback = generateFallbackResponse(for: prompt)
            return (fallback.reply, fallback.actionTitle, fallback.actionTarget, "CampusBuddy Smart Engine")
        }
        
        let model = selectedModel.rawValue
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(cleanedKey)") else {
            throw URLError(.badURL)
        }
        
        // Build contents including recent history (last 6 turns for context efficiency)
        var contents: [GeminiContentPayload] = []
        let recentHistory = history.suffix(6)
        for item in recentHistory {
            contents.append(
                GeminiContentPayload(
                    role: item.isUser ? "user" : "model",
                    parts: [GeminiPartPayload(text: item.text)]
                )
            )
        }
        // Append current prompt
        contents.append(
            GeminiContentPayload(
                role: "user",
                parts: [GeminiPartPayload(text: prompt)]
            )
        )
        
        let requestPayload = GeminiRequestPayload(
            systemInstruction: GeminiContentPayload(
                role: "system",
                parts: [GeminiPartPayload(text: systemGroundTruthPrompt)]
            ),
            contents: contents,
            generationConfig: GeminiGenerationConfigPayload(
                temperature: 0.6,
                maxOutputTokens: 600
            )
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestPayload)
        request.timeoutInterval = 15
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            if let decodedError = try? JSONDecoder().decode(GeminiResponsePayload.self, from: data),
               let err = decodedError.error {
                throw NSError(domain: "GeminiAPI", code: err.code ?? httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: err.message ?? "Gemini API error (\(httpResponse.statusCode))"])
            }
            throw NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned HTTP \(httpResponse.statusCode)"])
        }
        
        let decoded = try JSONDecoder().decode(GeminiResponsePayload.self, from: data)
        guard let candidate = decoded.candidates?.first,
              let part = candidate.content?.parts.first else {
            throw NSError(domain: "GeminiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response text received from Gemini"])
        }
        
        let rawText = part.text
        let parsed = parseActionFromText(rawText)
        return (parsed.cleanText, parsed.actionTitle, parsed.actionTarget, selectedModel.shortName)
    }
    
    // MARK: - Test API Key
    
    public func testApiKey(_ keyToTest: String, model: GeminiModel) async -> (success: Bool, message: String) {
        let cleaned = keyToTest.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            return (false, "Please enter an API key.")
        }
        
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model.rawValue):generateContent?key=\(cleaned)") else {
            return (false, "Invalid URL configuration.")
        }
        
        let pingPayload = GeminiRequestPayload(
            systemInstruction: nil,
            contents: [
                GeminiContentPayload(
                    role: "user",
                    parts: [GeminiPartPayload(text: "Reply with the single word: OK")]
                )
            ],
            generationConfig: GeminiGenerationConfigPayload(temperature: 0.1, maxOutputTokens: 10)
        )
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            req.httpBody = try JSONEncoder().encode(pingPayload)
            req.timeoutInterval = 10
            let (data, res) = try await URLSession.shared.data(for: req)
            
            if let httpRes = res as? HTTPURLResponse {
                if httpRes.statusCode == 200 {
                    return (true, "Key is valid & Gemini connection verified! ✨")
                } else {
                    if let errPayload = try? JSONDecoder().decode(GeminiResponsePayload.self, from: data),
                       let msg = errPayload.error?.message {
                        return (false, "Error \(httpRes.statusCode): \(msg)")
                    }
                    return (false, "HTTP error status \(httpRes.statusCode)")
                }
            }
            return (false, "Unknown server response.")
        } catch {
            return (false, error.localizedDescription)
        }
    }
    
    // MARK: - Action Parser
    
    private func parseActionFromText(_ text: String) -> (cleanText: String, actionTitle: String?, actionTarget: String?) {
        // Look for pattern: [ACTION:target|Title]
        let pattern = "\\[ACTION:([a-zA-Z0-9_]+)\\|([^\\]]+)\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return autoDetectActionFromContent(text)
        }
        
        let nsText = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
        
        if let match = matches.first, match.numberOfRanges >= 3 {
            let targetRange = match.range(at: 1)
            let titleRange = match.range(at: 2)
            let fullRange = match.range(at: 0)
            
            let target = nsText.substring(with: targetRange)
            let title = nsText.substring(with: titleRange)
            let cleaned = nsText.replacingCharacters(in: fullRange, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            return (cleaned, title, target)
        }
        
        // If model didn't use the tag, heuristically detect key destinations
        return autoDetectActionFromContent(text)
    }
    
    private func autoDetectActionFromContent(_ text: String) -> (cleanText: String, actionTitle: String?, actionTarget: String?) {
        let lower = text.lowercased()
        if lower.contains("room a-002") || lower.contains("accounts") || lower.contains("fee office") {
            return (text, "Navigate to Room A-002", "accounts")
        } else if lower.contains("cafeteria") || lower.contains("food court") {
            return (text, "Navigate to Cafeteria", "cafeteria")
        } else if lower.contains("library") || lower.contains("a-101") {
            return (text, "Navigate to Central Library", "library")
        } else if lower.contains("ai lab") || lower.contains("b-102") || lower.contains("cloud lab") {
            return (text, "Navigate to AI Lab", "ai_lab")
        } else if lower.contains("auditorium") || lower.contains("c-001") {
            return (text, "Navigate to Auditorium", "auditorium")
        } else if lower.contains("health center") || lower.contains("dispensary") || lower.contains("c-004") {
            return (text, "Navigate to Health Center", "health_center")
        } else if lower.contains("buggy") || lower.contains("shuttle") {
            return (text, "Book a Buggy", "buggy")
        } else if lower.contains("route") || lower.contains("navigation") {
            return (text, "Open Route Planner", "route")
        }
        return (text, nil, nil)
    }
    
    // MARK: - Smart Offline / Fallback Campus Engine
    
    public func generateFallbackResponse(for prompt: String) -> (reply: String, actionTitle: String?, actionTarget: String?) {
        let lower = prompt.lowercased()
        
        if lower.contains("account") || lower.contains("fee") || lower.contains("challan") || lower.contains("scholarship") {
            return (
                "The Accounts & Fee Office is located on the Ground Floor of Block A (Room A-002). Open Mon–Fri, 9:00 AM – 5:00 PM. In-charge: Mr. Ramesh Sharma (Finance Officer). Services: tuition payments, fee challans, no-dues certificates, and scholarship verification.",
                "Navigate to Room A-002",
                "accounts"
            )
        } else if lower.contains("buggy") || lower.contains("ride") || lower.contains("shuttle") || lower.contains("cart") {
            return (
                "Campus Electric Buggy shuttles operate from 7:00 AM to 9:30 PM. You can book an Eco Shuttle (₹10) or Express Buggy (₹25) directly from the Buggy tab with live GPS tracking! Accessible rides are 100% free for students with special needs.",
                "Book a Buggy",
                "buggy"
            )
        } else if lower.contains("library") || lower.contains("book") || lower.contains("reading") || lower.contains("study") {
            return (
                "The Central University Library is located in Block A, 1st Floor (Room A-101). It is open all 7 days from 8:00 AM to 10:00 PM with quiet study halls, digital research terminals, and over 120,000 titles.",
                "Navigate to Central Library",
                "library"
            )
        } else if lower.contains("cafe") || lower.contains("food") || lower.contains("lunch") || lower.contains("dining") || lower.contains("coffee") || lower.contains("hungry") {
            return (
                "The Central Cafeteria & Multi-Cuisine Food Court is located in Block D (Ground Floor). Outlets include Subway, Domino's, Nescafe Corner, and North/South Indian Thali dining. Open 7:30 AM – 11:00 PM.",
                "Navigate to Cafeteria",
                "cafeteria"
            )
        } else if lower.contains("ai") || lower.contains("lab") || lower.contains("cloud") || lower.contains("computer") {
            return (
                "The Artificial Intelligence & Cloud Computing Lab is located in Block B, Floor 1 (Room B-102). It is equipped with high-performance GPU nodes and cloud workstations. In-charge: Dr. Ananya Roy.",
                "Navigate to AI Lab",
                "ai_lab"
            )
        } else if lower.contains("health") || lower.contains("doctor") || lower.contains("medicine") || lower.contains("hospital") || lower.contains("dispensary") {
            return (
                "The Campus Health Center & Dispensary is located in Block C, Ground Floor (Room C-004). Resident doctors and nurses are on duty 24/7 with emergency first aid, ambulance support, and basic pharmacy medications.",
                "Navigate to Health Center",
                "health_center"
            )
        } else if lower.contains("audi") || lower.contains("hall") || lower.contains("seminar") || lower.contains("event") {
            return (
                "The Central Auditorium is situated in Block C (Hall C-001) with 1,200 seats and state-of-the-art acoustics. For smaller conferences, Block B Main Seminar Hall (Room B-301) seats 300.",
                "Navigate to Auditorium",
                "auditorium"
            )
        } else if lower.contains("sport") || lower.contains("gym") || lower.contains("pool") || lower.contains("badminton") {
            return (
                "The University Sports Complex is in Block E, featuring an Olympic swimming pool, fully equipped fitness gymnasium, 4 indoor badminton courts, and an outdoor athletic track.",
                "Open Route Planner",
                "route"
            )
        } else if lower.contains("lost") || lower.contains("found") {
            return (
                "Lost an item or found someone's belonging? Visit the Lost & Found Hub under Campus Services on the Home tab, or stop by Room A-008 (Student Helpdesk).",
                "Open Route Planner",
                "route"
            )
        } else {
            return (
                "I'm CampusBuddy! You can ask me for turn-by-turn directions to any room (e.g. Accounts Office Room A-002, AI Lab B-102), book an electric buggy, check cafeteria menus, library hours, or campus events. Where would you like to go today?",
                "Explore Route Planner",
                "route"
            )
        }
    }
}
