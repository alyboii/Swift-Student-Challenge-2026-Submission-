import SwiftUI

// MARK: - Change Success Overlay

struct ChangeSuccessOverlay: View {
    @Environment(GameManager.self) private var game
    @Binding var showHint: Bool
    @Binding var showConfetti: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.50)
                .ignoresSafeArea()

            VStack(spacing: CanteenSpacing.l) {
                CelebrationEmojiView()

                VStack(spacing: CanteenSpacing.s) {
                    Text("Correct! 🌟")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.basariYesili)
                        .accessibilityAddTraits(.isHeader)

                    // Coin amount inline with SF Symbol
                    HStack(spacing: 4) {
                        Text("You calculated")
                        CoinAmountLabel(
                            amount: game.changeTarget,
                            font: CanteenTypography.bodyText,
                            coinColor: Color.basariYesili
                        )
                        Text("change!")
                    }
                    .font(CanteenTypography.bodyText)
                    .foregroundStyle(Color.cikolataKahvesi)

                    Text("Nicely done, Canteen Hero!")
                        .font(CanteenTypography.bodyText)
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.75))
                }
                .multilineTextAlignment(.center)

                // Newly unlocked achievements
                let newlyUnlocked = game.achievements.filter { game.newlyUnlockedIds.contains($0.id) }
                if !newlyUnlocked.isEmpty {
                    HStack(spacing: CanteenSpacing.m) {
                        ForEach(newlyUnlocked.prefix(3)) { badge in
                            VStack(spacing: 4) {
                                Image(systemName: badge.symbol)
                                    .font(.system(size: 26))
                                    .foregroundStyle(Color.simitSarisi)
                                    .symbolEffect(.wiggle.byLayer)
                                Text(badge.title)
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(CanteenSpacing.s)
                    .glassEffect(in: .rect(cornerRadius: CanteenRadius.m))
                }

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showHint = false
                    showConfetti = false
                    let goToSummary = game.purchases.count >= 3 || game.budget < 3
                    game.navigate(to: goToSummary ? .summary : .canteen)
                } label: {
                    let goToSummary = game.purchases.count >= 3 || game.budget < 3
                    Label(
                        goToSummary ? "See My Results" : "Keep Shopping",
                        systemImage: goToSummary ? "chart.bar.fill" : "storefront.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.canteenPrimary)
                .accessibilityLabel(game.purchases.count >= 3 || game.budget < 3 ? "See My Results" : "Keep Shopping")
            }
            .padding(CanteenSpacing.xl)
            .background(.white.opacity(0.97))
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.l + 4))
            .shadow(color: Color.basariYesili.opacity(0.30), radius: 32, x: 0, y: 16)
            .padding(.horizontal, CanteenSpacing.xl)
        }
        .accessibilityElement(children: .contain)
    }
}

