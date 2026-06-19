import SwiftUI
#if os(watchOS)
import WatchKit
#endif

enum BreathingPhase: String, CaseIterable, Codable {
    case inhale
    case holdIn
    case exhale
    case holdOut

    var localizedName: String {
        switch self {
        case .inhale:  return "Nádych"
        case .holdIn:  return "Zadržanie"
        case .exhale:  return "Výdych"
        case .holdOut: return "Pauza"
        }
    }

    var instruction: String {
        switch self {
        case .inhale:  return "Pomaly sa nadýchnite nosom."
        case .holdIn:  return "Zadržte dych."
        case .exhale:  return "Pomaly vydychujte ústami."
        case .holdOut: return "Uvoľnite sa."
        }
    }

    var accentColor: Color {
        switch self {
        case .inhale:  return Color(red: 0.29, green: 0.62, blue: 1.00)
        case .holdIn:  return Color(red: 0.55, green: 0.36, blue: 0.95)
        case .exhale:  return Color(red: 0.06, green: 0.72, blue: 0.56)
        case .holdOut: return Color(red: 0.40, green: 0.45, blue: 0.55)
        }
    }

    var targetScale: CGFloat {
        switch self {
        case .inhale, .holdIn:  return 1.35
        case .exhale, .holdOut: return 0.65
        }
    }

    var frequency: Double {
        switch self {
        case .inhale:  return 432.0
        case .holdIn:  return 528.0
        case .exhale:  return 396.0
        case .holdOut: return 285.0
        }
    }

#if os(watchOS)
    var hapticType: WKHapticType {
        switch self {
        case .inhale:  return .start
        case .holdIn:  return .click
        case .exhale:  return .stop
        case .holdOut: return .click
        }
    }
#endif
}
