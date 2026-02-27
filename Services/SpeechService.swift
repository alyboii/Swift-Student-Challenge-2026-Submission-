import AVFoundation
import SwiftUI

// MARK: - Speech Service
// AVSpeechSynthesizer wrapper. Narrates key moments in a child-friendly tone.

@MainActor
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    private var isEnabled: Bool = true

    private init() {
        configureAudioSession()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers, .mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Silent fail — speech is optional enhancement
        }
    }

    // MARK: - Speak

    func speak(_ text: String, rate: Float = 0.45, pitch: Float = 1.1) {
        guard isEnabled else { return }

        // Don't interrupt ongoing speech for lower priority lines
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = 0.9
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.preUtteranceDelay = 0.1

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled { stop() }
    }

    // MARK: - 🎤 Scripted Lines

    /// Splash screen welcome
    func welcomeCanteen() {
        speak("Welcome to Canteen Hero!", rate: 0.44, pitch: 1.15)
    }

    /// Story screen — transition to canteen
    func letsGoToCanteen() {
        speak("Let's go to the canteen!", rate: 0.46, pitch: 1.1)
    }

    /// Canteen — product purchased
    func purchasedProduct(_ name: String) {
        speak("Great choice! You picked \(name).", rate: 0.45, pitch: 1.05)
    }

    /// Change game — prompt
    func askForChange(amount: Int) {
        speak("How much change should you get back? Make \(amount) coins!", rate: 0.44, pitch: 1.1)
    }

    /// Change game — correct!
    func correctChange() {
        speak("Perfect! You got the right change! Amazing!", rate: 0.48, pitch: 1.2)
    }

    /// Change game — too much
    func tooMuchChange() {
        speak("Oops! That's too many coins. Try removing some.", rate: 0.44, pitch: 1.0)
    }

    /// Change game — hint
    func hint(_ text: String) {
        speak(text, rate: 0.43, pitch: 1.05)
    }

    /// Achievement unlocked
    func achievementUnlocked(_ title: String) {
        speak("Achievement unlocked: \(title)!", rate: 0.46, pitch: 1.15)
    }

    /// Summary screen
    func summaryMessage(saved: Int) {
        if saved > 0 {
            speak("Great job! You saved \(saved) coins today!", rate: 0.45, pitch: 1.1)
        } else {
            speak("You spent all your coins! Try saving some next time.", rate: 0.44, pitch: 1.0)
        }
    }

    /// Goal setting — goal selected
    func goalSelected(_ goalName: String, sessions: Int) {
        speak("Great goal! Save a little each day and you'll get your \(goalName) in \(sessions) more visits!", rate: 0.44, pitch: 1.1)
    }

    // MARK: - 🪙 CoinIntro Narration

    /// Transition: StoryView → CoinIntroView
    func letsLearnCoins() {
        speak("First, let's meet your coins!", rate: 0.45, pitch: 1.15)
    }

    /// Plays when each coin drops — pitch and rate change based on value
    /// value: 1, 5, 10, or 20
    func coinDropped(value: Int) {
        switch value {
        case 1:  speak("Tiny!",            rate: 0.52, pitch: 1.35)
        case 5:  speak("More!",            rate: 0.48, pitch: 1.15)
        case 10: speak("A lot!",           rate: 0.45, pitch: 1.00)
        default: speak("Whoa! So much!",   rate: 0.40, pitch: 0.85)
        }
    }

    /// After all coins have been revealed
    func allCoinsRevealed() {
        speak("You know all your coins! Now let's go shopping!", rate: 0.46, pitch: 1.1)
    }
}
