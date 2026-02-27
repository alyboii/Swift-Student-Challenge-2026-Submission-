import SwiftUI

// MARK: - Goal Picker View
// Lets the player pick a savings goal before shopping begins.

struct GoalPickerView: View {
    @Environment(GameManager.self) private var game
    @State private var selectedGoal: SavingsGoal? = nil
    @State private var cardsAppeared = false
    @State private var headerPop = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let goals = SavingsGoal.all

    var body: some View {
        ZStack {
            CanteenMeshGradient()

            VStack(spacing: CanteenSpacing.l) {
                Spacer()

                headerSection

                goalCards

                if selectedGoal != nil {
                    continueButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
                Spacer()
            }
            .padding(.horizontal, CanteenSpacing.l)
            .frame(maxWidth: 600)
        }
        .onAppear {
            Task {
                let delay: Double = reduceMotion ? 0 : 0.15
                try? await Task.sleep(for: .seconds(delay))
                withAnimation(.spring(duration: 0.6, bounce: 0.3)) { headerPop = true }
                withAnimation(.spring(duration: 0.5, bounce: 0.2)) { cardsAppeared = true }
            }
            Task {
                try? await Task.sleep(for: .seconds(0.4))
                SpeechService.shared.speak(
                    "A savings goal is something you want to buy! If you don't spend all your coins, you save them. Pick something you want to save for!",
                    rate: 0.46, pitch: 1.12
                )
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CanteenSpacing.s) {
            Text("🎯")
                .font(.system(size: 56))
                .scaleEffect(reduceMotion ? 1.0 : (headerPop ? 1.0 : 0.4))
                .opacity(headerPop ? 1.0 : 0.0)
                .animation(
                    reduceMotion ? .none : .spring(duration: 0.7, bounce: 0.5),
                    value: headerPop
                )

            Text("What Are You Saving For?")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(Color.cikolataKahvesi)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            // Explainer for kids — "What is a savings goal?"
            VStack(spacing: 8) {
                Text("💡 What is a savings goal?")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.cikolataKahvesi)
                Text("When you don't spend all your coins, you save them! 🐷 Pick something you want, and try to save enough coins to get it!")
                    .font(CanteenTypography.bodyText)
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.70))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .padding(CanteenSpacing.m)
            .glassEffect(in: .rect(cornerRadius: CanteenRadius.m))

            Text("Pick a goal — then spend wisely at the canteen!")
                .font(CanteenTypography.bodyText)
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.60))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Goal Cards

    private var goalCards: some View {
        VStack(spacing: CanteenSpacing.m) {
            ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                GoalPickerCard(
                    goal: goal,
                    isSelected: selectedGoal?.id == goal.id
                )
                .opacity(cardsAppeared ? 1.0 : 0.0)
                .offset(y: cardsAppeared ? 0 : 24)
                .animation(
                    .spring(duration: 0.5, bounce: 0.2)
                        .delay(reduceMotion ? 0 : Double(index) * 0.1),
                    value: cardsAppeared
                )
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                        selectedGoal = goal
                    }
                    game.selectGoal(goal)
                }
                .accessibilityLabel("\(goal.name), costs \(goal.cost) coins. \(selectedGoal?.id == goal.id ? "Selected." : "Double-tap to select.")")
            }
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if game.coinIntroSeen {
                SpeechService.shared.letsGoToCanteen()
                game.navigate(to: .canteen)
            } else {
                SpeechService.shared.letsLearnCoins()
                game.navigate(to: .coinIntro)
            }
        } label: {
            Label("Let's Shop!", systemImage: "storefront.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.canteenPrimary)
        .accessibilityLabel("Continue to the canteen")
        .accessibilityHint("Start shopping with your savings goal in mind")
    }
}

// MARK: - Goal Picker Card

private struct GoalPickerCard: View {
    let goal: SavingsGoal
    let isSelected: Bool

    var body: some View {
        HStack(spacing: CanteenSpacing.m) {
            Text(goal.emoji)
                .font(.system(size: 40))
                .frame(width: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.cikolataKahvesi)
                Text("\(goal.cost)🪙 to save up")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.basariYesili)
                    .symbolEffect(.bounce, value: isSelected)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.25))
            }
        }
        .padding(CanteenSpacing.m)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.m))
        .overlay(
            RoundedRectangle(cornerRadius: CanteenRadius.m)
                .stroke(
                    isSelected ? Color.basariYesili.opacity(0.50) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}
