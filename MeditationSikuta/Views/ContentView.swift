import SwiftUI

struct ContentView: View {
    @StateObject private var vm = BreathingViewModel()
    @State private var showSettings = false

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                header
                Spacer()
                BreathingAnimationView(vm: vm)
                Spacer()
                cycleIndicator
                    .padding(.bottom, 28)
                controlButton
                    .padding(.bottom, 48)
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(pattern: $vm.pattern, audioManager: vm.audioManager)
        }
        .onChange(of: vm.state) { _, state in
            if state == .complete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation { vm.stop() }
                }
            }
        }
    }

    private var background: some View {
        ZStack {
            Color(red: 0.04, green: 0.06, blue: 0.12)

            RadialGradient(
                colors: [
                    vm.currentPhase.accentColor.opacity(vm.isActive ? 0.12 : 0.04),
                    .clear
                ],
                center: .center,
                startRadius: 80,
                endRadius: 400
            )
            .animation(.easeInOut(duration: 2.0), value: vm.currentPhase)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Meditation")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                    .textCase(.uppercase)
                    .tracking(1.5)
                Text("Šikuta")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.07))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }

    private var cycleIndicator: some View {
        VStack(spacing: 10) {
            if vm.isActive || vm.state == .paused {
                Text("Cyklus \(vm.currentCycle + 1) / \(vm.pattern.cycles)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))

                CycleDots(total: vm.pattern.cycles, completed: vm.currentCycle)
            } else if vm.state == .complete {
                Text("Sedenie dokončené  ✓")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.green.opacity(0.85))
            } else {
                Text(sessionDurationLabel)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .frame(height: 52)
    }

    private var sessionDurationLabel: String {
        let total = vm.pattern.totalSessionDuration
        let minutes = Int(total) / 60
        let seconds = Int(total) % 60
        if minutes > 0 {
            return "Trvanie: \(minutes) min \(seconds > 0 ? "\(seconds) s" : "")"
        } else {
            return "Trvanie: \(seconds) s"
        }
    }

    private var controlButton: some View {
        HStack(spacing: 16) {
            if vm.isActive || vm.state == .paused {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.stop()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 56, height: 56)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    switch vm.state {
                    case .idle, .complete:
                        vm.start()
                    case .active:
                        vm.pause()
                    case .paused:
                        vm.resume()
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 18, weight: .semibold))
                    Text(buttonLabel)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(buttonBackground)
                .clipShape(Capsule())
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.state)
    }

    private var buttonIcon: String {
        switch vm.state {
        case .idle, .complete: return "play.fill"
        case .active:          return "pause.fill"
        case .paused:          return "play.fill"
        }
    }

    private var buttonLabel: String {
        switch vm.state {
        case .idle:    return "Začať"
        case .active:  return "Pozastaviť"
        case .paused:  return "Pokračovať"
        case .complete: return "Znova"
        }
    }

    private var buttonBackground: some ShapeStyle {
        switch vm.state {
        case .idle, .complete:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        BreathingPhase.inhale.accentColor,
                        BreathingPhase.inhale.accentColor.opacity(0.7)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        default:
            return AnyShapeStyle(Color.white.opacity(0.15))
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
