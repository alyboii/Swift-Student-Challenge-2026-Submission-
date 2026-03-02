import SwiftUI

// MARK: - Splash View

struct SplashView: View {
    @Environment(GameManager.self) private var game
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var coinBounce = false
    @State private var coinsAppeared = false
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private var isIPad: Bool { hSizeClass == .regular }

    var body: some View {
        ZStack {
            CanteenMeshGradient()

            VStack(spacing: 0) {
                Spacer()

                // Logo cluster
                let iconSize: CGFloat = isIPad ? 180 : 148
                VStack(spacing: CanteenSpacing.l) {
                    ZStack {
                        // glow behind the app icon
                        Circle()
                            .fill(Color.simitSarisi.opacity(0.18))
                            .frame(width: iconSize * 1.55, height: iconSize * 1.55)
                            .blur(radius: 28)
                        Circle()
                            .fill(Color.simitSarisi.opacity(0.12))
                            .frame(width: iconSize * 1.25, height: iconSize * 1.25)

                        AppIconView()
                            .frame(width: iconSize, height: iconSize)
                            // rounded like a home screen icon
                            .clipShape(RoundedRectangle(cornerRadius: iconSize * 0.225, style: .continuous))
                            .shadow(color: Color.black.opacity(0.20), radius: 16, x: 0, y: 8)
                            .scaleEffect(coinBounce ? 1.04 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                                value: coinBounce
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    // title + tagline
                    VStack(spacing: 0) {
                        Text("Canteen Hero")
                            .font(.system(isIPad ? .largeTitle : .title, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.cikolataKahvesi)

                        Text("Learn money. One coin at a time.")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.cikolataKahvesi.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.top, CanteenSpacing.s)
                    }
                    .opacity(logoOpacity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Canteen Hero. Learn money. One coin at a time.")

                    // Turkey badge
                    HStack(spacing: CanteenSpacing.s) {
                        Text("🇹🇷")
                            .font(.system(size: 18))
                        Text("Inspired by a real school canteen in Turkey")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.cikolataKahvesi.opacity(0.80))
                    }
                    .padding(.horizontal, CanteenSpacing.m)
                    .padding(.vertical, CanteenSpacing.s)
                    .glassEffect(in: .capsule)
                    .opacity(logoOpacity)
                    .accessibilityLabel("Inspired by a real school canteen in Turkey")
                }

                // thin divider line
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            Color.simitSarisi.opacity(0),
                            Color.simitSarisi.opacity(0.35),
                            Color.simitSarisi.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 1)
                    .padding(.horizontal, CanteenSpacing.xl)
                    .padding(.vertical, CanteenSpacing.l)
                    .opacity(subtitleOpacity)

                // coin row — bigger = worth more
                VStack(spacing: CanteenSpacing.m) {
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

                // privacy note
                HStack(spacing: 6) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(.footnote, weight: .semibold))
                        .foregroundStyle(Color.basariYesili.opacity(0.80))
                    Text("Your data stays on this device")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.60))
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

private struct SplashCoinItem: View {
    let coin: CoinDenomination
    let appeared: Bool
    let entranceDelay: Double
    let bouncing: Bool

    var body: some View {
        let bounceScale: CGFloat = bouncing
            ? 1.0 + 0.05 * (CGFloat(coin.rawValue) / 20.0)
            : 1.0
        let entranceScale: CGFloat = appeared ? 1.0 : 0.3
        let entranceOffsetY: CGFloat = appeared ? 0 : 20

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
