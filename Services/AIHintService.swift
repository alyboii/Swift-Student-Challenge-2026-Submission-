import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - AI Hint Service
// Uses Foundation Models for on-device hints. Falls back to static hints
// when Apple Intelligence is unavailable or FoundationModels is not present.

@MainActor
final class AIHintService {
    static let shared = AIHintService()
    private init() {}

#if canImport(FoundationModels)

    private var session: LanguageModelSession?

    // MARK: - Availability

    /// Returns true if Apple Intelligence is enabled AND the device supports it
    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    // MARK: - Generate Hint

    /// Generates an async AI hint. Returns nil on failure/unavailability — caller uses static fallback.
    func generateHint(remaining: Int, selectedCoins: [CoinDenomination]) async -> String? {
        guard isAvailable else { return nil }

        // Lazy session init — child-friendly system instructions
        if session == nil {
            session = LanguageModelSession(
                model: .default,
                instructions: """
                    You are a warm, friendly helper for children aged 6–10 learning about money.
                    Rules: One sentence only. Maximum 12 words. Use simple vocabulary.
                    Encouraging tone. Never reveal the exact answer. Never use math symbols.
                    Example good hint: "You're close! Try a smaller coin this time."
                    """
            )
        }

        let coinDesc = selectedCoins.isEmpty
            ? "no coins yet"
            : selectedCoins.map { "\($0.rawValue) coin" }.joined(separator: ", ")

        let prompt = "Child has: \(coinDesc). They still need \(remaining) more. Give one hint only."

        do {
            let response = try await session!.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            // Reasonable length check — fall back if too short or too long
            guard text.count > 4, text.count < 100 else { return nil }
            return text
        } catch {
            session = nil   // Reset — retry on next call
            return nil
        }
    }

    // MARK: - Session Feedback

    /// Generates a warm, personalised end-of-session message for the Summary screen.
    /// Returns nil on failure — caller shows dadsReaction fallback instead.
    func generateSessionFeedback(
        sessionCorrect: Int,
        sessionAttempts: Int,
        totalCorrectChangeSaved: Int,
        gamesPlayed: Int
    ) async -> String? {
        guard isAvailable else { return nil }

        let accuracy = sessionAttempts == 0 ? "no attempts yet"
            : "\(sessionCorrect) correct out of \(sessionAttempts)"
        let prompt = """
            A child (age 6–10) just finished a canteen coin-change game. \
            Session result: \(accuracy). \
            Total correct change given across all games: \(totalCorrectChangeSaved) coins. \
            Games played: \(gamesPlayed). \
            Write ONE warm, encouraging sentence (max 15 words). \
            Use simple words. Refer to their "canteen hero" journey. \
            Never state raw numbers — use "lots" or "a little" instead.
            """

        // Separate session to avoid contaminating the hint context
        let feedbackSession = LanguageModelSession(
            model: .default,
            instructions: "You are a warm, encouraging coach for children aged 6–10. Keep it short and joyful."
        )
        do {
            let response = try await feedbackSession.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard text.count > 4, text.count < 120 else { return nil }
            return text
        } catch {
            return nil
        }
    }

    // MARK: - Reset

    /// Clear session — called when a new game starts
    func resetSession() { session = nil }

#else

    // MARK: - Stub (FoundationModels not available on this platform/SDK)

    var isAvailable: Bool { false }

    func generateHint(remaining: Int, selectedCoins: [CoinDenomination]) async -> String? { nil }

    func generateSessionFeedback(
        sessionCorrect: Int,
        sessionAttempts: Int,
        totalCorrectChangeSaved: Int,
        gamesPlayed: Int
    ) async -> String? { nil }

    func resetSession() {}

#endif
}
