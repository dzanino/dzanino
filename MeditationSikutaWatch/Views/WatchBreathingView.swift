import SwiftUI
import WatchKit

struct WatchBreathingView: View {
    @ObservedObject var vm: BreathingViewModel

    private let circleSize: CGFloat = 100

    var body: some View {
        ZStack {
            background

            VStack(spacing: 8) {
                breathingCircle
                    .padding(.top, 4)

                if vm.state == .complete {
                    completionLabel
                } else if vm.isActive || vm.state == .paused {
                    activeInfo
                } else {
                    idleInfo
                }
            }
        }
    }

    private var background: some View {
        Color(red: 0.04, green: 0.06, blue: 0.12)
            .ignoresSafeArea()
    }

    private var breathingCircle: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            vm.currentPhase.accentColor.opacity(0.6),
                            vm.currentPhase.accentColor.opacity(0.12)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: circleSize * 0.5
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .scaleEffect(activeScale)
                .animation(
                    vm.isActive
                        ? .easeInOut(duration: vm.animationDuration)
                        : .easeInOut(duration: 0.4),
                    value: vm.currentPhase
                )

            Circle()
                .stroke(vm.currentPhase.accentColor.opacity(0.7), lineWidth: 1.5)
                .frame(width: circleSize, height: circleSize)
                .scaleEffect(activeScale)
                .animation(
                    vm.isActive
                        ? .easeInOut(duration: vm.animationDuration)
                        : .easeInOut(duration: 0.4),
                    value: vm.currentPhase
                )

            circleLabel
        }
        .frame(width: circleSize, height: circleSize)
    }

    @ViewBuilder
    private var circleLabel: some View {
        if vm.state == .complete {
            Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.green)
        } else if vm.isActive || vm.state == .paused {
            VStack(spacing: 1) {
                Text(vm.currentPhase.localizedName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(String(format: "%.0f", max(0, vm.timeRemaining + 0.95)))
                    .font(.system(size: 28, weight: .thin, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .monospacedDigit()
            }
        } else {
            Text("Šikuta")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var activeInfo: some View {
        Text("Cyklus \(vm.currentCycle + 1)/\(vm.pattern.cycles)")
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.5))
    }

    private var idleInfo: some View {
        Text(vm.pattern.name)
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.45))
            .lineLimit(1)
    }

    private var completionLabel: some View {
        Text("Hotovo ✓")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.green.opacity(0.85))
    }

    private var activeScale: CGFloat {
        guard vm.isActive || vm.state == .paused else { return 1.0 }
        return vm.currentPhase.targetScale
    }
}
