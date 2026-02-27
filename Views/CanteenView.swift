import SwiftUI

// MARK: - Canteen View

struct CanteenView: View {
    @Environment(GameManager.self) private var game
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var columns: [GridItem] {
        let count = sizeClass == .regular ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: CanteenSpacing.m), count: count)
    }

    @State private var tutorialStep: Int = 0

    var body: some View {
        ZStack {
            CanteenMeshGradient()

            VStack(spacing: 0) {
                canteenHeader

                ScrollView {
                    VStack(spacing: CanteenSpacing.l) {
                        BudgetHeaderView()
                            .padding(.horizontal, CanteenSpacing.l)

                        if let goal = game.selectedGoal {
                            GoalProgressPill(goal: goal, savedCoins: game.budget)
                                .padding(.horizontal, CanteenSpacing.l)
                        }

                        menuSection

                        if !game.purchases.isEmpty {
                            purchaseHistorySection
                            goToSummaryButton
                        }

                        Spacer(minLength: CanteenSpacing.xl)
                    }
                    .padding(.vertical, CanteenSpacing.m)
                }
            }

            if tutorialStep > 0 {
                TutorialOverlayView(step: $tutorialStep) {
                    game.tutorialSeen = true
                    withAnimation(.easeOut(duration: 0.25)) { tutorialStep = 0 }
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: tutorialStep)
        .onAppear {
            if !game.tutorialSeen {
                Task {
                    try? await Task.sleep(for: .seconds(0.8))
                    withAnimation { tutorialStep = 1 }
                }
            } else {
                SpeechService.shared.speak("Welcome back to the canteen! Pick something to buy!", rate: 0.44, pitch: 1.1)
            }
        }
    }

    // MARK: Header

    private var canteenHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("🏪 The Canteen")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.cikolataKahvesi)
                    .accessibilityAddTraits(.isHeader)
                Text("Tap to buy, then calculate change!")
                    .font(CanteenTypography.caption)
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                // Budget badge — SF Symbol coin
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.simitSarisi)
                        .symbolEffect(.bounce, value: game.budget)
                    Text("\(game.budget)")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.cikolataKahvesi)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.3), value: game.budget)
                }
                .padding(.horizontal, CanteenSpacing.m)
                .padding(.vertical, CanteenSpacing.s)
                .glassEffect(in: .capsule)
                .accessibilityLabel("\(game.budget) coins remaining")

                if let goal = game.selectedGoal {
                    HStack(spacing: 3) {
                        Text(goal.emoji).font(.system(size: 13))
                        Text(goal.name)
                            .font(.system(.caption2, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.basariYesili)
                    }
                    .accessibilityLabel("Saving for \(goal.name)")
                }
            }
        }
        .padding(.horizontal, CanteenSpacing.l)
        .padding(.vertical, CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: 0))
    }

    // MARK: Menu Grid

    private var menuSection: some View {
        VStack(alignment: .leading, spacing: CanteenSpacing.m) {
            Text("Today's Menu")
                .font(CanteenTypography.sectionTitle)
                .foregroundStyle(Color.cikolataKahvesi)
                .padding(.horizontal, CanteenSpacing.l)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: columns, spacing: CanteenSpacing.m) {
                ForEach(Array(Product.menu.enumerated()), id: \.element.id) { index, product in
                    ProductCardView(product: product, entranceDelay: Double(index) * 0.08) {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        game.buyProduct(product)
                    }
                }
            }
            .padding(.horizontal, CanteenSpacing.l)
        }
    }

    // MARK: Purchase History

    private var purchaseHistorySection: some View {
        VStack(alignment: .leading, spacing: CanteenSpacing.s) {
            Text("Your Tray 🍽️")
                .font(CanteenTypography.sectionTitle)
                .foregroundStyle(Color.cikolataKahvesi)
                .padding(.horizontal, CanteenSpacing.l)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: CanteenSpacing.s) {
                ForEach(game.purchases) { purchase in
                    HStack(spacing: CanteenSpacing.m) {
                        Text(purchase.product.emoji)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(purchase.product.accentColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.s))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(purchase.product.name)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color.cikolataKahvesi)
                            Text(purchase.product.englishName)
                                .font(CanteenTypography.caption)
                                .foregroundStyle(Color.cikolataKahvesi.opacity(0.45))
                        }

                        Spacer()

                        // Cost with SF Symbol coin
                        HStack(spacing: 2) {
                            Text("−\(purchase.product.price)")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.hataKirmizisi)
                            Image(systemName: "circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.simitSarisi)
                        }
                    }
                    .padding(CanteenSpacing.m)
                    .glassEffect(in: .rect(cornerRadius: CanteenRadius.m))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(purchase.product.englishName), cost \(purchase.product.price) coins")
                }
            }
            .padding(.horizontal, CanteenSpacing.l)

            // Undo last purchase button
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                    game.undoLastPurchase()
                }
            } label: {
                Label("Undo Last Purchase", systemImage: "arrow.uturn.backward")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.canteenGhost)
            .padding(.horizontal, CanteenSpacing.l)
            .accessibilityLabel("Undo last purchase")
            .accessibilityHint("Removes the last item you bought and returns the coins")
        }
    }

    // MARK: Summary Button

    private var goToSummaryButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            game.navigate(to: .summary)
        } label: {
            Label("See My Results", systemImage: "chart.bar.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.canteenPrimary)
        .padding(.horizontal, CanteenSpacing.l)
        .accessibilityLabel("See My Results")
        .accessibilityHint("View your spending chart and earned achievements")
    }
}

