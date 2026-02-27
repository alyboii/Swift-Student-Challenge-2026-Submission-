import SwiftUI

// MARK: - Progress Arc Shape
// iOS 26 @Animatable macro — auto-synthesises animatableData for smooth ring fill

@Animatable
struct ProgressArc: Shape {
    var progress: Double   // 0.0 – 1.0

    func path(in rect: CGRect) -> Path {
        let clamped  = max(0, min(1, progress))
        let radius   = min(rect.width, rect.height) / 2
        let center   = CGPoint(x: rect.midX, y: rect.midY)
        let start    = Angle.degrees(-90)
        let end      = Angle.degrees(-90 + clamped * 360)

        var path = Path()
        path.addArc(center: center, radius: radius,
                    startAngle: start, endAngle: end, clockwise: false)
        return path
    }
}

// MARK: - Goal Setting View

struct GoalSettingView: View {
    @Environment(GameManager.self) private var game
    @State private var selectedGoal: SavingsGoal? = nil
    @State private var progressAnimated   = false
    @State private var cardsAppeared      = false
    @State private var headerPop          = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let goals = SavingsGoal.all

    var body: some View {
        ZStack(alignment: .top) {
            CanteenMeshGradient()

            VStack(spacing: 0) {
                // Back button header
                HStack {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        game.navigate(to: .summary)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(.subheadline, weight: .semibold))
                            Text("Results")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                        }
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.65))
                    }
                    .accessibilityLabel("Go back to results")
                    Spacer()
                }
                .padding(.horizontal, CanteenSpacing.l)
                .padding(.vertical, CanteenSpacing.m)
                .glassEffect(in: .rect(cornerRadius: 0))

                ScrollView {
                    VStack(spacing: CanteenSpacing.l) {
                        headerCard
                        goalPickerSection
                        tapToFlipHint

                    if let goal = selectedGoal {
                        progressCard(for: goal)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal:   .opacity
                            ))
                    }

                    playAgainButton
                    Spacer(minLength: CanteenSpacing.xl)
                }
                .padding(.horizontal, CanteenSpacing.l)
                .padding(.top, CanteenSpacing.l)
            }
            }   // end VStack (back header + ScrollView)
        }
        .onAppear {
            // Staggered entrance
            Task {
                let delay: Double = reduceMotion ? 0 : 0.2
                try? await Task.sleep(for: .seconds(delay))
                withAnimation(.spring(duration: 0.6, bounce: 0.25)) { cardsAppeared = true }
                withAnimation(.spring(duration: 0.7, bounce: 0.45)) { headerPop = true }
            }
            // Narration — delay so it doesn't clash with SummaryView speech
            Task {
                try? await Task.sleep(for: .seconds(0.8))
                SpeechService.shared.speak(
                    "What are you saving for? Pick a goal!",
                    rate: 0.45, pitch: 1.12
                )
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: CanteenSpacing.s) {
            // Animated trophy / star
            Text("🎯")
                .font(.system(size: 56))
                .scaleEffect(reduceMotion ? 1.0 : (headerPop ? 1.0 : 0.4))
                .opacity(headerPop ? 1.0 : 0.0)
                .animation(
                    reduceMotion ? .none : .spring(duration: 0.7, bounce: 0.5),
                    value: headerPop
                )

            Text("Set a Savings Goal")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(Color.cikolataKahvesi)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            // Savings summary pill
            HStack(spacing: CanteenSpacing.xs) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundStyle(Color.basariYesili)
                    .symbolEffect(.bounce, value: headerPop) // iOS 17+
                HStack(spacing: 3) {
                    Text("You saved")
                    CoinAmountLabel(
                        amount: game.budget,
                        font: .system(.subheadline, design: .rounded, weight: .semibold),
                        amountColor: Color.basariYesili,
                        coinColor: Color.basariYesili
                    )
                    Text("today!")
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.basariYesili)
            }
            .padding(.horizontal, CanteenSpacing.m)
            .padding(.vertical, CanteenSpacing.s)
            .background(Color.basariYesili.opacity(0.12),
                        in: .rect(cornerRadius: CanteenRadius.full))

            Text("Choose something to save up for:")
                .font(CanteenTypography.bodyText)
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.65))
                .multilineTextAlignment(.center)

            Text("💡 Saving means keeping some coins for later so you can buy something bigger!")
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(CanteenSpacing.l)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Set a Savings Goal. You saved \(game.budget) coins today. Choose something to save up for.")
    }

    // MARK: - Goal Picker

    private var goalPickerSection: some View {
        VStack(spacing: CanteenSpacing.m) {
            ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                GoalCardView(
                    goal:          goal,
                    isSelected:    selectedGoal?.id == goal.id,
                    savedCoins:    game.budget
                )
                .opacity(cardsAppeared ? 1.0 : 0.0)
                .offset(y: cardsAppeared ? 0 : 28)
                .animation(
                    .spring(duration: 0.5, bounce: 0.22)
                        .delay(reduceMotion ? 0 : Double(index) * 0.13),
                    value: cardsAppeared
                )
                .onTapGesture {
                    HapticService.shared.goalSelected()
                    withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
                        selectedGoal    = goal
                        progressAnimated = false
                    }
                    // GameManager triggers speech via selectGoal
                    game.selectGoal(goal)

                    // Animate progress ring after a beat
                    Task {
                        let ringDelay: Double = reduceMotion ? 0 : 0.40
                        try? await Task.sleep(for: .seconds(ringDelay))
                        withAnimation(.spring(duration: 1.1, bounce: 0.08)) {
                            progressAnimated = true
                        }
                    }
                }
                .accessibilityLabel("\(goal.name), costs \(goal.cost) coins. \(selectedGoal?.id == goal.id ? "Selected." : "Double-tap to select.")")
            }
        }
    }

    // MARK: - Tap to Flip Hint

    @ViewBuilder
    private var tapToFlipHint: some View {
        if selectedGoal == nil {
            HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.simitSarisi)
                    .symbolEffect(.breathe, options: .repeating)
                Text("Tap a card to see details!")
                    .font(.system(.callout, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.65))
            }
            .padding(CanteenSpacing.s)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .accessibilityLabel("Tap any card to see more details")
        }
    }

    // MARK: - Progress Card

    private func progressCard(for goal: SavingsGoal) -> some View {
        let fraction  = min(1.0, Double(game.budget) / Double(goal.cost))
        let sessions  = goal.sessionsNeeded(coinsPerSession: max(game.budget, 1))
        let pct       = Int(fraction * 100)

        return VStack(spacing: CanteenSpacing.m) {
            // Section title
            Label("Your Progress", systemImage: "chart.line.uptrend.xyaxis")
                .font(CanteenTypography.sectionTitle)
                .foregroundStyle(Color.cikolataKahvesi)
                .accessibilityAddTraits(.isHeader)

            // Progress ring
            ZStack {
                // Background track
                Circle()
                    .stroke(Color.gray.opacity(0.13), lineWidth: 16)
                    .frame(width: 150, height: 150)

                // Animated arc — @Animatable ProgressArc
                ProgressArc(progress: progressAnimated ? fraction : 0)
                    .stroke(
                        LinearGradient(
                            colors: Color.prideColors,
                            startPoint: .topLeading,
                            endPoint:   .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .animation(.spring(duration: 1.1, bounce: 0.08), value: progressAnimated)

                // Center label
                VStack(spacing: 2) {
                    Text("\(pct)%")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.cikolataKahvesi)
                        .contentTransition(.numericText())
                    Text("of goal")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.50))
                }
            }
            .accessibilityLabel("Progress ring: \(pct) percent toward your goal")

            // Goal info row
            VStack(spacing: CanteenSpacing.xs) {
                HStack(spacing: CanteenSpacing.s) {
                    Text(goal.emoji)
                        .font(.system(size: 26))
                    HStack(spacing: 4) {
                        Text("\(goal.name)  •")
                        CoinAmountLabel(
                            amount: goal.cost,
                            font: .system(.subheadline, design: .rounded, weight: .semibold)
                        )
                    }
                    .foregroundStyle(Color.cikolataKahvesi)
                }

                Text(sessionsMessage(sessions: sessions, fraction: fraction))
                    .font(CanteenTypography.bodyText)
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.70))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }
        }
        .padding(CanteenSpacing.m)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Goal: \(goal.name). \(pct) percent reached. \(sessionsMessage(sessions: sessions, fraction: fraction))")
    }

    private func sessionsMessage(sessions: Int, fraction: Double) -> String {
        if fraction >= 1.0 {
            return "🎉 You already have enough coins! You're a champion saver!"
        } else if sessions == 1 {
            return "Just one more session like today and you'll reach your goal! 🚀"
        } else {
            return "At this rate, you'll reach your goal in about \(sessions) more sessions. Keep it up! 💪"
        }
    }

    // MARK: - Play Again Button

    private var playAgainButton: some View {
        VStack(spacing: CanteenSpacing.m) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                game.reset()
            } label: {
                Label("Play Again", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.canteenPrimary)
            .accessibilityLabel("Play Again")
            .accessibilityHint("Reset the game and go back to the beginning")
        }
    }
}

