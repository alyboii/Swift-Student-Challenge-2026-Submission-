import SwiftUI

// MARK: - Summary View

struct SummaryView: View {
    @Environment(GameManager.self) private var game
    @State private var chartAnimated = false
    @State private var badgesRevealed = false
    @State private var emojiAppeared = false
    @State private var showGoalCelebration = false

    var body: some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                CanteenMeshGradient()

                ScrollView {
                    VStack(spacing: CanteenSpacing.l) {
                        heroCard
                        feedbackCard
                        if game.selectedGoal != nil {
                            goalProgressCard
                        }
                        nextStepButtons
                        spendingChartCard
                        achievementsCard
                        Spacer(minLength: CanteenSpacing.xl)
                    }
                    .padding(.horizontal, CanteenSpacing.l)
                    .padding(.top, CanteenSpacing.xl + CanteenSpacing.l)  // back button için yer
                }

                // back button
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    game.navigate(to: .canteen)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Canteen")
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                    }
                    .foregroundStyle(Color.simitSarisi)
                    .padding(.horizontal, CanteenSpacing.m)
                    .padding(.vertical, CanteenSpacing.s)
                    .glassEffect(in: .capsule)
                }
                .padding(.top, CanteenSpacing.xl)
                .padding(.leading, CanteenSpacing.l)
                .accessibilityLabel("Back to Canteen")
                .accessibilityHint("Go back to the canteen to keep shopping")
            }

            // Goal celebration overlay
            if showGoalCelebration, let goal = game.selectedGoal {
                GoalCelebrationOverlay(goal: goal) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showGoalCelebration = false
                    }
                }
                .transition(.opacity)
                .zIndex(20)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showGoalCelebration)
        .onAppear {
            game.checkSmartSaverAchievement()
            game.saveState()
            Task {
                try? await Task.sleep(for: .seconds(0.15))
                emojiAppeared = true
            }
            Task {
                try? await Task.sleep(for: .seconds(0.3))
                withAnimation(.spring(duration: 0.7, bounce: 0.2)) { chartAnimated = true }
            }
            Task {
                try? await Task.sleep(for: .seconds(0.6))
                withAnimation(.spring(duration: 0.5, bounce: 0.15)) { badgesRevealed = true }
            }
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                SpeechService.shared.summaryMessage(saved: game.budget)
            }
            // Show goal celebration if goal reached
            if let goal = game.selectedGoal, game.sessionCorrectChangeSaved >= goal.cost {
                Task {
                    try? await Task.sleep(for: .seconds(1.2))
                    withAnimation { showGoalCelebration = true }
                }
            }
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(spacing: CanteenSpacing.m) {
            Text(trophyEmoji)
                .font(.system(size: 64))
                .scaleEffect(emojiAppeared ? 1.0 : 0.5)
                .opacity(emojiAppeared ? 1.0 : 0.0)
                .animation(.spring(duration: 0.6, bounce: 0.5), value: emojiAppeared)

            Text(heroTitle)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.cikolataKahvesi)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            // Stats row
            HStack(spacing: 0) {
                statBlock(value: "\(game.totalSpent)", unit: "🛍️", label: "Spent",
                          icon: "cart.fill", color: .tostTuruncusu)
                Divider().frame(height: 44)
                statBlock(value: "\(game.budget)", unit: "💰", label: "Saved",
                          icon: "dollarsign.circle.fill", color: .basariYesili)
                Divider().frame(height: 44)
                statBlock(value: "\(game.purchases.count)", unit: "", label: "Items",
                          icon: "bag.fill", color: .simitSarisi)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, CanteenSpacing.xs)

            if game.totalCorrectChangeSaved > 0 {
                HStack(spacing: CanteenSpacing.xs) {
                    Image(systemName: "storefront.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 0.20, green: 0.50, blue: 0.90))
                    Text("All-time correct change: \(game.totalCorrectChangeSaved) coins")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.20, green: 0.50, blue: 0.90).opacity(0.85))
                }
                .padding(.horizontal, CanteenSpacing.s)
                .padding(.vertical, 4)
                .background(Color(red: 0.20, green: 0.50, blue: 0.90).opacity(0.08))
                .clipShape(Capsule())
                .accessibilityLabel("All-time correct change: \(game.totalCorrectChangeSaved) coins")
            }
        }
        .padding(CanteenSpacing.l)
        .frame(maxWidth: .infinity)
        // iOS 26 Liquid Glass hero card
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Summary: Spent \(game.totalSpent) coins, saved \(game.budget) coins, bought \(game.purchases.count) items.")
    }

    private func statBlock(value: String, unit: String, label: String,
                           icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .symbolEffect(.bounce, value: badgesRevealed)
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.cikolataKahvesi)
                Text(unit)
                    .font(.system(size: 18))
            }
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
    }

    private var trophyEmoji: String {
        game.unlockedCount >= 2 ? "🏆" : game.unlockedCount == 1 ? "⭐️" : "🌟"
    }

    private var heroTitle: String {
        if game.unlockedCount >= 2 { return "You're a Canteen Hero! 🏆" }
        if game.budget > 30 { return "Almost a Canteen Hero! ⭐" }
        return "Every coin is a lesson! 💪"
    }

    // MARK: - Feedback Card
    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: CanteenSpacing.m) {
            Label("Savings Tip 💡", systemImage: "lightbulb.fill")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.cikolataKahvesi)

            Text(savingsTipText)
                .font(CanteenTypography.bodyText)
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(5)
        }
        .padding(CanteenSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.simitSarisi.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.l))
        .overlay(
            RoundedRectangle(cornerRadius: CanteenRadius.l)
                .stroke(Color.simitSarisi.opacity(0.25), lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Savings tip: \(savingsTipText)")
    }

    // MARK: - Spending Chart

    private var spendingChartCard: some View {
        VStack(alignment: .leading, spacing: CanteenSpacing.m) {
            Label("What You Bought", systemImage: "cart.fill")
                .font(CanteenTypography.sectionTitle)
                .foregroundStyle(Color.cikolataKahvesi)
                .accessibilityAddTraits(.isHeader)

            if game.purchases.isEmpty {
                Text("No purchases — all saved! 💰")
                    .font(CanteenTypography.bodyText)
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 100)
            } else {
                VStack(spacing: CanteenSpacing.s) {
                    ForEach(game.purchases) { purchase in
                        EmojiSpendingRow(
                            emoji: purchase.product.emoji,
                            name: purchase.product.englishName,
                            price: purchase.product.price,
                            accentColor: purchase.product.accentColor,
                            animated: chartAnimated
                        )
                    }
                }
            }

            // Saved summary bar
            if game.budget > 0 {
                HStack(spacing: CanteenSpacing.s) {
                    Text("🐷")
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You saved!")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.basariYesili)
                        HStack(spacing: 2) {
                            ForEach(0..<min(game.budget, 25), id: \.self) { i in
                                Circle()
                                    .fill(Color.basariYesili)
                                    .frame(width: 8, height: 8)
                                    .opacity(chartAnimated ? 1 : 0)
                                    .animation(
                                        .spring(duration: 0.3).delay(Double(i) * 0.03),
                                        value: chartAnimated
                                    )
                            }
                            if game.budget > 25 {
                                Text("+\(game.budget - 25)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.basariYesili)
                            }
                        }
                    }
                    Spacer()
                    CoinAmountLabel(
                        amount: game.budget,
                        font: .system(.headline, design: .rounded, weight: .bold),
                        amountColor: Color.basariYesili,
                        coinColor: Color.basariYesili
                    )
                }
                .padding(CanteenSpacing.m)
                .background(Color.basariYesili.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
                .accessibilityLabel("You saved \\(game.budget) coins! Well done!")
            }
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
    }

    // MARK: - Achievements

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: CanteenSpacing.m) {
            HStack {
                Label("Achievements", systemImage: "medal.fill")
                    .font(CanteenTypography.sectionTitle)
                    .foregroundStyle(Color.cikolataKahvesi)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text("\(game.unlockedCount)/\(game.achievements.count)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.simitSarisi)
                    .accessibilityLabel("\(game.unlockedCount) out of \(game.achievements.count) achievements unlocked")
            }

            VStack(spacing: CanteenSpacing.s) {
                ForEach(Array(game.achievements.enumerated()), id: \.element.id) { index, achievement in
                    AchievementRowView(achievement: achievement)
                        .opacity(badgesRevealed ? 1 : 0)
                        .offset(y: badgesRevealed ? 0 : 20)
                        .animation(
                            .spring(duration: 0.5, bounce: 0.2).delay(Double(index) * 0.12),
                            value: badgesRevealed
                        )
                }
            }
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
    }

    // MARK: - Savings Tip

    private var savingsTipText: String {
        let saved = game.budget
        if saved >= game.startingBudget {
            return "Incredible — you saved every single coin! 💰 If you did this every day at school, in a week you could treat a friend to a Simit. 🥯 Real heroes share!"
        } else if saved > 25 {
            return "Great work saving \(saved) coins! If you save a little every day at the canteen, you'll reach your dream goal before you know it. Dad would call that smart! 😊"
        } else if saved > 10 {
            return "Good job! You kept \(saved) coins safe. Next time, pause before each snack and ask: \"Is this something I truly need?\" Small choices build big savings! 💪"
        } else {
            return "You spent most of your coins — and that's okay! Every great canteen hero has days like this. The trick is to learn and try again. You've got this! 🌱"
        }
    }

    // MARK: - Goal Progress (Inline)

    private var goalProgressCard: some View {
        let goal = game.selectedGoal!
        let fraction = min(1.0, Double(game.sessionCorrectChangeSaved) / Double(goal.cost))
        let pct = Int(fraction * 100)
        let sessions = goal.sessionsNeeded(coinsPerSession: max(game.sessionCorrectChangeSaved, 1))

        return VStack(spacing: CanteenSpacing.m) {
            Label(
                title: { Text("Your Savings Goal") },
                icon: {
                    Image(systemName: "chart.bar.fill", variableValue: chartAnimated ? fraction : 0)
                }
            )
            .font(CanteenTypography.sectionTitle)
            .foregroundStyle(Color.cikolataKahvesi)
            .accessibilityAddTraits(.isHeader)

            HStack(spacing: CanteenSpacing.m) {
                // Progress ring (compact)
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.12), lineWidth: 10)
                        .frame(width: 80, height: 80)
                    ProgressArc(progress: chartAnimated ? fraction : 0)
                        .stroke(
                            LinearGradient(
                                colors: Color.prideColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .animation(.spring(duration: 1.0, bounce: 0.08), value: chartAnimated)
                    Text("\(pct)%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.cikolataKahvesi)
                }

                VStack(alignment: .leading, spacing: CanteenSpacing.xs) {
                    HStack(spacing: CanteenSpacing.xs) {
                        Text(goal.emoji)
                            .font(.system(size: 22))
                        Text(goal.name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.cikolataKahvesi)
                    }

                    HStack(spacing: 3) {
                        CoinAmountLabel(
                            amount: game.sessionCorrectChangeSaved,
                            font: .system(size: 13, weight: .medium, design: .rounded),
                            amountColor: Color.basariYesili
                        )
                        Text("saved /")
                        CoinAmountLabel(
                            amount: goal.cost,
                            font: .system(size: 13, weight: .medium, design: .rounded),
                            amountColor: Color.cikolataKahvesi.opacity(0.60)
                        )
                        Text("needed")
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.60))

                    Text(goalMessage(sessions: sessions, fraction: fraction))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.basariYesili)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
            }
        }
        .padding(CanteenSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Savings goal: \(goal.name). \(pct) percent reached. \(game.sessionCorrectChangeSaved) of \(goal.cost) coins saved.")
    }

    private func goalMessage(sessions: Int, fraction: Double) -> String {
        if fraction >= 1.0 {
            return "You reached your goal! Champion saver! 🎉"
        } else if sessions == 1 {
            return "One more session to reach your goal! 🚀"
        } else {
            return "About \(sessions) more sessions to go! 💪"
        }
    }

    // MARK: - Next Step Buttons

    private var nextStepButtons: some View {
        VStack(spacing: CanteenSpacing.m) {
            if game.selectedGoal != nil {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    game.navigate(to: .goalSetting)
                } label: {
                    Label("View Goal Details", systemImage: "target")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityLabel("View Goal Details")
                .accessibilityHint("See your full savings goal progress")
            } else {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    game.navigate(to: .goalSetting)
                } label: {
                    Label("Set a Savings Goal 🎯", systemImage: "star.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityLabel("Set a Savings Goal")
                .accessibilityHint("Choose something to save up for")
            }

            // Secondary: Play again
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                game.reset()
            } label: {
                Label("Reset the Game", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityLabel("Reset the Game")
            .accessibilityHint("Start completely over from the beginning")
        }
    }
}

// MARK: - Emoji Spending Row

struct EmojiSpendingRow: View {
    let emoji: String
    let name: String
    let price: Int
    let accentColor: Color
    let animated: Bool

    var body: some View {
        HStack(spacing: CanteenSpacing.m) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 44, height: 44)
                .background(accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.s))

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.cikolataKahvesi)
                    .lineLimit(1)

                HStack(spacing: 2) {
                    ForEach(0..<price, id: \.self) { i in
                        Circle()
                            .fill(Color.simitSarisi)
                            .frame(width: 8, height: 8)
                            .opacity(animated ? 1 : 0)
                            .animation(
                                .spring(duration: 0.3).delay(Double(i) * 0.04),
                                value: animated
                            )
                    }
                }
            }

            Spacer()

            CoinAmountLabel(
                amount: price,
                font: .system(.headline, design: .rounded, weight: .bold),
                amountColor: Color.tostTuruncusu,
                coinColor: Color.simitSarisi
            )
        }
        .padding(CanteenSpacing.s)
        .background(accentColor.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), cost \(price) coins")
    }
}

