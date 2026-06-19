import SwiftUI

struct ContentView: View {
    @StateObject private var vm = BreathingViewModel()
    @State private var showSettings = false

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                header
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Spacer(minLength: 8)

                // Breathing circle — fixed size, never too large
                BreathingAnimationView(vm: vm)
                    .frame(width: 300, height: 300)

                Spacer(minLength: 8)

                // Status text
                statusArea
                    .padding(.horizontal, 24)

                // Big start button — always pinned near bottom
                startButton
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(pattern: $vm.pattern, audioManager: vm.audioManager)
        }
        .onChange(of: vm.state) { _, state in
            if state == .complete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation { vm.stop() }
                }
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color(red: 0.04, green: 0.06, blue: 0.12)
            RadialGradient(
                colors: [vm.currentPhase.accentColor.opacity(vm.isActive ? 0.15 : 0.05), .clear],
                center: .center,
                startRadius: 80,
                endRadius: 420
            )
            .animation(.easeInOut(duration: 1.5), value: vm.currentPhase)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("MEDITATION")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(2)
                Text("Šikuta")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Status area

    private var statusArea: some View {
        VStack(spacing: 6) {
            switch vm.state {
            case .idle:
                Text(vm.pattern.name)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                Text("Trvanie: \(durationLabel)")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.35))

            case .active, .paused:
                Text("Cyklus \(vm.currentCycle + 1) z \(vm.pattern.cycles)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                CycleDots(total: vm.pattern.cycles, completed: vm.currentCycle)

            case .complete:
                Text("Cvičenie dokončené")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.green)
                Text("Skvelá práca!")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(height: 52)
        .animation(.easeInOut(duration: 0.3), value: vm.state)
    }

    // MARK: - Start / control button

    private var startButton: some View {
        HStack(spacing: 14) {
            // Stop button (only when active or paused)
            if vm.isActive || vm.state == .paused {
                Button {
                    withAnimation { vm.stop() }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .transition(.scale.combined(with: .opacity))
            }

            // Main button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    switch vm.state {
                    case .idle, .complete: vm.start()
                    case .active:          vm.pause()
                    case .paused:          vm.resume()
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: mainButtonIcon)
                        .font(.system(size: 16, weight: .bold))
                    Text(mainButtonLabel)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(mainButtonGradient)
                .clipShape(Capsule())
                .shadow(color: mainButtonShadowColor, radius: 12, x: 0, y: 4)
            }
        }
        .animation(.spring(duration: 0.35), value: vm.state)
    }

    // MARK: - Helpers

    private var durationLabel: String {
        let t = Int(vm.pattern.totalSessionDuration)
        return t >= 60 ? "\(t / 60) min \(t % 60 > 0 ? "\(t % 60) s" : "")" : "\(t) s"
    }

    private var mainButtonIcon: String {
        switch vm.state {
        case .idle, .complete: return "play.fill"
        case .active:          return "pause.fill"
        case .paused:          return "play.fill"
        }
    }

    private var mainButtonLabel: String {
        switch vm.state {
        case .idle:    return "Začať"
        case .active:  return "Pozastaviť"
        case .paused:  return "Pokračovať"
        case .complete: return "Znova"
        }
    }

    private var mainButtonGradient: some ShapeStyle {
        switch vm.state {
        case .idle, .complete:
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.29, green: 0.62, blue: 1.0), Color(red: 0.18, green: 0.45, blue: 0.85)],
                startPoint: .leading, endPoint: .trailing
            ))
        default:
            return AnyShapeStyle(Color.white.opacity(0.15))
        }
    }

    private var mainButtonShadowColor: Color {
        switch vm.state {
        case .idle, .complete: return Color(red: 0.29, green: 0.62, blue: 1.0).opacity(0.4)
        default: return .clear
        }
    }
}

struct CycleDots: View {
    let total: Int
    let completed: Int
    private let maxVisible = 16

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<min(total, maxVisible), id: \.self) { i in
                Circle()
                    .fill(i < completed
                        ? BreathingPhase.inhale.accentColor
                        : Color.white.opacity(0.2))
                    .frame(width: i < completed ? 7 : 5, height: i < completed ? 7 : 5)
                    .animation(.spring(duration: 0.3), value: completed)
            }
            if total > maxVisible {
                Text("+\(total - maxVisible)")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }
}