// MARK: - Goal Card View (Flip Animation)

struct GoalCardView: View {
    let goal:       SavingsGoal
    let isSelected: Bool
    let savedCoins: Int

    @State private var isFlipped = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var fraction: Double {
        min(1.0, Double(savedCoins) / Double(goal.cost))
    }

    var body: some View {
        ZStack {
            // Front — glass card
            frontFace
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 90 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Back — selected state card
            backFace
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -90),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .onChange(of: isSelected) { _, selected in
            if selected && !reduceMotion {
                withAnimation(.spring(duration: 0.5, bounce: 0.20)) { isFlipped = true }
            } else if !selected {
                withAnimation(.spring(duration: 0.38, bounce: 0.10)) { isFlipped = false }
            } else if selected && reduceMotion {
                isFlipped = true
            }
        }
    }

    // MARK: Front Face

    private var frontFace: some View {
        HStack(spacing: CanteenSpacing.m) {
            Text(goal.emoji)
                .font(.system(size: 44))
                .frame(width: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.cikolataKahvesi)
                HStack(spacing: 2) {
                    CoinAmountLabel(
                        amount: goal.cost,
                        font: .system(.caption, design: .rounded, weight: .medium),
                        amountColor: Color.cikolataKahvesi.opacity(0.52)
                    )
                    Text("needed")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.52))
                }
            }

            Spacer()

            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.simitSarisi)
        }
        .padding(CanteenSpacing.m)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.m))
    }

    // MARK: Back Face (Selected)

    private var backFace: some View {
        HStack(spacing: CanteenSpacing.m) {
            Text(goal.emoji)
                .font(.system(size: 44))
                .frame(width: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text(goal.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.cikolataKahvesi)

                // Coins saved vs needed
                HStack(spacing: 4) {
                    CoinAmountLabel(
                        amount: savedCoins,
                        font: .system(.caption, design: .rounded, weight: .bold),
                        amountColor: Color.basariYesili,
                        coinColor: Color.basariYesili
                    )
                    Text("/")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.50))
                    CoinAmountLabel(
                        amount: goal.cost,
                        font: .system(.caption, design: .rounded, weight: .medium),
                        amountColor: Color.cikolataKahvesi.opacity(0.50)
                    )
                }

                // Mini horizontal progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.13))
                            .frame(height: 7)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.tostTuruncusu, Color.simitSarisi],
                                    startPoint: .leading,
                                    endPoint:   .trailing
                                )
                            )
                            .frame(width: geo.size.width * fraction, height: 7)
                            .animation(.spring(duration: 0.8), value: fraction)
                    }
                }
                .frame(height: 7)
            }

            Spacer()

            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.basariYesili)
                .symbolEffect(.bounce, value: isFlipped) // iOS 17+
        }
        .padding(CanteenSpacing.m)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.m))
        .overlay(
            RoundedRectangle(cornerRadius: CanteenRadius.m)
                .stroke(Color.basariYesili.opacity(0.45), lineWidth: 2)
        )
    }
}
