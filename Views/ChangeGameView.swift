import SwiftUI

// MARK: - Change Game View

struct ChangeGameView: View {
    @Environment(GameManager.self) private var game
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showHint = false
    @State private var hintText = ""
    @State private var showConfetti = false
    @State private var isDragOverTray: Bool = false

    // MARK: - Layout Helpers

    /// iPad (regular width) — portrait or landscape
    private var isIPad: Bool { hSizeClass == .regular }
    /// iPad landscape — use two-column layout
    private var isLandscape: Bool { hSizeClass == .regular && vSizeClass == .compact }
    /// Coin button size — bigger on iPad for better tap targets
    private var coinSize: CGFloat { isIPad ? 80 : 64 }

    private var shouldRevealTarget: Bool {
        switch game.difficulty {
        case .easy:   return true
        case .medium: return showHint  // only reveals when child explicitly asks for a hint
        case .hard:   return false
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            CanteenMeshGradient()

            VStack(spacing: 0) {
                changeHeader

                if isLandscape {
                    iPadLandscapeLayout
                } else {
                    portraitLayout
                }
            }

            if game.changeResult == .correct {
                ChangeSuccessOverlay(showHint: $showHint, showConfetti: $showConfetti)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .scale(scale: 0.85, anchor: .center))
                    )
            }

