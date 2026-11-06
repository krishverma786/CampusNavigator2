import SwiftUI

struct TimetableView: View {
    
    @State private var selectedDay = "Mon"
    @State private var selectedNavPlace: CampusPlace?
    @State private var showingNavigation = false
    
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 20) {
                
                // Attendance Summary Card
                attendanceCard
                
                // Day Selector Chips
                daySelector
                
                // Today's Classes Timeline
                classesTimeline
                
                // Upcoming Midterms & Exams
                examsSection
                
                Color.clear.frame(height: 30)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Class Timetable")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingNavigation) {
            if let place = selectedNavPlace {
                CampusNavigationView(destination: place)
            }
        }
    }
    
    // MARK: - Attendance Card
    
    private var attendanceCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 72, height: 72)
                
                Circle()
                    .trim(from: 0.0, to: 0.87)
                    .stroke(
                        LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 72, height: 72)
                
                VStack(spacing: 0) {
                    Text("87%")
                        .font(.system(size: 18, weight: .heavy))
                    Text("Present")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Semester Attendance")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("You are safely above the 75% university eligibility requirement.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 6, height: 6)
                        Text("42 Present")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.red).frame(width: 6, height: 6)
                        Text("6 Absent")
                            .font(.system(size: 10, weight: .semibold))
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Day Selector
    
    private var daySelector: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.self) { day in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDay = day
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(day)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedDay == day ? Color.blue : Color(.secondarySystemBackground))
                    .foregroundStyle(selectedDay == day ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Classes Timeline
    
    private var classesTimeline: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Schedule for \(selectedDay)")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(sampleTodayClasses.count) Sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(sampleTodayClasses) { session in
                    classRowCard(session)
                }
            }
        }
    }
    
    private func classRowCard(_ session: ClassSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(session.timeRange)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(session.isCurrent ? .blue : .secondary)
                        
                        if session.isCurrent {
                            Text("NOW")
                                .font(.system(size: 8, weight: .heavy))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(session.subjectName)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Text(session.type.rawValue)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemBackground))
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                        Text("\(session.block) • \(session.roomNumber)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Faculty: \(session.facultyName)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Direct Navigate Action
                Button {
                    selectedNavPlace = CampusPlace(
                        name: session.subjectName,
                        type: "Classroom",
                        building: session.block,
                        floor: session.roomNumber.contains("0") ? 0 : 1,
                        latitude: 30.7685,
                        longitude: 76.5760,
                        roomNumber: session.roomNumber
                    )
                    showingNavigation = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                        Text("Navigate")
                    }
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.12))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(session.isCurrent ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
    }
    
    // MARK: - Exams Section
    
    private var examsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Exams & Dates")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                ForEach(sampleUpcomingExams) { exam in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.12))
                                .frame(width: 48, height: 48)
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(exam.subjectName)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Text("\(exam.dateString) • \(exam.timeRange)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 8) {
                                Text(exam.venue)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.blue)
                                Text("•  Seat: \(exam.seatNumber)")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}