// MARK: - Budget Header

struct BudgetHeaderView: View {
    @Environment(GameManager.self) private var game

    var body: some View {
        VStack(spacing: CanteenSpacing.s) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Budget")
                        .font(CanteenTypography.caption)
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(game.budget)")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.cikolataKahvesi)
                            .contentTransition(.numericText())
                            .animation(.spring(duration: 0.35), value: game.budget)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.simitSarisi)
                            .symbolEffect(.bounce, value: game.budget)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Spent")
                        .font(CanteenTypography.caption)
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
                    HStack(spacing: 4) {
                        Text("\(game.totalSpent)")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.tostTuruncusu)
                            .contentTransition(.numericText())
                            .animation(.spring(duration: 0.35), value: game.totalSpent)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.simitSarisi)
                    }
                }
            }

            // Budget progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.cikolataKahvesi.opacity(0.08))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(LinearGradient(
                            colors: Color.prideColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * game.budgetFraction, height: 10)
                        .animation(.spring(duration: 0.55, bounce: 0.15), value: game.budgetFraction)
                }
            }
            .frame(height: 10)

            HStack {
                CoinAmountLabel(
                    amount: 0,
                    amountColor: Color.cikolataKahvesi.opacity(0.35)
                )
                Spacer()
                CoinAmountLabel(
                    amount: game.startingBudget,
                    amountColor: Color.cikolataKahvesi.opacity(0.35)
                )
            }
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Budget: \(game.budget) coins remaining out of \(game.startingBudget). You've spent \(game.totalSpent) coins.")
    }
}

// MARK: - Product Card with KeyframeAnimator entrance

struct ProductCardView: View {
    let product: Product
    var entranceDelay: Double = 0
    let onBuy: () -> Void

    @Environment(GameManager.self) private var game
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var canAfford: Bool { game.budget >= product.price }

    private struct CardAnimValues {
        var scale: Double = 0.82
        var opacity: Double = 0.0
        var yOffset: CGFloat = 24
    }

