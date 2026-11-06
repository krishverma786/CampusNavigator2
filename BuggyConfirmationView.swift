import SwiftUI

struct BuggyConfirmationView: View {
    
    let booking: BuggyBooking
    @Environment(\.dismiss) private var dismiss
    @State private var animateCheckmark = false
    
    var onViewRides: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: Success Animation Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 90, height: 90)
                                
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 72, height: 72)
                                    .scaleEffect(animateCheckmark ? 1.0 : 0.5)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateCheckmark)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(.white)
                                    .scaleEffect(animateCheckmark ? 1.0 : 0.2)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.1), value: animateCheckmark)
                            }
                            .padding(.top, 20)
                            
                            Text("Booking Confirmed!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Your campus buggy has been booked. Driver assignment is in progress.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // MARK: Booking Details Card
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Label("Ride Summary", systemImage: "doc.plaintext.fill")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                                
                                Spacer()
                                
                                Text("#\(booking.id.uuidString.prefix(8).uppercased())")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            
                            Divider()
                            
                            // Route Details
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 10, height: 10)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("PICKUP")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.secondary)
                                        Text(booking.pickup)
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                Rectangle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 2, height: 20)
                                    .padding(.leading, 4)
                                
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 10, height: 10)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("DESTINATION")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.secondary)
                                        Text(booking.destination)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Metrics Grid
                            HStack {
                                InfoPill(title: "Passengers", value: "\(booking.passengers)", icon: "person.2.fill")
                                Spacer()
                                InfoPill(title: "Est. Time", value: "\(booking.estimatedTime) min", icon: "clock.fill")
                                Spacer()
                                InfoPill(title: "Distance", value: String(format: "%.1f km", booking.distance), icon: "map.fill")
                                Spacer()
                                InfoPill(title: "Total Fare", value: "₹\(Int(booking.fare))", icon: "indianrupeesign.circle.fill")
                            }
                        }
                        .padding(20)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        
                        // MARK: Action Buttons
                        VStack(spacing: 12) {
                            if let onViewRides = onViewRides {
                                Button {
                                    dismiss()
                                    onViewRides()
                                } label: {
                                    HStack {
                                        Image(systemName: "list.bullet.clipboard.fill")
                                        Text("Track in My Rides")
                                            .fontWeight(.bold)
                                    }
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Booking Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                animateCheckmark = true
            }
        }
    }
}

private struct InfoPill: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.blue)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    BuggyConfirmationView(
        booking: BuggyBooking(
            pickup: "Main Gate",
            destination: "Central Library",
            passengers: 2,
            distance: 1.2,
            fare: 40.0,
            estimatedTime: 5
        )
    )
}
