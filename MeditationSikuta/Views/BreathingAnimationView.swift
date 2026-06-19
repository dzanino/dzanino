import SwiftUI

struct BreathingAnimationView: View {
    @ObservedObject var vm: BreathingViewModel

    private let baseSize: CGFloat = 160

    var body: some View {
        ZStack {
            glowRings
            progressRing
            mainCircle
            labelOverlay
        }
        .frame(width: baseSize * 1.8, height: baseSize * 1.8)
    }

    private var progressRing: some View {
        let progress = vm.state == .active || vm.state == .paused ? vm.progress : 0.0
        return Circle()
            .trim(from: 0, to: CGFloat(progress))
            .stroke(
                vm.currentPhase.accentColor.opacity(0.55),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
            .frame(width: baseSize * 1.72, height: baseSize * 1.72)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 0.5), value: vm.currentCycle)
    }

    private var glowRings: some View {
        ForEach(0..<4, id: \.self) { i in
            Circle()
                .stroke(
                    vm.currentPhase.accentColor.opacity(0.08 - Double(i) * 0.015),
                    lineWidth: 1.5
                )
                .frame(width: baseSize, height: baseSize)
                .scaleEffect(circleScale + CGFloat(i + 1) * 0.14)
                .animation(
                    vm.isActive
                        ? .easeInOut(duration: vm.animationDuration).delay(Double(i) * 0.05)
                        : .easeInOut(duration: 0.4),
                    value: vm.currentPhase
                )
        }
    }

    private var mainCircle: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            vm.currentPhase.accentColor.opacity(0.55),
                            vm.currentPhase.accentColor.opacity(0.18),
                            vm.currentPhase.accentColor.opacity(0.04)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: baseSize * 0.5
                    )
                )
                .frame(width: baseSize, height: baseSize)
                .scaleEffect(circleScale)
                .animation(
                    vm.isActive
                        ? .easeInOut(duration: vm.animationDuration)
                        : .easeInOut(duration: 0.4),
                    value: vm.currentPhase
                )

            Circle()
                .stroke(
                    vm.currentPhase.accentColor.opacity(0.6),
                    lineWidth: 1.5
                )
                .frame(width: baseSize, height: baseSize)
                .scaleEffect(circleScale)
                .animation(
                    vm.isActive
                        ? .easeInOut(duration: vm.animationDuration)
                        : .easeInOut(duration: 0.4),
                    value: vm.currentPhase
                )
        }
    }

    private var labelOverlay: some View {
        VStack(spacing: 6) {
            if vm.state == .idle {
                Image(systemName: "play.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Text("Štart")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            } else if vm.state == .complete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)
                Text("Hotovo")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Text(vm.currentPhase.localizedName)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: vm.currentPhase)

                Text(String(format: "%.0f", max(0, vm.timeRemaining + 0.95)))
                    .font(.system(size: 56, weight: .thin, design: .rounded))
                    .foregroundStyle(.white.opacity(0.92))
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.05), value: vm.timeRemaining)
            }
        }
    }

    private var circleScale: CGFloat {
        guard vm.isActive || vm.state == .paused else { return 1.0 }
        return vm.currentPhase.targetScale
    }
}
