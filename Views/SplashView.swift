import SwiftUI

// MARK: - Splash View
// Welcome screen. Coins are shown at ascending sizes to introduce value hierarchy.

struct SplashView: View {
    @Environment(GameManager.self) private var game
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var coinBounce = false
    @State private var coinsAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private var isIPad: Bool { hSizeClass == .regular }

    var body: some View {
        ZStack {
            CanteenMeshGradient()

            VStack(spacing: 0) {
                Spacer()

                // Logo cluster
                VStack(spacing: CanteenSpacing.m) {
                    ZStack {
                        // Layered glow
                        Circle()
                            .fill(Color.simitSarisi.opacity(0.18))
                            .frame(width: 160, height: 160)
                            .blur(radius: 18)
                        Circle()
                            .fill(Color.simitSarisi.opacity(0.14))
                            .frame(width: 130, height: 130)
                        Circle()
                            .fill(Color.simitSarisi.opacity(0.22))
                            .frame(width: 104, height: 104)

                        Text("🏪")
                            .font(.system(size: 60))
                            .scaleEffect(coinBounce && !reduceMotion ? 1.08 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                                value: coinBounce
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    VStack(spacing: CanteenSpacing.xs) {
                        Text("Canteen Hero")
                            .font(.system(isIPad ? .largeTitle : .title, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.cikolataKahvesi)

                        Text("Learn money. One coin at a time.")
                            .font(CanteenTypography.bodyText)
                            .foregroundStyle(Color.cikolataKahvesi.opacity(0.60))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(logoOpacity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Canteen Hero. Learn money. One coin at a time.")
                }

                Spacer()

                // Coin row — ascending size signals ascending value
                // The 20-coin is visually almost 2× the 1-coin.
                VStack(spacing: CanteenSpacing.s) {
                    HStack(alignment: .bottom, spacing: isIPad ? CanteenSpacing.xl : CanteenSpacing.l) {
                        ForEach(Array(CoinDenomination.allCases.enumerated()), id: \.element) { idx, coin in
                            SplashCoinItem(
                                coin: coin,
                                appeared: coinsAppeared,
                                entranceDelay: Double(idx) * 0.12,
                                bouncing: coinBounce
                            )
                        }
                    }
                    .opacity(subtitleOpacity)

                    // "Smaller = less, bigger = more" micro-hint
                    HStack(spacing: CanteenSpacing.xs) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(.caption2, weight: .bold))
                            .foregroundStyle(Color.simitSarisi.opacity(0.7))
                        Text("bigger coin = more value")
                            .font(.system(.caption2, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.cikolataKahvesi.opacity(0.45))
                    }
                    .opacity(subtitleOpacity)
                }
                .padding(.bottom, CanteenSpacing.l)

                // Start button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    game.navigate(to: .story)
                } label: {
                    HStack(spacing: CanteenSpacing.s) {
                        Text("Start Adventure")
                            .font(CanteenTypography.buttonLabel)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                            .symbolEffect(.appear.byLayer, isActive: buttonOpacity > 0.5)
                            .symbolEffect(.bounce, value: coinBounce)
                    }
                    .foregroundStyle(Color.cikolataKahvesi)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CanteenSpacing.m)
                    .padding(.horizontal, CanteenSpacing.xl)
                    .background(Color.simitSarisi)
                    .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m + 2))
                    .shadow(color: Color.simitSarisi.opacity(0.40), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, CanteenSpacing.xl)
                .opacity(buttonOpacity)
                .accessibilityLabel("Start Adventure")
                .accessibilityHint("Begin the Canteen Hero financial literacy game")

                // Games played badge
                if game.gamesPlayed > 0 {
                    Text("You've played \(game.gamesPlayed) time\(game.gamesPlayed == 1 ? "" : "s")!")
                        .font(CanteenTypography.caption)
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.45))
                        .padding(.top, CanteenSpacing.s)
                        .opacity(buttonOpacity)
                }

                // Privacy by Design badge — Apple culture signal
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(.caption2))
                        .foregroundStyle(Color.basariYesili.opacity(0.7))
                        .symbolEffect(.appear.byLayer, isActive: buttonOpacity > 0.5)
                    Text("Your data stays on this device")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.40))
                }
                .padding(.top, CanteenSpacing.xs)
                .opacity(buttonOpacity)
                .accessibilityLabel("Privacy: all data stays on your device")

                Spacer().frame(height: CanteenSpacing.xl * 1.5)
            }
            .padding(.horizontal, CanteenSpacing.l)
            .frame(maxWidth: 640)
        }
        .onAppear { animateIn() }
    }

    private func animateIn() {
        if reduceMotion {
            logoScale = 1; logoOpacity = 1
            subtitleOpacity = 1; buttonOpacity = 1
            coinsAppeared = true
            SpeechService.shared.welcomeCanteen()
            return
        }
        withAnimation(.spring(duration: 0.75, bounce: 0.50).delay(0.1)) {
            logoScale = 1
            logoOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.45).delay(0.65)) {
            subtitleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.45).delay(0.65)) {
            coinsAppeared = true
        }
        withAnimation(.easeOut(duration: 0.45).delay(1.05)) {
            buttonOpacity = 1
        }
        Task {
            try? await Task.sleep(for: .seconds(1.4))
            coinBounce = true
        }
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            SpeechService.shared.welcomeCanteen()
        }
    }
}

