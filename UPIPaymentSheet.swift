import SwiftUI

struct UPIPaymentSheet: View {
    
    let amount: Double
    let description: String
    var onPaymentSuccess: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    @State private var paymentState: PaymentState = .ready
    
    enum PaymentState {
        case ready
        case processing
        case success
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                if paymentState == .success {
                    successView
                } else {
                    paymentForm
                }
            }
            .padding(20)
            .navigationTitle("UPI Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var paymentForm: some View {
        VStack(spacing: 18) {
            
            // Amount Header
            VStack(spacing: 4) {
                Text("AMOUNT PAYABLE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                
                Text("₹\(Int(amount))")
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
            
            // QR Code Simulation Card
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .frame(width: 170, height: 170)
                        .shadow(color: .black.opacity(0.08), radius: 6)
                    
                    VStack(spacing: 6) {
                        Image(systemName: "qrcode")
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 130, height: 130)
                            .foregroundStyle(.black)
                        
                        Text("UPI ID: cu.buggy@oksbi")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.black.opacity(0.7))
                    }
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                    Text("Verified Campus Merchant • NPCI Secure")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            // Pay via Apps Button (GPay / PhonePe / Paytm)
            VStack(spacing: 10) {
                Button {
                    paymentState = .processing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        paymentState = .success
                        onPaymentSuccess?()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if paymentState == .processing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                            Text("Pay via Google Pay / UPI")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(paymentState == .processing)
            }
            
            Spacer()
        }
    }
    
    private var successView: some View {
        VStack(spacing: 18) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.green)
            }
            
            Text("Payment Successful! 🎉")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("₹\(Int(amount)) received via Google Pay UPI")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Transaction Ref:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("UPI/2026/8941\(Int.random(in: 1000...9999))")
                        .font(.system(size: 10, weight: .bold))
                }
                HStack {
                    Text("Timestamp:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(Date(), style: .time)
                        .font(.caption2)
                }
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
