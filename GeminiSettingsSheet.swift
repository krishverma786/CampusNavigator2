import SwiftUI

struct GeminiSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var geminiService = GeminiAPIService.shared
    
    @State private var inputKey: String = ""
    @State private var isKeyVisible: Bool = false
    @State private var isTesting: Bool = false
    @State private var testResult: (success: Bool, message: String)? = nil
    @State private var showSavedAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - Status Banner
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(geminiService.isKeyConfigured ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: geminiService.isKeyConfigured ? "checkmark.seal.fill" : "key.fill")
                                .font(.title3)
                                .foregroundStyle(geminiService.isKeyConfigured ? .green : .orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(geminiService.isKeyConfigured ? "Gemini AI Active" : "Setup Gemini API")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(geminiService.isKeyConfigured
                                 ? "\(geminiService.selectedModel.shortName) is ready"
                                 : "Add your key to enable live AI responses")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - API Key Input
                Section(
                    header: Text("Google Gemini API Key"),
                    footer: Text("Your key is stored securely in local device storage and used directly to communicate with Google Generative AI endpoints.")
                ) {
                    HStack {
                        if isKeyVisible {
                            TextField("Paste AIzaSy... key", text: $inputKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .font(.system(.subheadline, design: .monospaced))
                        } else {
                            SecureField("Paste AIzaSy... key", text: $inputKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .font(.system(.subheadline, design: .monospaced))
                        }
                        
                        Button {
                            isKeyVisible.toggle()
                        } label: {
                            Image(systemName: isKeyVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                        
                        if !inputKey.isEmpty {
                            Button {
                                inputKey = ""
                                testResult = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    
                    // Paste from clipboard helper button
                    if let string = UIPasteboard.general.string, string.hasPrefix("AIza") && inputKey.isEmpty {
                        Button {
                            inputKey = string
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.clipboard")
                                Text("Paste from Clipboard")
                            }
                            .font(.caption)
                            .foregroundStyle(.blue)
                        }
                    }
                }
                
                // MARK: - Model Selection
                Section(header: Text("Model Selection")) {
                    Picker("Model", selection: $geminiService.selectedModelRaw) {
                        ForEach(GeminiModel.allCases) { model in
                            VStack(alignment: .leading) {
                                Text(model.shortName)
                                    .fontWeight(.medium)
                            }
                            .tag(model.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Toggle("Use Live Gemini Model", isOn: $geminiService.useLiveAI)
                }
                
                // MARK: - Test Connection Section
                Section {
                    Button {
                        runTest()
                    } label: {
                        HStack {
                            if isTesting {
                                ProgressView()
                                    .padding(.trailing, 6)
                                Text("Verifying with Gemini...")
                            } else {
                                Image(systemName: "bolt.horizontal.fill")
                                Text("Test API Connection")
                            }
                        }
                        .fontWeight(.semibold)
                    }
                    .disabled(inputKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTesting)
                    
                    if let result = testResult {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: result.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundStyle(result.success ? .green : .red)
                            
                            Text(result.message)
                                .font(.caption)
                                .foregroundStyle(result.success ? .green : .red)
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                // MARK: - Actions
                Section {
                    Button {
                        saveKey()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save Key")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .disabled(inputKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    if geminiService.isKeyConfigured {
                        Button(role: .destructive) {
                            inputKey = ""
                            geminiService.apiKey = ""
                            testResult = nil
                        } label: {
                            HStack {
                                Spacer()
                                Text("Remove API Key")
                                Spacer()
                            }
                        }
                    }
                }
                
                // MARK: - How to Get a Key
                Section(header: Text("Need an API Key?")) {
                    Link(destination: URL(string: "https://aistudio.google.com/app/apikey")!) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Get free key at Google AI Studio")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    Text("Google AI Studio offers a free tier for developers with high rate limits, perfect for personal and academic campus apps.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Gemini API Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if !inputKey.isEmpty && inputKey != geminiService.apiKey {
                            saveKey()
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                inputKey = geminiService.apiKey
            }
            .alert("Key Saved", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your Gemini API key has been saved and is now powering CampusBuddy AI!")
            }
        }
    }
    
    private func runTest() {
        isTesting = true
        testResult = nil
        
        Task {
            let res = await geminiService.testApiKey(inputKey, model: geminiService.selectedModel)
            await MainActor.run {
                isTesting = false
                testResult = res
            }
        }
    }
    
    private func saveKey() {
        let cleaned = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
        geminiService.apiKey = cleaned
        showSavedAlert = true
    }
}
