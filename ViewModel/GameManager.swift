import SwiftUI
import Observation
import SwiftData

// MARK: - App Screen

enum AppScreen: Equatable {
    case splash
    case story
    case goalPicker
    case coinIntro
    case canteen
    case changeGame
    case summary
    case goalSetting
}

// MARK: - Game Manager (Core)

@MainActor
@Observable
final class GameManager {

    // MARK: Navigation
    var screen: AppScreen = .splash

    // MARK: Budget
    var budget: Int = 50
    let startingBudget: Int = 50

    // MARK: Purchases
    var purchases: [Purchase] = []

    // MARK: Achievements
    var achievements: [Achievement] = Achievement.all

    // MARK: Change Game State
    var currentProduct: Product? = nil
    var paymentAmount: Int = 0
    var changeTarget: Int = 0
    var selectedCoins: [CoinDenomination] = []
    var changeResult: ChangeResult? = nil
    var hintUsed: Bool = false
    var newlyUnlockedIds: Set<String> = []

    // MARK: Difficulty
    var difficulty: DifficultyLevel = .easy

    // MARK: AI Hint State
    var aiHintText: String = ""
    var isGeneratingAIHint: Bool = false

    // MARK: Goal
    var selectedGoal: SavingsGoal? = nil

    // MARK: Persistent State (loaded by SwiftData on setup)
    var gamesPlayed: Int = 0
    var tutorialSeen: Bool = false
    var coinIntroSeen: Bool = false

    // MARK: Analytics (Session)
    var sessionAttempts: Int = 0       // Attempts in current game
    var sessionCorrect: Int = 0        // Correct answers in current game
    var sessionCorrectChangeSaved: Int = 0  // Coins earned from correct change this session

    // MARK: Analytics (Cumulative)
    var totalAttempts: Int = 0
    var totalCorrectAttempts: Int = 0
    var totalCorrectChangeSaved: Int = 0
    var sessionAccuracyHistory: [Double] = []

    // MARK: SwiftData Context (not observed)
    @ObservationIgnored var modelContext: ModelContext? = nil

    // MARK: - Init
    init() {}

    // MARK: - Computed

    var selectedTotal: Int {
        selectedCoins.reduce(0) { $0 + $1.rawValue }
    }

    var budgetFraction: Double {
        guard startingBudget > 0 else { return 0 }
        return Double(budget) / Double(startingBudget)
    }

    var totalSpent: Int {
        purchases.reduce(0) { $0 + $1.product.price }
    }

    var coinsSaved: Int {
        startingBudget - totalSpent
    }

    var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    var sessionAccuracy: Double {
        sessionAttempts == 0 ? 0 : Double(sessionCorrect) / Double(sessionAttempts)
    }

    var lifetimeAccuracy: Double {
        totalAttempts == 0 ? 0 : Double(totalCorrectAttempts) / Double(totalAttempts)
    }

    // MARK: - Navigation

    func navigate(to destination: AppScreen) {
        withAnimation(.spring(duration: 0.4, bounce: 0.1)) {
            screen = destination
        }
    }

    // MARK: - Purchase

    func buyProduct(_ product: Product) {
        guard budget >= product.price else { return }

        budget -= product.price

        let roundDenominations = difficulty.paymentDenominations
        let payment = roundDenominations.first { $0 > product.price } ?? (product.price + (difficulty == .hard ? 20 : 5))
        paymentAmount = payment
        changeTarget = payment - product.price
        currentProduct = product
        selectedCoins = []
        changeResult = nil
        hintUsed = false
        newlyUnlockedIds.removeAll()

        let record = Purchase(product: product, paidWith: payment, change: changeTarget)
        purchases.append(record)
        saveState()

        if purchases.count == 1 { unlockAchievement(id: "first_purchase") }

        HapticService.shared.purchaseConfirm()
        SpeechService.shared.purchasedProduct(product.englishName)
        navigate(to: .changeGame)
    }

    // MARK: - Undo Purchase

    func undoLastPurchase() {
        guard let last = purchases.last else { return }
        budget += last.product.price
        purchases.removeLast()
        // Reset change game state
        currentProduct = nil
        selectedCoins = []
        changeResult = nil
        if screen == .changeGame {
            navigate(to: .canteen)
        }
        saveState()
    }

    // MARK: - Reset

    func reset() {
        budget = startingBudget
        purchases = []
        achievements = Achievement.all
        selectedCoins = []
        currentProduct = nil
        changeResult = nil
        hintUsed = false
        newlyUnlockedIds.removeAll()
        selectedGoal = nil
        difficulty = .easy
        aiHintText = ""
        isGeneratingAIHint = false
        AIHintService.shared.resetSession()
        sessionAttempts = 0
        sessionCorrect = 0
        sessionCorrectChangeSaved = 0
        gamesPlayed += 1
        navigate(to: .splash)
        saveState()
    }

    // go back to canteen — keeps goal and achievements
    func replayCanteen() {
        budget = startingBudget
        purchases = []
        selectedCoins = []
        currentProduct = nil
        changeResult = nil
        hintUsed = false
        newlyUnlockedIds.removeAll()
        aiHintText = ""
        isGeneratingAIHint = false
        AIHintService.shared.resetSession()
        sessionAttempts = 0
        sessionCorrect = 0
        sessionCorrectChangeSaved = 0
        gamesPlayed += 1
        navigate(to: .canteen)
        saveState()
    }
}

// MARK: - SwiftData Persistence

extension GameManager {

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

        // merge saved unlock states into the current achievement list
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
