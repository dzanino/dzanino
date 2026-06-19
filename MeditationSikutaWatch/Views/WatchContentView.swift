import SwiftUI
import WatchKit

struct WatchNavigationView: View {
    @StateObject private var vm = BreathingViewModel()

    var body: some View {
        NavigationStack {
            WatchContentView(vm: vm)
                .navigationTitle("Šikuta")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WatchContentView: View {
    @ObservedObject var vm: BreathingViewModel
    @State private var showPatternPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                WatchBreathingView(vm: vm)

                controlButtons

                if vm.state == .idle {
                    patternButton
                }
            }
            .padding(.horizontal, 4)
        }
        .sheet(isPresented: $showPatternPicker) {
            WatchPatternPicker(selectedPattern: $vm.pattern)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 10) {
            if vm.isActive || vm.state == .paused {
                Button(role: .destructive) {
                    vm.stop()
                    WKInterfaceDevice.current().play(.failure)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .background(Color.red.opacity(0.25))
                .clipShape(Circle())
            }

            Button {
                switch vm.state {
                case .idle, .complete:
                    vm.start()
                    WKInterfaceDevice.current().play(.start)
                case .active:
                    vm.pause()
                    WKInterfaceDevice.current().play(.click)
                case .paused:
                    vm.resume()
                    WKInterfaceDevice.current().play(.click)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 14, weight: .semibold))
                    Text(buttonLabel)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(buttonColor)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var patternButton: some View {
        Button {
            showPatternPicker = true
        } label: {
            HStack {
                Text(vm.pattern.name)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
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
        case .active:  return "Pauza"
        case .paused:  return "Pokračovať"
        case .complete: return "Znova"
        }
    }

    private var buttonColor: Color {
        switch vm.state {
        case .idle, .complete: return BreathingPhase.inhale.accentColor
        default:               return Color.white.opacity(0.15)
        }
    }
}

struct WatchPatternPicker: View {
    @Binding var selectedPattern: BreathingPattern
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(BreathingPattern.presets) { preset in
                Button {
                    selectedPattern = preset
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preset.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("\(Int(preset.inhale))-\(Int(preset.holdIn))-\(Int(preset.exhale))-\(Int(preset.holdOut))")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.45))
                        }
                        Spacer()
                        if selectedPattern.id == preset.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(BreathingPhase.inhale.accentColor)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Vzor")
    }
}
