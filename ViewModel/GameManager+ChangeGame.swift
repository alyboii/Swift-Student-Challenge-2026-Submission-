import SwiftUI

// MARK: - Change Game Logic

extension GameManager {

    func addCoin(_ coin: CoinDenomination) {
        guard selectedCoins.count < 40 else { return }
        guard selectedTotal + coin.rawValue <= changeTarget * 3 else { return }
        selectedCoins.append(coin)
        HapticService.shared.coinTap()
        HapticService.shared.playCoinSound()
        // Real-time over-limit feedback only.
        // Correct answer is gated behind the "Check Answer" button —
        // children need to confirm deliberately, not have the screen
        // hijacked the instant they place their last coin.
        if selectedTotal > changeTarget {
            changeResult = .tooMuch
            HapticService.shared.tooMuchChange()
            HapticService.shared.playWrongSound()
            SpeechService.shared.tooMuchChange()
        } else {
            changeResult = nil
        }
    }

    func removeCoin(at index: Int) {
        guard index < selectedCoins.count else { return }
        selectedCoins.remove(at: index)
        changeResult = nil
    }

    func clearCoins() {
        selectedCoins = []
        changeResult = nil
        aiHintText = ""
        isGeneratingAIHint = false
    }

    func evaluateAnswer() {
        // Track every "Check Answer" tap — correct or not
        sessionAttempts += 1
        totalAttempts += 1

        if selectedTotal == changeTarget {
            sessionCorrect += 1
            totalCorrectAttempts += 1
            totalCorrectChangeSaved += changeTarget   // Social impact accumulator
            changeResult = .correct
            HapticService.shared.correctChange()
            HapticService.shared.playCorrectSound()
            unlockAchievement(id: "change_master")
            // Independent Thinker: correct without requesting any hint
            if !hintUsed {
                unlockAchievement(id: "no_hint_hero")
            }
            // Mix & Match: used 3 or more distinct coin denominations
            if Set(selectedCoins.map(\.rawValue)).count >= 3 {
                unlockAchievement(id: "coin_mix")
            }
            SpeechService.shared.correctChange()
            UIAccessibility.post(
                notification: .announcement,
                argument: "Correct! You gave \(changeTarget) coins change. Well done, Canteen Hero!"
            )
        } else if selectedTotal > changeTarget {
            changeResult = .tooMuch
            HapticService.shared.tooMuchChange()
            HapticService.shared.playWrongSound()
            SpeechService.shared.tooMuchChange()
            UIAccessibility.post(
                notification: .announcement,
                argument: "Too many coins. Remove some and try again."
            )
        } else {
            changeResult = nil
        }
    }

    func getHint() -> String {
        hintUsed = true
        aiHintText = ""
        let remaining = changeTarget - selectedTotal
        if remaining <= 0 { return "You've got the right amount! ✅" }

        let staticHint: String
        if let bestCoin = CoinDenomination.allCases
            .filter({ $0.rawValue <= remaining })
            .max(by: { $0.rawValue < $1.rawValue }) {
            staticHint = "Try adding a \(bestCoin.rawValue) coin! You still need \(remaining) more."
        } else {
            staticHint = "You need \(remaining) more. Try smaller coins!"
        }
        SpeechService.shared.hint(staticHint)
        Task { await requestAIHint(remaining: remaining) }
        return staticHint
    }

    func requestAIHint(remaining: Int) async {
        guard AIHintService.shared.isAvailable else { return }
        isGeneratingAIHint = true
        if let aiHint = await AIHintService.shared.generateHint(remaining: remaining, selectedCoins: selectedCoins) {
            withAnimation(.spring(duration: 0.4)) {
                aiHintText = aiHint
                isGeneratingAIHint = false
            }
            SpeechService.shared.hint(aiHint)
        } else {
            isGeneratingAIHint = false
        }
    }
}
