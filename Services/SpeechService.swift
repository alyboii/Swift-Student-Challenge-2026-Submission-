import AVFoundation
import SwiftUI

// MARK: - Speech Service
// handles all the spoken narration in the app

@MainActor
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    private var isEnabled: Bool = true

    private init() {}

    // MARK: - Speak

    func speak(_ text: String) {
        guard isEnabled else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }

        let utterance = AVSpeechUtterance(string: text)
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

    // MARK: - Scripted Lines

    // Splash screen welcome
    func welcomeCanteen() {
        speak("Welcome to Canteen Hero!")
    }

    // Story screen — transition to canteen
    func letsGoToCanteen() {
        speak("Let's go to the canteen!")
    }

    // Canteen — product purchased
    func purchasedProduct(_ name: String) {
        speak("Great choice! You picked \(name).")
    }

    // Change game — prompt
    func askForChange(amount: Int) {
        speak("How much change should you get back? Make \(amount) coins!")
    }

    // Change game — correct!
    func correctChange() {
        speak("Perfect! You got the right change! Amazing!")
    }

    // Change game — too much
    func tooMuchChange() {
        speak("Oops! That's too many coins. Try removing some.")
    }

    // Change game — hint
    func hint(_ text: String) {
        speak(text)
    }

    // Achievement unlocked
    func achievementUnlocked(_ title: String) {
        speak("Achievement unlocked: \(title)!")
    }

    // Summary screen
    func summaryMessage(saved: Int) {
        if saved > 0 {
            speak("Great job! You saved \(saved) coins today!")
        } else {
            speak("You spent all your coins! Try saving some next time.")
        }
    }

    // Goal setting — goal selected
    func goalSelected(_ goalName: String, sessions: Int) {
        speak("Great goal! Save a little each day and you'll get your \(goalName) in \(sessions) more visits!")
    }

    // MARK: - CoinIntro

    // Transition: StoryView → CoinIntroView
    func letsLearnCoins() {
        speak("First, let's meet your coins!")
    }

    // Plays when each coin drops
    func coinDropped(value: Int) {
        switch value {
        case 1:  speak("Tiny!")
        case 5:  speak("More!")
        case 10: speak("A lot!")
        default: speak("Whoa! So much!")
        }
    }

    // After all coins have been revealed
    func allCoinsRevealed() {
        speak("You know all your coins! Now let's go shopping!")
    }
}
