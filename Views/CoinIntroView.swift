import SwiftUI
import SpriteKit

// MARK: - CoinIntroView
// SwiftUI wrapper around CoinIntroScene. Shows a coin comparison row at the top
// and a continue button after the physics demo completes.

struct CoinIntroView: View {
    @Environment(GameManager.self) private var game
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var scene: CoinIntroScene? = nil
    @State private var headerVisible  = false
    @State private var showContinue   = false
    @State private var coinRowVisible = false
    @State private var expandedCoin: CoinDenomination? = nil

    var body: some View {
        ZStack {
            // Consistent MeshGradient background (matches all screens)
            CanteenMeshGradient()

            VStack(spacing: 0) {
                // Top bar: back button + title
                topBar

                // Header text
                headerText
                    .opacity(headerVisible ? 1 : 0)
                    .offset(y: headerVisible ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: headerVisible)

                // Value comparison row — ascending sizes before the physics demo
                // Shows all four coins at ascending visual sizes BEFORE
                // the SpriteKit demo.  Children grasp SIZE = VALUE
                // immediately, then the physics reinforces it.
                valueComparisonRow
                    .opacity(coinRowVisible ? 1 : 0)
                    .offset(y: coinRowVisible ? 0 : 16)
                    .animation(
                        .spring(duration: 0.55, bounce: 0.30).delay(0.45),
                        value: coinRowVisible
                    )

                // SpriteKit scene (fills remaining screen space)
                GeometryReader { geo in
                    SpriteView(
                        scene: makeScene(size: geo.size),
                        options: [.allowsTransparency]
                    )
                    .background(Color.clear)
                    .accessibilityLabel("Coin drop zone. Four coins appear one by one — tap anywhere to drop each coin and watch it fall.")
                    .accessibilityHint(showContinue ? "All coins have dropped. Tap the Let's Shop button below." : "Tap anywhere on this area to drop the current coin.")
                    .accessibilityAddTraits(.allowsDirectInteraction)
                }

                // SwiftUI continue button — appears after all four beats complete
                if showContinue {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        HapticService.shared.achievementUnlock()
                        game.coinIntroSeen = true
                        SpeechService.shared.letsGoToCanteen()
                        game.navigate(to: .canteen)
                    } label: {
                        Label("Let's Shop!", systemImage: "storefront.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.canteenPrimary)
                    .padding(.horizontal, CanteenSpacing.l)
                    .padding(.bottom, CanteenSpacing.l)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .accessibilityLabel("Let's Shop")
                    .accessibilityHint("Start shopping at the canteen")
                }
            }
            .animation(.spring(duration: 0.4, bounce: 0.15), value: showContinue)
        }
        .preferredColorScheme(.light)
        .onAppear {
            headerVisible  = true
            coinRowVisible = true
            SpeechService.shared.letsLearnCoins()
        }
        .onDisappear {
            SpeechService.shared.stop()
        }
    }

    // MARK: - Value Comparison Row
    // Ascending sizes (introDisplaySize: 44 → 58 → 72 → 88 pt), bottom-aligned.
    // Tap any coin → context panel with dot-count grid + real-world hint.

    @ViewBuilder
    private var valueComparisonRow: some View {
        VStack(spacing: 6) {

            // Coin strip
            HStack(alignment: .bottom) {
                ForEach(CoinDenomination.allCases) { coin in
                    CoinIntroCard(
                        coin: coin,
                        isHighlighted: expandedCoin == coin,
                        reduceMotion: reduceMotion
                    )
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let next: CoinDenomination? = (expandedCoin == coin) ? nil : coin
                        withAnimation(.spring(duration: 0.30, bounce: 0.45)) {
                            expandedCoin = next
                        }
                        let style: UIImpactFeedbackGenerator.FeedbackStyle =
                            coin.rawValue >= 20 ? .heavy
                          : coin.rawValue >= 10 ? .medium
                          : .light
                        UIImpactFeedbackGenerator(style: style).impactOccurred()
                    }
                    .accessibilityLabel("\(coin.rawValue)-coin. \(coin.buyingPowerHint).")
                    .accessibilityHint("Double-tap to see how many 1-coins it equals")
                    .accessibilityAddTraits(.isButton)
                }
            }

            // Context panel — fixed height so the SpriteKit view doesn't jump
            // when the panel appears / disappears.
            ZStack(alignment: .top) {
                if let coin = expandedCoin {
                    coinDetailPanel(for: coin)
                        .transition(
                            .scale(scale: 0.88, anchor: .top).combined(with: .opacity)
                        )
                } else {
                    Text("👆 Tap a coin to learn more!")
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.50))
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.22), value: expandedCoin?.rawValue)
            .frame(minHeight: 54, alignment: .top)
        }
        .padding(.horizontal, CanteenSpacing.l)
        .padding(.bottom, CanteenSpacing.s)
    }

    /// Equivalence label + dot-count grid for the tapped coin.
    private func coinDetailPanel(for coin: CoinDenomination) -> some View {
        VStack(spacing: 6) {

            // Equivalence text
            HStack(spacing: 3) {
                Image(systemName: "equal.circle.fill")
                    .foregroundStyle(coin.coinColor)
                    .font(.caption2)

                Text(
                    coin.rawValue == 1
                        ? "The smallest coin — nothing is worth less"
                        : "\(coin.rawValue) × the 1-coin"
                )
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(coin.coinColor)

                Text("·")
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.30))
                    .font(.caption2)

                Text(coin.buyingPowerHint)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.60))
            }

            // Dot grid — 5 dots per row, colour-coded to the coin.
            // "Count the dots!" is the most powerful pre-numeric comparison.
            CoinDotGrid(count: coin.rawValue, color: coin.coinColor)
        }
        .padding(.horizontal, CanteenSpacing.s)
        .padding(.vertical, CanteenSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: CanteenRadius.m)
                .fill(coin.coinColor.opacity(0.09))
        )
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                SpeechService.shared.stop()
                game.navigate(to: .goalPicker)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back to goal picker")

            Spacer()

            Text("Meet Your Coins")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.60))

            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, CanteenSpacing.l)
        .padding(.top, CanteenSpacing.xl)
    }

    // MARK: - Header Text

    private var headerText: some View {
        VStack(spacing: CanteenSpacing.s) {
            Text("Tap each coin to drop it! 👇")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color.cikolataKahvesi)
                .multilineTextAlignment(.center)

            Text("🪙 Bigger coin = worth more! 💪")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.cikolataKahvesi.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, CanteenSpacing.l)
        .padding(.bottom, CanteenSpacing.s)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Tap each coin to drop it. Bigger coin means worth more."
        )
    }

    // MARK: - Scene Factory

    private func makeScene(size: CGSize) -> CoinIntroScene {
        if let existing = scene { return existing }

        let s = CoinIntroScene(size: size)
        s.scaleMode    = .resizeFill
        s.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 0)
        s.reduceMotion = reduceMotion

        // When all beats complete → show SwiftUI button
        s.onAllBeatsComplete = {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                showContinue = true
            }
        }

        // Legacy callback — no longer used for direct navigation
        s.onComplete = nil

        scene = s
        return s
    }
}