    var body: some View {
        VStack(spacing: CanteenSpacing.s) {
            Text(product.emoji)
                .font(.system(size: 52))
                .scaleEffect(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.5))
                .animation(.spring(duration: 0.5, bounce: 0.45).delay(entranceDelay + 0.1), value: appeared)

            VStack(spacing: 2) {
                Text(product.name)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.cikolataKahvesi)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(product.englishName)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.50))
                    .lineLimit(1)
            }

            // Price with SF Symbol coin
            CoinAmountLabel(
                amount: product.price,
                font: .system(.headline, design: .rounded, weight: .bold),
                amountColor: canAfford ? Color.cikolataKahvesi : Color.cikolataKahvesi.opacity(0.30)
            )
            .lineLimit(1)

            buyButton
        }
        .padding(CanteenSpacing.l)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .opacity(canAfford ? 1.0 : 0.55)
        .keyframeAnimator(initialValue: CardAnimValues(), trigger: appeared) { view, val in
            view
                .scaleEffect(val.scale)
                .opacity(val.opacity)
                .offset(y: val.yOffset)
        } keyframes: { _ in
            KeyframeTrack(\.scale) {
                LinearKeyframe(0.82, duration: 0.01)
                SpringKeyframe(1.04, duration: 0.28, spring: .bouncy)
                CubicKeyframe(1.0, duration: 0.14)
            }
            KeyframeTrack(\.opacity) {
                LinearKeyframe(0.0, duration: 0.01)
                LinearKeyframe(1.0, duration: 0.20)
            }
            KeyframeTrack(\.yOffset) {
                LinearKeyframe(24, duration: 0.01)
                SpringKeyframe(0, duration: 0.32, spring: .snappy)
            }
        }
        .onAppear {
            if !reduceMotion {
                Task {
                    try? await Task.sleep(for: .seconds(entranceDelay))
                    appeared = true
                }
            } else {
                appeared = true
            }
        }
    }

    private var buyButton: some View {
        Button {
            guard canAfford else { return }
            onBuy()
        } label: {
            Group {
                if canAfford {
                    Label("Buy", systemImage: "cart.badge.plus")
                } else {
                    HStack(spacing: 4) {
                        Text("Need \(product.price - game.budget) more")
                            .foregroundStyle(Color.hataKirmizisi.opacity(0.70))
                        Image(systemName: "circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.simitSarisi)
                    }
                }
            }
            .font(.system(.callout, design: .rounded, weight: .bold))
            .foregroundStyle(canAfford ? Color.cikolataKahvesi : Color.cikolataKahvesi.opacity(0.50))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(canAfford ? Color.simitSarisi : Color.gray.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
        }
        .disabled(!canAfford)
        .accessibilityLabel("\(product.name), \(product.englishName), costs \(product.price) coins")
        .accessibilityHint(canAfford ? "Double tap to buy" : "Not enough coins. You need \(product.price - game.budget) more.")
    }
}

// MARK: - Tutorial Overlay View

private struct TutorialOverlayView: View {
    @Binding var step: Int
    let onDismiss: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var emojiVisible = false

    private struct StepContent {
        let emoji: String
        let title: String
        let body: String
        let speech: String
    }

    private var content: StepContent {
        switch step {
        case 1:
            return StepContent(
                emoji: "💰",
                title: "Your Budget",
                body: "You have 50 coins to spend at the canteen today! Keep an eye on your budget at the top.",
                speech: "You have 50 coins. Watch your budget at the top of the screen!"
            )
        case 2:
            return StepContent(
                emoji: "🛍️",
                title: "Buy Something!",
                body: "Tap any item on the menu to buy it. The price is shown in coins.",
                speech: "Tap a food item to buy it with your coins."
            )
        case 3:
            return StepContent(
                emoji: "🧮",
                title: "Calculate Change!",
                body: "After buying, you'll get change back. Tap the coins below to build the right amount!",
                speech: "After you buy something, you will need to calculate your change. Tap coins to build the right amount!"
            )
        default:
            return StepContent(emoji: "", title: "", body: "", speech: "")
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: CanteenSpacing.l) {
                Text(content.emoji)
                    .font(.system(size: 60))
                    .scaleEffect(reduceMotion ? 1.0 : (emojiVisible ? 1.0 : 0.4))
                    .opacity(emojiVisible ? 1.0 : 0.0)
                    .animation(
                        reduceMotion ? .none : .spring(duration: 0.5, bounce: 0.45),
                        value: emojiVisible
                    )
                    .onAppear { emojiVisible = true }
                    .onChange(of: step) { _, _ in
                        emojiVisible = false
                        Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(30))
                            emojiVisible = true
                        }
                    }

                VStack(spacing: CanteenSpacing.s) {
                    Text(content.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.cikolataKahvesi)
                        .accessibilityAddTraits(.isHeader)
                    Text(content.body)
                        .font(CanteenTypography.bodyText)
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: CanteenSpacing.s) {
                    ForEach(1...3, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color.simitSarisi : Color.cikolataKahvesi.opacity(0.20))
                            .frame(width: i == step ? 24 : 8, height: 8)
                            .animation(.spring(duration: 0.3), value: step)
                    }
                }
                .accessibilityLabel("Tutorial step \(step) of 3")

                HStack(spacing: CanteenSpacing.m) {
                    Button("Skip") {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onDismiss()
                    }
                    .buttonStyle(.canteenGhost)
                    .accessibilityLabel("Skip tutorial")

                    Button(step < 3 ? "Next →" : "Let's go! 🏪") {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        if step < 3 {
                            withAnimation(.spring(duration: 0.3)) { step += 1 }
                            SpeechService.shared.speak(content.speech, rate: 0.44, pitch: 1.1)
                        } else {
                            onDismiss()
                        }
                    }
                    .buttonStyle(.canteenPrimary)
                    .accessibilityLabel(step < 3 ? "Next tutorial step" : "Start shopping")
                }
            }
            .padding(CanteenSpacing.xl)
            .background(.white.opacity(0.97))
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.l + 4))
            .shadow(color: Color.simitSarisi.opacity(0.28), radius: 30, x: 0, y: 14)
            .padding(.horizontal, CanteenSpacing.xl)
        }
        .onAppear {
            SpeechService.shared.speak(content.speech, rate: 0.44, pitch: 1.1)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Goal Progress Pill

struct GoalProgressPill: View {
    let goal: SavingsGoal
    let savedCoins: Int

    private var fraction: Double {
        min(1.0, Double(savedCoins) / Double(goal.cost))
    }

    private var pct: Int { Int(fraction * 100) }

    var body: some View {
        HStack(spacing: CanteenSpacing.m) {
            Text(goal.emoji)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Text("🎯 Saving for:")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.65))
                    Text(goal.name)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.cikolataKahvesi)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.12))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(LinearGradient(
                                colors: Color.prideColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * fraction, height: 8)
                            .animation(.spring(duration: 0.6), value: fraction)
                    }
                }
                .frame(height: 8)
            }

            Spacer()

            // Saved / total with SF Symbol
            VStack(spacing: 2) {
                Text("\(savedCoins)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.basariYesili)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.35), value: savedCoins)
                HStack(spacing: 2) {
                    Text("/ \(goal.cost)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.45))
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.simitSarisi.opacity(0.60))
                }
            }
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Saving for \(goal.name). \(savedCoins) of \(goal.cost) coins saved. \(pct) percent.")
    }
}
