import SwiftData
import Foundation

// MARK: - GameState (SwiftData Model)
// Persists game progress between launches. One record per device, updated in-place.

@Model
final class GameState {
    var budget: Int = 50
    var gamesPlayed: Int = 0
    var tutorialSeen: Bool = false
    var coinIntroSeen: Bool = false
    var unlockedAchievementIds: [String] = []
    var purchasesData: Data = Data()

    // MARK: - Learning Analytics (added for session tracking)
    var totalAttempts: Int = 0            // All-time total evaluateAnswer() calls
    var totalCorrectAttempts: Int = 0     // All-time correct answers
    var totalCorrectChangeSaved: Int = 0  // Sum of all correct changeTarget values (social impact)
    var sessionAccuracyData: Data = Data()// JSON-encoded [Double] — last 10 session accuracy rates

    init() {}
}
