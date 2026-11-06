import SwiftUI

struct CheckInRecord: Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let timestamp: Date
    let type: String
}

struct QRScannerView: View {
    
    @State private var isScanning = true
    @State private var scanResult: CheckInRecord? = nil
    @State private var checkInHistory: [CheckInRecord] = [
        CheckInRecord(
            title: "Morning Attendance",
            location: "Block B, Room B-102",
            timestamp: Date().addingTimeInterval(-7200),
            type: "Lecture Check-in"
        )
    ]
    @State private var laserOffset: CGFloat = -100
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // Viewfinder Section
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 260, height: 260)
                        
                        // Corner brackets
                        cornerBrackets
                            .frame(width: 260, height: 260)
                        
                        // Animated Scanning Laser Line
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, .blue, .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 240, height: 3)
                            .offset(y: laserOffset)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: laserOffset)
                        
                        VStack {
                            Spacer()
                            Text("Align QR Code within the frame")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.bottom, 12)
                        }
                    }
                    .padding(.top, 20)
                    .onAppear {
                        laserOffset = 100
                    }
                    
                    // Demo Preset QR Triggers for Testing
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Simulate Scanning Campus QR Codes:")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                qrPresetButton(
                                    title: "Room A-002 (Accounts)",
                                    location: "Block A, Accounts Office",
                                    type: "Office Visit Check-in"
                                )
                                
                                qrPresetButton(
                                    title: "CS401 Lecture (AI Lab)",
                                    location: "Block B, Room B-102",
                                    type: "Class Attendance"
                                )
                                
                                qrPresetButton(
                                    title: "CU HackSprint 2026",
                                    location: "Main Auditorium Hall C-001",
                                    type: "Event Check-in"
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Recent Check-in History List
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Recent Verified Check-Ins")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(checkInHistory.count) logged")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 16)
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(checkInHistory) { record in
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.title3)
                                            .foregroundStyle(.green)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(record.title)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)
                                            Text("\(record.location) • \(record.type)")
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Text(record.timestamp, style: .time)
                                            .font(.caption2)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Campus QR Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $scanResult) { record in
                checkInSuccessSheet(record)
            }
        }
    }
    
    private var cornerBrackets: some View {
        ZStack {
            // Top Left
            VStack {
                HStack {
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 30))
                        p.addLine(to: CGPoint(x: 0, y: 0))
                        p.addLine(to: CGPoint(x: 30, y: 0))
                    }
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 30, height: 30)
                    Spacer()
                }
                Spacer()
            }
            // Top Right
            VStack {
                HStack {
                    Spacer()
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 0))
                        p.addLine(to: CGPoint(x: 30, y: 0))
                        p.addLine(to: CGPoint(x: 30, y: 30))
                    }
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 30, height: 30)
                }
                Spacer()
            }
            // Bottom Left
            VStack {
                Spacer()
                HStack {
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 0))
                        p.addLine(to: CGPoint(x: 0, y: 30))
                        p.addLine(to: CGPoint(x: 30, y: 30))
                    }
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 30, height: 30)
                    Spacer()
                }
            }
            // Bottom Right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Path { p in
                        p.move(to: CGPoint(x: 30, y: 0))
                        p.addLine(to: CGPoint(x: 30, y: 30))
                        p.addLine(to: CGPoint(x: 0, y: 30))
                    }
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 30, height: 30)
                }
            }
        }
    }
    
    private func qrPresetButton(title: String, location: String, type: String) -> some View {
        Button {
            let record = CheckInRecord(
                title: title,
                location: location,
                timestamp: Date(),
                type: type
            )
            checkInHistory.insert(record, at: 0)
            scanResult = record
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.25))
            .foregroundStyle(.cyan)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1))
        }
    }
    
    private func checkInSuccessSheet(_ record: CheckInRecord) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
            }
            
            Text("Verified Check-In! ✅")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your attendance and physical location presence has been officially recorded by CampusNavigator.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Subject / Location:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(record.title)
                        .font(.caption)
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Venue:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(record.location)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Time:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(record.timestamp, style: .time)
                        .font(.caption)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button {
                scanResult = nil
            } label: {
                Text("Done")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}
