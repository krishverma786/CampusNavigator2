import SwiftUI

struct LoginView: View {

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("currentUserName") private var currentUserName = ""

    // MARK: - Mode

    private enum AuthMode {
        case signIn
        case signUp
    }

    @State private var mode: AuthMode = .signIn

    // MARK: - Form Fields

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    // MARK: - Validation & State

    @State private var fullNameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var isLoading = false

    // MARK: - Animation

    @State private var didAppear = false

    @FocusState private var focusedField: Field?

    private enum Field {
        case fullName, email, password
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {

                // MARK: Background

                backgroundLayer(height: geo.size.height)

                VStack(spacing: 0) {

                    // MARK: Hero

                    heroSection
                        .frame(height: geo.size.height * 0.36)
                        .opacity(didAppear ? 1 : 0)
                        .offset(y: didAppear ? 0 : -16)

                    // MARK: Form Card

                    formCard
                        .opacity(didAppear ? 1 : 0)
                        .offset(y: didAppear ? 0 : 40)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                didAppear = true
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }

    // MARK: - Background

    private func backgroundLayer(height: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.22, blue: 0.62), Color(red: 0.29, green: 0.42, blue: 0.93)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 260, height: 260)
                .offset(x: -120, y: -140)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 200, height: 200)
                .offset(x: 140, y: -40)

            // Subtle route-line motif echoing the app's navigation theme
            GeometryReader { geo in
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width * 0.1, y: geo.size.height * 0.28))
                    path.addCurve(
                        to: CGPoint(x: geo.size.width * 0.85, y: geo.size.height * 0.10),
                        control1: CGPoint(x: geo.size.width * 0.35, y: geo.size.height * 0.42),
                        control2: CGPoint(x: geo.size.width * 0.6, y: geo.size.height * 0.02)
                    )
                }
                .stroke(
                    Color.white.opacity(0.18),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [1, 14])
                )
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 14) {

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 88, height: 88)

                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)

                Image(systemName: "location.north.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .indigo],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(-45))
            }

            Text("CampusNavigator")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(mode == .signIn ? "Welcome back — let's get you moving." : "Set up your account to get started.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 22) {

            modeSwitcher
                .padding(.top, 22)

            VStack(spacing: 14) {

                if mode == .signUp {
                    fieldBlock(
                        icon: "person.fill",
                        placeholder: "Full name",
                        text: $fullName,
                        error: fullNameError,
                        field: .fullName
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                fieldBlock(
                    icon: "envelope.fill",
                    placeholder: "Email address",
                    text: $email,
                    error: emailError,
                    field: .email,
                    keyboard: .emailAddress
                )

                secureFieldBlock

                if mode == .signIn {
                    HStack {
                        Spacer()
                        Button("Forgot password?") {
                            // Demo-only: no backend wired up yet.
                        }
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    }
                }
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.25), value: mode)

            primaryButton
                .padding(.horizontal, 24)

            dividerRow
                .padding(.horizontal, 24)

            guestButton
                .padding(.horizontal, 24)

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 20, y: -6)
        )
        .padding(.top, -28)
    }

    // MARK: - Mode Switcher

    private var modeSwitcher: some View {
        HStack(spacing: 4) {
            switcherOption(title: "Sign In", isActive: mode == .signIn) {
                switchMode(to: .signIn)
            }
            switcherOption(title: "Create Account", isActive: mode == .signUp) {
                switchMode(to: .signUp)
            }
        }
        .padding(4)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
        .padding(.horizontal, 24)
    }

    private func switcherOption(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isActive ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isActive {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .indigo],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    private func switchMode(to newMode: AuthMode) {
        guard newMode != mode else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            mode = newMode
            fullNameError = nil
            emailError = nil
            passwordError = nil
        }
    }

    // MARK: - Text Field Block

    private func fieldBlock(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        error: String?,
        field: Field,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(field == .email ? .never : .words)
                    .autocorrectionDisabled(field == .email)
                    .focused($focusedField, equals: field)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        error != nil ? Color.red.opacity(0.6) :
                            (focusedField == field ? Color.blue : Color.clear),
                        lineWidth: 1.5
                    )
            )

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            }
        }
    }

    // MARK: - Secure Field Block

    private var secureFieldBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Group {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .focused($focusedField, equals: .password)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        passwordError != nil ? Color.red.opacity(0.6) :
                            (focusedField == .password ? Color.blue : Color.clear),
                        lineWidth: 1.5
                    )
            )

            if let passwordError {
                Text(passwordError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            } else if mode == .signUp {
                Text("At least 6 characters.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
    }

    // MARK: - Primary Button

    private var primaryButton: some View {
        Button {
            submit()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(mode == .signIn ? "Sign In" : "Create Account")
                        .fontWeight(.bold)

                    Image(systemName: "arrow.right")
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [.blue, .indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .opacity(isLoading ? 0.85 : 1)
        }
        .disabled(isLoading)
    }

    // MARK: - Divider

    private var dividerRow: some View {
        HStack(spacing: 10) {
            Rectangle().fill(Color(.separator)).frame(height: 1)
            Text("or")
                .font(.caption)
                .foregroundStyle(.secondary)
            Rectangle().fill(Color(.separator)).frame(height: 1)
        }
    }

    // MARK: - Guest Button

    private var guestButton: some View {
        Button {
            currentUserName = "Guest"
            withAnimation {
                isLoggedIn = true
            }
        } label: {
            HStack {
                Image(systemName: "figure.walk")
                Text("Continue as Guest")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Validation & Submit

    private func submit() {
        focusedField = nil
        fullNameError = nil
        emailError = nil
        passwordError = nil

        var isValid = true

        if mode == .signUp && fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            fullNameError = "Enter your name."
            isValid = false
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = "Enter your email."
            isValid = false
        } else if !trimmedEmail.contains("@") || !trimmedEmail.contains(".") {
            emailError = "Enter a valid email."
            isValid = false
        }

        if password.isEmpty {
            passwordError = "Enter your password."
            isValid = false
        } else if mode == .signUp && password.count < 6 {
            passwordError = "Password must be at least 6 characters."
            isValid = false
        }

        guard isValid else { return }

        isLoading = true

        // Simulated auth delay — no backend is wired up in this demo.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            isLoading = false
            currentUserName = mode == .signUp
                ? fullName.trimmingCharacters(in: .whitespaces)
                : trimmedEmail.components(separatedBy: "@").first ?? "Student"
            withAnimation {
                isLoggedIn = true
            }
        }
    }
}

#Preview {
    LoginView()
}
