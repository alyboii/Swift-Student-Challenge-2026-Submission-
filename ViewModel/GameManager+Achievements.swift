import SwiftUI

// MARK: - Achievements & Goals

extension GameManager {

    func unlockAchievement(id: String) {
        guard let index = achievements.firstIndex(where: { $0.id == id && !$0.isUnlocked }) else { return }
        withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
            achievements[index].isUnlocked = true
        }
        newlyUnlockedIds.insert(achievements[index].id)
        saveState()
        HapticService.shared.achievementUnlock()
        HapticService.shared.playCelebrationSound()
        UIAccessibility.post(notification: .announcement, argument: "Achievement unlocked: \(achievements[index].title)")
        SpeechService.shared.achievementUnlocked(achievements[index].title)
    }

    func checkSmartSaverAchievement() {
        guard !purchases.isEmpty else { return }
        if totalSpent < 20 { unlockAchievement(id: "smart_saver") }
        if budget >= 30 { unlockAchievement(id: "budget_master") }
    }

    func selectGoal(_ goal: SavingsGoal) {
        selectedGoal = goal
        let sessions = goal.sessionsNeeded(coinsPerSession: max(coinsSaved, 1))
        SpeechService.shared.goalSelected(goal.name, sessions: sessions)
    }
}
