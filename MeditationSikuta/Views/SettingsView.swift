import SwiftUI

struct SettingsView: View {
    @Binding var pattern: BreathingPattern
    @ObservedObject var audioManager: AudioManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPreset: BreathingPattern = .sikuta
    @State private var customPattern: BreathingPattern = .custom
    @State private var useCustom = false

    var body: some View {
        NavigationView {
            ZStack {
                background
                ScrollView {
                    VStack(spacing: 24) {
                        presetSection
                        customSection
                        audioSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Nastavenia")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hotovo") {
                        pattern = useCustom ? customPattern : selectedPreset
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if pattern.isPreset {
                selectedPreset = pattern
                useCustom = false
            } else {
                customPattern = pattern
                useCustom = true
            }
        }
    }

    private var background: some View {
        Color(red: 0.06, green: 0.07, blue: 0.14)
            .ignoresSafeArea()
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Predvolené vzory")

            ForEach(BreathingPattern.presets) { preset in
                PresetCard(
                    preset: preset,
                    isSelected: !useCustom && selectedPreset.id == preset.id
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPreset = preset
                        useCustom = false
                    }
                }
            }
        }
    }

    private var customSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                sectionHeader("Vlastné nastavenie")
                Spacer()
                Toggle("", isOn: $useCustom)
                    .labelsHidden()
            }

            if useCustom {
                VStack(spacing: 16) {
                    TimingRow(label: "Nádych", value: $customPattern.inhale, color: BreathingPhase.inhale.accentColor)
                    TimingRow(label: "Zadržanie", value: $customPattern.holdIn, color: BreathingPhase.holdIn.accentColor)
                    TimingRow(label: "Výdych", value: $customPattern.exhale, color: BreathingPhase.exhale.accentColor)
                    TimingRow(label: "Pauza", value: $customPattern.holdOut, color: BreathingPhase.holdOut.accentColor)

                    HStack {
                        Text("Počet cyklov")
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Stepper("\(customPattern.cycles)", value: $customPattern.cycles, in: 1...30)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(cardBackground)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Zvuk a hlas")

            VStack(spacing: 0) {
                Toggle(isOn: $audioManager.isToneEnabled) {
                    Label("Zvukové tóny", systemImage: "music.note")
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding()
                .tint(Color(red: 0.29, green: 0.62, blue: 1.0))

                Divider().background(.white.opacity(0.1))

                Toggle(isOn: $audioManager.isSpeechEnabled) {
                    Label("Hlasové pokyny", systemImage: "speaker.wave.2")
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding()
                .tint(Color(red: 0.29, green: 0.62, blue: 1.0))
            }
            .background(cardBackground)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white.opacity(0.5))
            .textCase(.uppercase)
            .tracking(0.5)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(0.07))
    }
}

struct PresetCard: View {
    let preset: BreathingPattern
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(preset.description)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.55))

                HStack(spacing: 8) {
                    phaseTag("↑ \(Int(preset.inhale))s", color: BreathingPhase.inhale.accentColor)
                    if preset.holdIn > 0 {
                        phaseTag("⏸ \(Int(preset.holdIn))s", color: BreathingPhase.holdIn.accentColor)
                    }
                    phaseTag("↓ \(Int(preset.exhale))s", color: BreathingPhase.exhale.accentColor)
                    if preset.holdOut > 0 {
                        phaseTag("⏸ \(Int(preset.holdOut))s", color: BreathingPhase.holdOut.accentColor)
                    }
                }
                .padding(.top, 4)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(BreathingPhase.inhale.accentColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected
                    ? Color.white.opacity(0.12)
                    : Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected
                            ? BreathingPhase.inhale.accentColor.opacity(0.6)
                            : Color.clear,
                            lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private func phaseTag(_ label: String, color: Color) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

struct TimingRow: View {
    let label: String
    @Binding var value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 8, height: 8)

            Text(label)
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 90, alignment: .leading)

            Slider(value: $value, in: 0...20, step: 0.5)
                .tint(color)

            Text(String(format: "%.0fs", value))
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 34, alignment: .trailing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.07))
        )
    }
}
