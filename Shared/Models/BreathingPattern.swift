import Foundation

struct BreathingPattern: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var inhale: Double
    var holdIn: Double
    var exhale: Double
    var holdOut: Double
    var cycles: Int
    var isPreset: Bool

    var totalCycleDuration: Double {
        inhale + holdIn + exhale + holdOut
    }

    var totalSessionDuration: Double {
        totalCycleDuration * Double(cycles)
    }

    static let sikuta = BreathingPattern(
        name: "Šikutova metóda",
        description: "4-7-8 dýchanie pre hlbokú relaxáciu a zníženie stresu",
        inhale: 4,
        holdIn: 7,
        exhale: 8,
        holdOut: 0,
        cycles: 8,
        isPreset: true
    )

    static let box = BreathingPattern(
        name: "Box dýchanie",
        description: "Rovnomerné 4-4-4-4, používané pre sústredenie a upokojenie",
        inhale: 4,
        holdIn: 4,
        exhale: 4,
        holdOut: 4,
        cycles: 8,
        isPreset: true
    )

    static let relaxation = BreathingPattern(
        name: "Relaxačné",
        description: "Predĺžený výdych pre rýchle upokojenie nervovej sústavy",
        inhale: 4,
        holdIn: 0,
        exhale: 6,
        holdOut: 2,
        cycles: 10,
        isPreset: true
    )

    static let energizing = BreathingPattern(
        name: "Energizačné",
        description: "Krátke cykly pre zvýšenie energie a bdelosť",
        inhale: 6,
        holdIn: 2,
        exhale: 2,
        holdOut: 0,
        cycles: 12,
        isPreset: true
    )

    static let presets: [BreathingPattern] = [.sikuta, .box, .relaxation, .energizing]

    static var custom = BreathingPattern(
        name: "Vlastné",
        description: "Upravte časovanie podľa seba",
        inhale: 4,
        holdIn: 4,
        exhale: 4,
        holdOut: 4,
        cycles: 8,
        isPreset: false
    )
}
