import Foundation
import AVFoundation
#if os(watchOS)
import WatchKit
#endif

final class AudioManager: NSObject, ObservableObject {
    @Published var isToneEnabled = true
    @Published var isSpeechEnabled = true

#if os(iOS)
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var isEngineRunning = false
#endif

    override init() {
        super.init()
#if os(iOS)
        setupAudioSession()
        setupAudioEngine()
#endif
    }

#if os(iOS)
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        do {
            try audioEngine.start()
            isEngineRunning = true
        } catch {
            print("Audio engine error: \(error)")
        }
    }
#endif

    func playTone(for phase: BreathingPhase, duration: Double = 0.6) {
#if os(iOS)
        guard isToneEnabled, isEngineRunning else { return }
        guard let buffer = generateTone(frequency: phase.frequency, duration: duration) else { return }
        playerNode.stop()
        playerNode.scheduleBuffer(buffer)
        playerNode.play()
#elseif os(watchOS)
        WKInterfaceDevice.current().play(phase.hapticType)
#endif
    }

    func speak(_ text: String) {
#if os(iOS)
        guard isSpeechEnabled else { return }
        speechSynthesizer.stopSpeaking(at: .word)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "sk-SK")
            ?? AVSpeechSynthesisVoice(language: "cs-CZ")
        utterance.rate = 0.44
        utterance.volume = 0.85
        utterance.pitchMultiplier = 1.0
        speechSynthesizer.speak(utterance)
#endif
    }

    func speakSessionComplete() {
        speak("Výborne! Cvičenie je ukončené. Zostaňte v pokoji ešte chvíľu.")
    }

    func stop() {
#if os(iOS)
        playerNode.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
#endif
    }

#if os(iOS)
    private func generateTone(frequency: Double, duration: Double) -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1]
        else { return nil }

        buffer.frameLength = frameCount
        let fadeLength = max(1, Int(sampleRate * 0.06))
        let total = Int(frameCount)

        for i in 0..<total {
            let t = Double(i) / sampleRate
            var sample = Float(sin(2.0 * Double.pi * frequency * t)) * 0.22

            if i < fadeLength {
                sample *= Float(i) / Float(fadeLength)
            } else if i > total - fadeLength {
                sample *= Float(total - i) / Float(fadeLength)
            }

            left[i] = sample
            right[i] = sample
        }
        return buffer
    }
#endif
}