// MARK: - Splash Coin Item
// Each coin in the splash row — ascending SIZE communicates ascending value.
// 1-coin is small, 20-coin is almost twice as large.

private struct SplashCoinItem: View {
    let coin: CoinDenomination
    let appeared: Bool
    let entranceDelay: Double
    let bouncing: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Pre-typed locals break the long modifier chain that exceeds the
        // Swift type-checker inference budget and causes a compile timeout.
        let bounceScale: CGFloat = (bouncing && !reduceMotion)
            ? 1.0 + 0.05 * (CGFloat(coin.rawValue) / 20.0)
            : 1.0
        let entranceScale: CGFloat = appeared ? 1.0 : (reduceMotion ? 1.0 : 0.3)
        let entranceOffsetY: CGFloat = appeared ? 0 : (reduceMotion ? 0 : 20)

        return VStack(spacing: 6) {
            ZStack {
                // Coin body
                Circle()
                    .fill(coin.coinColor)
                    .overlay(
                        Circle()
                            .stroke(coin.coinColor.opacity(0.4), lineWidth: 2.5)
                            .padding(2)
                    )
                    .shadow(color: coin.coinColor.opacity(0.50), radius: 7, x: 0, y: 4)

                // Denomination label
                Text(coin.label)
                    .font(.system(size: coin.splashDisplaySize * 0.28,
                                  weight: .black, design: .rounded))
                    .foregroundStyle(coin.labelColor)
            }
            .frame(width: coin.splashDisplaySize, height: coin.splashDisplaySize)
            .scaleEffect(bounceScale)
            .animation(
                .easeInOut(duration: 0.85 + Double(coin.rawValue) * 0.03)
                    .repeatForever(autoreverses: true)
                    .delay(Double(coin.rawValue) * 0.07),
                value: bouncing
            )
            // Staggered entrance from below
            .scaleEffect(entranceScale)
            .opacity(appeared ? 1.0 : 0.0)
            .offset(y: entranceOffsetY)
            .animation(
                .spring(duration: 0.55, bounce: 0.45).delay(entranceDelay),
                value: appeared
            )

            // Value label beneath each coin
            Text(coin.label)
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.50))
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.3).delay(entranceDelay + 0.2), value: appeared)
        }
        .accessibilityLabel("\(coin.rawValue) coin")
        .accessibilityHidden(true)
    }
}