            ConfettiView(isActive: showConfetti, intensity: 55)
                .allowsHitTesting(false)
        }
        .animation(.spring(duration: 0.45, bounce: 0.2), value: game.changeResult)
        .onChange(of: game.changeResult) { _, result in
            if result == .correct && !reduceMotion { showConfetti = true }
        }
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                SpeechService.shared.askForChange(amount: game.changeTarget)
            }
        }
    }

    // MARK: - iPad Landscape (Two-Column)

    private var iPadLandscapeLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left column — scrollable game content
            ScrollView {
                VStack(spacing: CanteenSpacing.l) {
                    problemCard
                    targetView
                    coinTray
                    if showHint { hintCard }
                    actionButtons
                }
                .padding(CanteenSpacing.l)
            }

            // Right column — always visible: coin bank + optional goal progress
            VStack(spacing: CanteenSpacing.l) {
                coinBank(size: 76)

                if let goal = game.selectedGoal {
                    GoalProgressPill(goal: goal, savedCoins: game.budget)
                }

                Spacer()
            }
            .frame(width: 240)
            .padding(.top, CanteenSpacing.l)
            .padding(.trailing, CanteenSpacing.l)
        }
    }

    // MARK: - Portrait Layout (iPhone + iPad Portrait)

    private var portraitLayout: some View {
        ScrollView {
            VStack(spacing: CanteenSpacing.l) {
                problemCard
                targetView
                coinTray
                coinBank(size: coinSize)
                if showHint { hintCard }
                actionButtons

                // iPad portrait: fill extra space with goal progress
                if isIPad, let goal = game.selectedGoal {
                    GoalProgressPill(goal: goal, savedCoins: game.budget)
                }

                // iPad portrait: achievement grid fills remaining space
                if isIPad {
                    achievementsMiniGrid
                }

                Spacer(minLength: CanteenSpacing.xl)
            }
            .padding(.horizontal, CanteenSpacing.l)
            .padding(.vertical, CanteenSpacing.m)
        }
    }

    // MARK: - Header

    private var changeHeader: some View {
        HStack {
            HStack(spacing: CanteenSpacing.s) {
                Image(systemName: "cart.fill")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
                Text("Step 2 of 3")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
            }
            .frame(width: 90, height: 44)
            .accessibilityLabel("Step 2 of 3: Calculate change")

            Spacer()

            VStack(spacing: 2) {
                Text("Make Change")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.cikolataKahvesi)
                    .accessibilityAddTraits(.isHeader)
            }

            Spacer()

            // Budget pill — SF Symbol coin icon instead of emoji
            HStack(spacing: 4) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.simitSarisi)
                Text("\(game.budget)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.cikolataKahvesi)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, CanteenSpacing.m)
            .padding(.vertical, CanteenSpacing.s)
            .glassEffect(in: .capsule)
            .accessibilityLabel("\(game.budget) coins remaining")
        }
        .padding(.horizontal, CanteenSpacing.l)
        .padding(.vertical, CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: 0))
    }

    // MARK: - Problem Card

    private var problemCard: some View {
        HStack(spacing: CanteenSpacing.m) {
            if let product = game.currentProduct {
                ZStack {
                    RoundedRectangle(cornerRadius: CanteenRadius.m)
                        .fill(product.accentColor.opacity(0.20))
                        .frame(width: 64, height: 64)
                    Text(product.emoji)
                        .font(.system(size: 38))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("You bought \(product.name)!")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.cikolataKahvesi)
                        .minimumScaleFactor(0.85)
                        .lineLimit(1)

                    // Inline coin amounts with SF Symbol
                    HStack(spacing: 3) {
                        Text("Paid")
                        CoinAmountLabel(
                            amount: game.paymentAmount,
                            amountColor: Color.cikolataKahvesi.opacity(0.70)
                        )
                        Text("for a")
                        CoinAmountLabel(
                            amount: product.price,
                            amountColor: Color.cikolataKahvesi.opacity(0.70)
                        )
                        Text("item")
                    }
                    .font(CanteenTypography.caption)
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.60))
                }

                Spacer()
            }
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("You bought \(game.currentProduct?.englishName ?? "item") for \(game.currentProduct?.price ?? 0) coins and paid \(game.paymentAmount) coins.")
    }

    // MARK: - Target Amount (Pedagogical Equation)

    private var targetView: some View {
        VStack(spacing: CanteenSpacing.s) {
            Text("Let's calculate your change!")
                .font(CanteenTypography.caption)
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.60))

            // Visual Equation: Paid - Cost = Change
            HStack(spacing: CanteenSpacing.s) {
                // Paid Amount
                VStack(spacing: 2) {
                    Text("Paid")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.50))
                        .textCase(.uppercase)
                    CoinAmountLabel(
                        amount: game.paymentAmount,
                        font: .system(.title3, design: .rounded, weight: .bold)
                    )
                }

                Text("-")
                    .font(.system(.title2, design: .rounded, weight: .black))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.30))

                // Item Cost
                VStack(spacing: 2) {
                    Text("Cost")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.50))
                        .textCase(.uppercase)
                    CoinAmountLabel(
                        amount: game.currentProduct?.price ?? 0,
                        font: .system(.title3, design: .rounded, weight: .bold)
                    )
                }

                Text("=")
                    .font(.system(.title2, design: .rounded, weight: .black))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.30))

                // Target Change
                VStack(spacing: 2) {
                    Text("Change")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.tostTuruncusu)
                        .textCase(.uppercase)
                    
                    if shouldRevealTarget {
                        CoinAmountLabel(
                            amount: game.changeTarget,
                            font: .system(.title2, design: .rounded, weight: .bold)
                        )
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.3), value: shouldRevealTarget)
                    } else {
                        Text("???")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.cikolataKahvesi)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.simitSarisi.opacity(shouldRevealTarget ? 0.15 : 0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .frame(maxWidth: .infinity)
            .padding(CanteenSpacing.m)
            .glassEffect(in: .rect(cornerRadius: CanteenRadius.m))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(shouldRevealTarget
            ? "\(game.paymentAmount) minus \(game.currentProduct?.price ?? 0) equals \(game.changeTarget) coins."
            : "Calculate \(game.paymentAmount) minus \(game.currentProduct?.price ?? 0).")
    }

    // MARK: - Coin Tray

    private var coinTray: some View {
        VStack(spacing: CanteenSpacing.s) {
            HStack {
                Text("Your coin tray")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.65))
                Spacer()
                CoinAmountLabel(
                    amount: game.selectedTotal,
                    font: .system(.headline, design: .rounded, weight: .bold),
                    amountColor: trayTotalColor,
                    coinColor: trayTotalColor
                )
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.3), value: game.selectedTotal)
            }

            if game.selectedCoins.isEmpty {
                emptyTrayPlaceholder
            } else {
                filledTray
            }

            if game.changeResult == .tooMuch {
                HStack(spacing: CanteenSpacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(Color.hataKirmizisi)
                    Text("Too many coins! Tap a coin to remove it.")
                        .font(CanteenTypography.caption)
                        .foregroundStyle(Color.hataKirmizisi)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .overlay(
            RoundedRectangle(cornerRadius: CanteenRadius.l)
                .stroke(Color.simitSarisi, lineWidth: isDragOverTray ? 3 : 0)
                .animation(.easeInOut(duration: 0.2), value: isDragOverTray)
        )
        .dropDestination(for: String.self) { droppedValues, _ in
            for valueString in droppedValues {
                if let rawValue = Int(valueString),
                   let coin = CoinDenomination(rawValue: rawValue) {
                    withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                        game.addCoin(coin)
                    }
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
            }
            return true
        } isTargeted: { targeted in
            isDragOverTray = targeted
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Coin tray: \(game.selectedTotal) coins out of \(game.changeTarget) needed.")
        .accessibilityValue("\(game.selectedTotal) of \(game.changeTarget) coins selected")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var emptyTrayPlaceholder: some View {
        Text(isDragOverTray ? "Drop coin here!" : "Tap or drag a coin below")
            .font(CanteenTypography.caption)
            .foregroundStyle(isDragOverTray ? Color.simitSarisi : Color.cikolataKahvesi.opacity(0.30))
            .frame(maxWidth: .infinity)
            .frame(height: 78)
            .background(Color.cikolataKahvesi.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
            .overlay(
                RoundedRectangle(cornerRadius: CanteenRadius.m)
                    .stroke(Color.cikolataKahvesi.opacity(0.12),
                            style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            )
    }

    private var filledTray: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CanteenSpacing.s) {
                ForEach(Array(game.selectedCoins.enumerated()), id: \.offset) { index, coin in
                    TrayChipView(denomination: coin) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(duration: 0.3, bounce: 0.25)) {
                            game.removeCoin(at: index)
                        }
                    }
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .asymmetric(
                                insertion: .scale(scale: 0.35).combined(with: .opacity),
                                removal: .scale(scale: 0.35).combined(with: .opacity)
                            )
                    )
                }
            }
            .padding(.horizontal, CanteenSpacing.xs)
            .padding(.vertical, CanteenSpacing.s)
        }
        .frame(height: 78)
        .background(Color.cikolataKahvesi.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
    }

    // MARK: - Coin Bank

    private func coinBank(size: CGFloat = 64) -> some View {
        VStack(spacing: CanteenSpacing.s) {
            Text("Tap or drag coins to your tray")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.65))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: CanteenSpacing.l) {
                ForEach(CoinDenomination.allCases) { coin in
                    CoinBankButton(denomination: coin, size: size) {
                        withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                            game.addCoin(coin)
                        }
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    }
                    .accessibilityLabel("\(coin.rawValue) coin")
                    .accessibilityHint("Tap to add a \(coin.rawValue) coin to your tray")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .accessibilityLabel("Coin bank")
    }

    // MARK: - Hint Card

    private var hintCard: some View {
        HStack(alignment: .top, spacing: CanteenSpacing.m) {
            Group {
                if game.isGeneratingAIHint {
                    ProgressView()
                        .tint(Color.simitSarisi)
                        .scaleEffect(0.85)
                        .accessibilityLabel("Apple Intelligence hint is loading")
                } else {
                    Image(systemName: game.aiHintText.isEmpty ? "lightbulb.fill" : "sparkles")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.simitSarisi)
                        .symbolEffect(.pulse)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: 26)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                if !game.aiHintText.isEmpty {
                    Label("Apple Intelligence", systemImage: "sparkles")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.simitSarisi.opacity(0.85))
                }
                Text(game.aiHintText.isEmpty ? hintText : game.aiHintText)
                    .font(CanteenTypography.caption)
                    .foregroundStyle(Color.cikolataKahvesi)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.interpolate)
                    .animation(.spring(duration: 0.5), value: game.aiHintText)
            }

            Spacer()
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.m))
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityLabel(game.isGeneratingAIHint
            ? "Loading Apple Intelligence hint, please wait"
            : game.aiHintText.isEmpty
                ? "Hint: \(hintText)"
                : "Apple Intelligence Hint: \(game.aiHintText)")
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: CanteenSpacing.m) {
            // Check Answer — gating evaluation behind an explicit tap is intentional:
            // children need to consciously confirm their answer rather
            // than having the screen change the instant the last coin lands.
            if !game.selectedCoins.isEmpty && game.changeResult != .correct {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    game.evaluateAnswer()
                } label: {
                    Label("Check Answer", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.canteenPrimary)
                .accessibilityLabel("Check your answer")
                .accessibilityHint("Confirm whether your coins add up to the correct change")
            }

            // Get a Hint
            if !showHint && game.changeResult != .correct && game.difficulty.showHintButton {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    hintText = game.getHint()
                    withAnimation(.spring(duration: 0.4)) { showHint = true }
                } label: {
                    Label("Get a Hint", systemImage: "lightbulb")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.canteenSecondary)
                .accessibilityLabel("Get a hint")
                .accessibilityHint("Shows a tip to help you calculate the correct change")
            }

            // Clear All
            if !game.selectedCoins.isEmpty && game.changeResult != .correct {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(duration: 0.3)) {
                        game.clearCoins()
                        showHint = false
                    }
                } label: {
                    Label("Clear All", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.canteenGhost)
                .accessibilityLabel("Clear all coins from the tray")
            }
        }
    }

    // MARK: - Achievements Mini Grid (iPad portrait filler)

    @ViewBuilder
    private var achievementsMiniGrid: some View {
        VStack(alignment: .leading, spacing: CanteenSpacing.s) {
            Text("Achievements")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.65))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: CanteenSpacing.s) {
                ForEach(game.achievements) { badge in
                    VStack(spacing: 4) {
                        Image(systemName: badge.symbol)
                            .font(.system(size: 22))
                            .foregroundStyle(badge.isUnlocked ? badge.prideAccentColor : Color.cikolataKahvesi.opacity(0.18))
                            .symbolEffect(.wiggle.byLayer, value: badge.isUnlocked)
                        Text(badge.title.components(separatedBy: " ").first ?? badge.title)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(badge.isUnlocked ? Color.cikolataKahvesi.opacity(0.65) : Color.cikolataKahvesi.opacity(0.22))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(CanteenSpacing.m)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
    }

    // MARK: - Helpers

    private var trayTotalColor: Color {
        switch game.changeResult {
        case .correct:  return Color.basariYesili
        case .tooMuch:  return Color.hataKirmizisi
        case nil:       return game.selectedTotal > 0 ? Color.simitSarisi : Color.cikolataKahvesi.opacity(0.35)
        }
    }
}
