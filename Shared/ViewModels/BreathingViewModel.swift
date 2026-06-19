import Foundation
import Combine
import SwiftUI

enum SessionState: Equatable {
    case idle
    case active
    case paused
    case complete
}

final class BreathingViewModel: ObservableObject {
    @Published var state: SessionState = .idle
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var timeRemaining: Double = 0
    @Published var currentCycle: Int = 0
    @Published var pattern: BreathingPattern = .sikuta

    var animationDuration: Double {
        switch currentPhase {
        case .inhale:  return pattern.inhale
        case .exhale:  return pattern.exhale
        case .holdIn, .holdOut: return 0.25
        }
    }

    var progress: Double {
        guard pattern.cycles > 0 else { return 0 }
        return Double(currentCycle) / Double(pattern.cycles)
    }

    var isActive: Bool { state == .active }
    var isComplete: Bool { state == .complete }

    private var timer: AnyCancellable?
    let audioManager = AudioManager()

    func start() {
        state = .active
        currentCycle = 0
        begin(phase: .inhale)
    }

    func stop() {
        timer?.cancel()
        audioManager.stop()
        state = .idle
        currentPhase = .inhale
        timeRemaining = 0
        currentCycle = 0
    }

    func pause() {
        guard state == .active else { return }
        timer?.cancel()
        audioManager.stop()
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        state = .active
        tick()
    }

    private func begin(phase: BreathingPhase) {
        let duration = self.duration(for: phase)

        if duration <= 0 {
            advance(from: phase)
            return
        }

        currentPhase = phase
        timeRemaining = duration
        audioManager.playTone(for: phase)
        audioManager.speak(phase.localizedName)

        scheduleTimer()
    }

    private func scheduleTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        timeRemaining -= 0.05
        if timeRemaining <= 0 {
            timer?.cancel()
            advance(from: currentPhase)
        }
    }

    private func advance(from phase: BreathingPhase) {
        switch phase {
        case .inhale:
            begin(phase: .holdIn)
        case .holdIn:
            begin(phase: .exhale)
        case .exhale:
            begin(phase: .holdOut)
        case .holdOut:
            completeCycle()
        }
    }

    private func completeCycle() {
        currentCycle += 1
        if currentCycle >= pattern.cycles {
            timer?.cancel()
            state = .complete
            audioManager.speakSessionComplete()
        } else {
            begin(phase: .inhale)
        }
    }

    private func duration(for phase: BreathingPhase) -> Double {
        switch phase {
        case .inhale:  return pattern.inhale
        case .holdIn:  return pattern.holdIn
        case .exhale:  return pattern.exhale
        case .holdOut: return pattern.holdOut
        }
    }
}