// MARK: - CoinIntroCard
// A single coin in the ascending-size preview row.
// introDisplaySize: 44 (1) → 58 (5) → 72 (10) → 88 (20-coin).
// Bottom-aligned in parent HStack so smaller coins visually "stand shorter".

private struct CoinIntroCard: View {
    let coin: CoinDenomination
    let isHighlighted: Bool
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: 5) {

            ZStack {
                // Halo glow when selected
                if isHighlighted && !reduceMotion {
                    Circle()
                        .fill(coin.coinColor.opacity(0.22))
                        .frame(
                            width:  coin.introDisplaySize + 22,
                            height: coin.introDisplaySize + 22
                        )
                        .blur(radius: 8)
                }

                Circle()
                    .fill(coin.coinColor)
                    .overlay(
                        Circle()
                            .stroke(
                                coin.coinColor.opacity(isHighlighted ? 0.75 : 0.35),
                                lineWidth: isHighlighted ? 2.5 : 1.5
                            )
                            .padding(2)
                    )
                    .shadow(
                        color: coin.coinColor.opacity(isHighlighted ? 0.55 : 0.30),
                        radius: isHighlighted ? 10 : 5,
                        x: 0, y: 3
                    )
                    .frame(width: coin.introDisplaySize, height: coin.introDisplaySize)
                    .scaleEffect(isHighlighted && !reduceMotion ? 1.10 : 1.0)

                Text(coin.label)
                    .font(.system(
                        size: coin.introDisplaySize * 0.30,
                        weight: .black,
                        design: .rounded
                    ))
                    .foregroundStyle(coin.labelColor)
            }

            // Denomination label below the coin
            Text(coin.label)
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(
                    isHighlighted
                        ? coin.coinColor
                        : Color.cikolataKahvesi.opacity(0.50)
                )
        }
    }
}

// MARK: - CoinDotGrid
// N dots arranged in rows of 5 — matches the "five-frame" model used in
// early-years numeracy (Singapore Math CPA approach).
//
// Visual proof: the 20-coin grid has 4 rows of 5 dots.
//               the 1-coin grid has a single dot.
// A 6-year-old can count and COMPARE without needing to read numbers.

private struct CoinDotGrid: View {
    let count: Int
    let color: Color

    private let columns   = 5
    private let dotSize:    CGFloat = 6
    private let dotGap:     CGFloat = 3

    private var rows: Int {
        Int(ceil(Double(count) / Double(columns)))
    }

    var body: some View {
        VStack(spacing: dotGap) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: dotGap) {
                    let filled = min(columns, count - row * columns)

                    // Filled dots
                    ForEach(0..<filled, id: \.self) { _ in
                        Circle()
                            .fill(color)
                            .frame(width: dotSize, height: dotSize)
                    }

                    // Empty placeholders so every row is the same width
                    if filled < columns {
                        ForEach(0..<(columns - filled), id: \.self) { _ in
                            Color.clear
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                }
            }
        }
        .accessibilityLabel(
            "\(count) dot\(count == 1 ? "" : "s") — equal to \(count) one-coin\(count == 1 ? "" : "s")"
        )
    }
}
