import SwiftUI
import SwiftData

// MARK: - SwiftData Persistence
// Saves and loads the single GameState record from the SwiftData store.

extension GameManager {

    /// Call from ContentView.onAppear to bind the model context and load saved state
    func setup(with context: ModelContext) {
        self.modelContext = context
        loadState()
    }

    func saveState() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<GameState>()
        let state: GameState
        if let existing = try? context.fetch(descriptor).first {
            state = existing
        } else {
            state = GameState()
            context.insert(state)
        }

        state.budget = budget
        state.gamesPlayed = gamesPlayed
        state.tutorialSeen = tutorialSeen
        state.coinIntroSeen = coinIntroSeen
        state.unlockedAchievementIds = achievements.filter(\.isUnlocked).map(\.id)

        if let data = try? JSONEncoder().encode(purchases) {
            state.purchasesData = data
        }

        // Learning analytics
        state.totalAttempts = totalAttempts
        state.totalCorrectAttempts = totalCorrectAttempts
        state.totalCorrectChangeSaved = totalCorrectChangeSaved
        var history = sessionAccuracyHistory
        history.append(sessionAccuracy)
        if history.count > 10 { history = Array(history.suffix(10)) }
        sessionAccuracyHistory = history
        state.sessionAccuracyData = (try? JSONEncoder().encode(history)) ?? Data()

        try? context.save()
    }

    func loadState() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<GameState>()
        guard let state = try? context.fetch(descriptor).first else { return }

        budget = state.budget
        gamesPlayed = state.gamesPlayed
        tutorialSeen = state.tutorialSeen
        coinIntroSeen = state.coinIntroSeen

        // Merge: start from Achievement.all, apply saved unlock states
        // → future new achievements won't be lost when loading old saves
        var merged = Achievement.all
        let unlockedIds = Set(state.unlockedAchievementIds)
        for i in merged.indices where unlockedIds.contains(merged[i].id) {
            merged[i].isUnlocked = true
        }
        achievements = merged

        if let saved = try? JSONDecoder().decode([Purchase].self, from: state.purchasesData) {
            purchases = saved
        }

        // Learning analytics
        totalAttempts = state.totalAttempts
        totalCorrectAttempts = state.totalCorrectAttempts
        totalCorrectChangeSaved = state.totalCorrectChangeSaved
        sessionAccuracyHistory = (try? JSONDecoder().decode([Double].self,
            from: state.sessionAccuracyData)) ?? []
    }
}
