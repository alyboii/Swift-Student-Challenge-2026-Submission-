import SwiftUI
import FoundationModels

// MARK: - AI Hint Service
// on-device AI hints using Foundation Models, with static fallback

@MainActor
final class AIHintService {
    static let shared = AIHintService()
    private init() {}

    private var session: LanguageModelSession?

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    // MARK: - Generate Hint

    func generateHint(remaining: Int, selectedCoins: [CoinDenomination]) async -> String? {
        guard isAvailable else { return nil }

        if session == nil {
            session = LanguageModelSession()
        }

        let coinDesc = selectedCoins.isEmpty
            ? "no coins yet"
            : selectedCoins.map { "\($0.rawValue) coin" }.joined(separator: ", ")

        let prompt = "A child is giving change and needs \(remaining) more coins. They have: \(coinDesc). Give one short encouraging hint, max 12 words, no numbers."

        do {
            let response = try await session!.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard text.count > 4, text.count < 100 else { return nil }
            return text
        } catch {
            session = nil
            return nil
        }
    }

    // MARK: - Session Feedback

    func generateSessionFeedback(
        sessionCorrect: Int,
        sessionAttempts: Int,
        totalCorrectChangeSaved: Int,
        gamesPlayed: Int
    ) async -> String? {
        guard isAvailable else { return nil }

        let result = sessionAttempts == 0
            ? "no attempts"
            : "\(sessionCorrect) out of \(sessionAttempts) correct"

        let prompt = "A child just finished a canteen money game: \(result). Write one short encouraging sentence, max 15 words, simple words."

        do {
            if session == nil { session = LanguageModelSession() }
            let response = try await session!.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard text.count > 4, text.count < 120 else { return nil }
            return text
        } catch {
            return nil
        }
    }

    // MARK: - Reset

    func resetSession() { session = nil }
}