// MARK: - Achievement Row (with .wiggle SF Symbol effect)

struct AchievementRowView: View {
    let achievement: Achievement
    @State private var drawTriggered = false

    var body: some View {
        HStack(spacing: CanteenSpacing.m) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.prideAccentColor : Color.gray.opacity(0.10))
                    .frame(width: 52, height: 52)
                    .shadow(
                        color: achievement.isUnlocked ? achievement.prideAccentColor.opacity(0.38) : .clear,
                        radius: 8, x: 0, y: 3
                    )

                Image(systemName: achievement.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? .white : Color.gray.opacity(0.35))
                    .symbolEffect(.bounce, value: drawTriggered)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(achievement.isUnlocked ? Color.cikolataKahvesi : Color.cikolataKahvesi.opacity(0.30))

                Text(achievement.subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.45))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: achievement.isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                .font(.system(size: 20))
                .foregroundStyle(achievement.isUnlocked ? Color.basariYesili : Color.gray.opacity(0.28))
        }
        .padding(CanteenSpacing.m)
        .background(achievement.isUnlocked ? achievement.prideAccentColor.opacity(0.07) : Color.gray.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title): \(achievement.subtitle). \(achievement.isUnlocked ? "Unlocked." : "Locked.")")
        .onAppear {
            if achievement.isUnlocked {
                Task {
                    try? await Task.sleep(for: .seconds(0.3))
                    drawTriggered = true
                }
            }
        }
    }
}
