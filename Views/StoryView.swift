import SwiftUI

// MARK: - Story Card Model

struct StoryCard: Sendable {
    let emoji: String
    let title: String
    let body: String
    let accentColor: Color
    let speechText: String
    let showKidScene: KidScene

    enum KidScene: Sendable {
        case none
        case scared       // Card 1: kid frozen at canteen counter
        case watching     // Card 2: kid watching other child lose change
        case icon         // Card 3: the icon character
    }
}

// MARK: - Story Cards

private let storyCards: [StoryCard] = [
    StoryCard(
        emoji: "😰",
        title: "I Was That Kid",
        body: "When I was little, maths was hard for me — and change calculations were the hardest part.\n\nMy dad runs a school canteen in Turkey. Standing there, watching him count coins, I'd try to follow along in my head.\n\n20 minus 13... I'd count on my fingers under the counter, hoping nobody saw.\n\nI'm not scared of it anymore. But I remember exactly what that fear felt like.",
        accentColor: Color(red: 0.20, green: 0.50, blue: 0.90),
        speechText: "When I was little, maths was hard for me — and change calculations were the hardest part. My dad runs a school canteen in Turkey. 20 minus 13... I'd count on my fingers under the counter, hoping nobody saw. I'm not scared of it anymore. But I remember exactly what that fear felt like.",
        showKidScene: .scared
    ),
    StoryCard(
        emoji: "👀",
        title: "The Moment That Changed Everything",
        body: "One day I was working at my dad's canteen when a kid bought a simit and walked away — without his change.\n\nHe didn't forget. He just didn't know how much it should be. And asking would've meant admitting that.\n\nI knew exactly how that felt. That was me, not long ago. 💙",
        accentColor: Color(red: 0.85, green: 0.45, blue: 0.20),
        speechText: "One day I was working at my dad's canteen when a kid bought a simit and walked away without his change. He didn't forget. He just didn't know how much it should be. And asking would have meant admitting that. I knew exactly how that felt. That was me, not long ago.",
        showKidScene: .watching
    ),
    StoryCard(
        emoji: "💡",
        title: "The Kid Who Inspired This",
        body: "The little character on this app's icon?\n\nThat's the kid I keep building for.\nThe one who's a bit scared of numbers. The one who just needs someone to show them — gently, playfully — that they can do this.\n\nMaybe that kid is you. 💙",
        accentColor: Color(red: 0.30, green: 0.70, blue: 0.45),
        speechText: "The little character on this app's icon? That's the kid I keep building for. The one who's a bit scared of numbers. Maybe that kid is you.",
        showKidScene: .icon
    ),
    StoryCard(
        emoji: "🏪",
        title: "Welcome to the Canteen!",
        body: "You have 50 coins and a whole canteen of yummy snacks waiting for you! 🥙\n\nBuy what you like, count your change, and save up for something special.\n\nEvery coin you claim back is a small victory! 🪙",
        accentColor: .simitSarisi,
        speechText: "You have fifty coins and a whole canteen of yummy snacks! Buy what you like, count your change, and save up for something special!",
        showKidScene: .none
    ),
    StoryCard(
        emoji: "🦸",
        title: "Your Mission",
        body: "Be the hero that little kid at the canteen needed.\n\nCount coins. Make change. Earn stars. ⭐\n\nMaths isn't scary — it's your superpower. Now go prove it! 💪",
        accentColor: .tostTuruncusu,
        speechText: "Be the hero that little kid at the canteen needed. Count coins. Make change. Earn stars. Maths isn't scary — it's your superpower. Now go prove it!",
        showKidScene: .none
    ),
]

// MARK: - Story View

struct StoryView: View {
    @Environment(GameManager.self) private var game
    @State private var currentIndex = 0
    @State private var showDifficultyPicker = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            CanteenMeshGradient()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        game.navigate(to: .splash)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Back to main screen")

                    Spacer()
                    progressDots
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, CanteenSpacing.l)
                .padding(.top, CanteenSpacing.xl)

                Spacer()

                TabView(selection: $currentIndex) {
                    ForEach(storyCards.indices, id: \.self) { idx in
                        StoryCardView(card: storyCards[idx])
                            .tag(idx)
                            .padding(.horizontal, CanteenSpacing.l)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 520)
                .animation(reduceMotion ? nil : .spring(duration: 0.4, bounce: 0.1), value: currentIndex)

                Spacer()

                navigationRow
                    .padding(.horizontal, CanteenSpacing.l)
                    .padding(.bottom, CanteenSpacing.xl)
            }
        }
        .onAppear {
            SpeechService.shared.speak(storyCards[0].speechText, rate: 0.43, pitch: 1.1)
        }
        .onChange(of: currentIndex) { _, newIdx in
            if !reduceMotion {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            SpeechService.shared.speak(storyCards[newIdx].speechText, rate: 0.43, pitch: 1.1)
        }
        .sheet(isPresented: $showDifficultyPicker) {
            DifficultyPickerSheet {
                showDifficultyPicker = false
                game.navigate(to: .goalPicker)
            }
            .presentationDetents(
                UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium]
            )
            .presentationDragIndicator(.visible)
        }
    }

    private var progressDots: some View {
        HStack(spacing: CanteenSpacing.s) {
            ForEach(storyCards.indices, id: \.self) { idx in
                Capsule()
                    .fill(idx == currentIndex ? Color.simitSarisi : Color.cikolataKahvesi.opacity(0.2))
                    .frame(width: idx == currentIndex ? 28 : 8, height: 8)
                    .animation(.spring(duration: 0.3), value: currentIndex)
            }
        }
        .accessibilityLabel("Page \(currentIndex + 1) of \(storyCards.count)")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var navigationRow: some View {
        HStack {
            if currentIndex > 0 {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(duration: 0.3)) { currentIndex -= 1 }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.canteenSecondary)
                .accessibilityLabel("Previous page")
                .accessibilityHint("Go back to the previous story card")
            }

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if currentIndex < storyCards.count - 1 {
                    withAnimation(.spring(duration: 0.3)) { currentIndex += 1 }
                } else {
                    showDifficultyPicker = true
                }
            } label: {
                if currentIndex < storyCards.count - 1 {
                    Label("Next", systemImage: "chevron.right")
                } else {
                    Label("Let's Go!", systemImage: "storefront.fill")
                }
            }
            .buttonStyle(.canteenPrimary)
            .accessibilityLabel(currentIndex < storyCards.count - 1 ? "Next page" : "Let's Go — start the game")
            .accessibilityHint(currentIndex < storyCards.count - 1 ? "See the next story card" : "Choose difficulty and start shopping")
        }
    }
}

// MARK: - Story Card View

private struct StoryCardView: View {
    let card: StoryCard
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: CanteenSpacing.m) {
            // Scene illustration (only on cards that have one)
            if card.showKidScene != .none {
                KidSceneView(scene: card.showKidScene)
                    .frame(height: 90)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : (reduceMotion ? 1 : 0.85))
                    .animation(
                        reduceMotion ? .none : .spring(duration: 0.5, bounce: 0.3).delay(0.05),
                        value: appeared
                    )
            } else {
                // Emoji fallback for cards without illustration
                Text(card.emoji)
                    .font(.system(size: 64))
                    .scaleEffect(reduceMotion ? 1.0 : (appeared ? 1.0 : 0.4))
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(
                        reduceMotion ? .none : .spring(duration: 0.55, bounce: 0.50),
                        value: appeared
                    )
            }

            VStack(spacing: CanteenSpacing.s) {
                Text(card.title)
                    .font(CanteenTypography.sectionTitle)
                    .foregroundStyle(Color.cikolataKahvesi)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(card.body)
                    .font(CanteenTypography.bodyText)
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 14))
            .animation(.easeOut(duration: 0.4).delay(0.18), value: appeared)
        }
        .padding(CanteenSpacing.xl)
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: CanteenRadius.l))
        .shadow(color: card.accentColor.opacity(0.15), radius: 20, x: 0, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.title). \(card.body)")
        .onAppear {
            if !reduceMotion {
                withAnimation { appeared = true }
            } else {
                appeared = true
            }
        }
        .onDisappear { appeared = false }
    }
}

// MARK: - Kid Scene Illustrations

private struct KidSceneView: View {
    let scene: StoryCard.KidScene
    @State private var coinWobble = false

    var body: some View {
        ZStack {
            switch scene {
            case .scared:    ScaredAtCounterScene(coinWobble: $coinWobble)
            case .watching:  WatchingScene()
            case .icon:      IconKidScene()
            case .none:      EmptyView()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                coinWobble = true
            }
        }
    }
}

// MARK: Scene 1 — Scared kid at canteen counter, coins trembling in hand

private struct ScaredAtCounterScene: View {
    @Binding var coinWobble: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            // Canteen counter top
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.55, green: 0.38, blue: 0.25))
                .frame(width: 220, height: 14)
                .offset(y: 0)

            // Counter front
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.45, green: 0.30, blue: 0.20))
                .frame(width: 220, height: 30)
                .offset(y: 22)

            // Simit on counter
            ZStack {
                Circle()
                    .stroke(Color(red: 0.72, green: 0.45, blue: 0.20), lineWidth: 9)
                    .frame(width: 28, height: 28)
                Circle()
                    .fill(Color(red: 0.98, green: 0.96, blue: 0.93))
                    .frame(width: 12, height: 12)
            }
            .offset(x: 50, y: -10)

            // Price tag
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 24, height: 14)
                Text("7🪙")
                    .font(.system(size: 7, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.cikolataKahvesi)
            }
            .offset(x: 50, y: -28)

            // Kid body (simplified hoodie)
            ZStack {
                // Body
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.25, green: 0.65, blue: 0.35))
                    .frame(width: 32, height: 28)
                    .offset(y: 14)
                // Head
                Circle()
                    .fill(Color(red: 0.96, green: 0.80, blue: 0.65))
                    .frame(width: 28, height: 28)
                // Hair
                Capsule()
                    .fill(Color(red: 0.30, green: 0.18, blue: 0.10))
                    .frame(width: 30, height: 8)
                    .offset(y: -11)
                // Worried eyes
                HStack(spacing: 6) {
                    Circle().fill(Color.cikolataKahvesi).frame(width: 4, height: 4)
                    Circle().fill(Color.cikolataKahvesi).frame(width: 4, height: 4)
                }
                .offset(y: 2)
                // Sweat drop
                Circle()
                    .fill(Color(red: 0.50, green: 0.75, blue: 1.0).opacity(0.8))
                    .frame(width: 4, height: 5)
                    .offset(x: 16, y: 4)
            }
            .offset(x: -60, y: -16)

            // Trembling coin in kid's hand
            ZStack {
                Circle()
                    .fill(Color(red: 0.85, green: 0.65, blue: 0.13))
                    .frame(width: 18, height: 18)
                Text("20")
                    .font(.system(size: 6, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.36, green: 0.24, blue: 0.18))
            }
            .offset(x: -38, y: -8)
            .rotationEffect(.degrees(coinWobble ? 8 : -8))
            .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: coinWobble)
        }
        .frame(width: 220, height: 90)
    }
}

// MARK: Scene 2 — Developer watching a kid leave without change

private struct WatchingScene: View {
    @State private var arrowOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Running kid (leaving)
            ZStack {
                // Body
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.90, green: 0.35, blue: 0.25))
                    .frame(width: 26, height: 22)
                    .offset(y: 10)
                // Head
                Circle()
                    .fill(Color(red: 0.96, green: 0.80, blue: 0.65))
                    .frame(width: 22, height: 22)
                // Happy (unaware) eyes
                HStack(spacing: 5) {
                    Circle().fill(Color.cikolataKahvesi).frame(width: 3, height: 3)
                    Circle().fill(Color.cikolataKahvesi).frame(width: 3, height: 3)
                }
                .offset(y: 2)
                // Smile
                Path { p in
                    p.move(to: CGPoint(x: -4, y: 6))
                    p.addQuadCurve(to: CGPoint(x: 4, y: 6),
                                   control: CGPoint(x: 0, y: 10))
                }
                .stroke(Color.cikolataKahvesi, lineWidth: 1.5)
            }
            .offset(x: 40, y: -5)

            // Lost coins floating away
            ForEach(0..<3, id: \.self) { i in
                ZStack {
                    Circle()
                        .fill(Color.simitSarisi.opacity(0.8))
                        .frame(width: 10, height: 10)
                    Text("1")
                        .font(.system(size: 5, weight: .black))
                        .foregroundStyle(Color.cikolataKahvesi)
                }
                .offset(
                    x: 60 + CGFloat(i) * 12 + arrowOffset,
                    y: -20 - CGFloat(i) * 6
                )
                .opacity(0.6)
            }

            // Observer kid (watching, concerned)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.25, green: 0.65, blue: 0.35))
                    .frame(width: 26, height: 22)
                    .offset(y: 10)
                Circle()
                    .fill(Color(red: 0.96, green: 0.80, blue: 0.65))
                    .frame(width: 22, height: 22)
                // Concerned eyes (wider)
                HStack(spacing: 5) {
                    Circle().fill(Color.cikolataKahvesi).frame(width: 4, height: 4)
                    Circle().fill(Color.cikolataKahvesi).frame(width: 4, height: 4)
                }
                .offset(y: 2)
                // Raised eyebrow line
                Path { p in
                    p.move(to: CGPoint(x: -6, y: -4))
                    p.addLine(to: CGPoint(x: -1, y: -6))
                }
                .stroke(Color.cikolataKahvesi, lineWidth: 1.2)
            }
            .offset(x: -60, y: -5)

            // Thought bubble: lightbulb
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 22, height: 22)
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.simitSarisi)
            }
            .offset(x: -40, y: -36)

            // Dotted connection: thought to observer
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.cikolataKahvesi.opacity(0.25))
                    .frame(width: 3, height: 3)
                    .offset(x: -50 + CGFloat(i) * 6, y: -25)
            }
        }
        .frame(width: 220, height: 90)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                arrowOffset = 20
            }
        }
    }
}

// MARK: Scene 3 — The icon kid holding a coin, proud

private struct IconKidScene: View {
    @State private var coinGlow = false
    @State private var starOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Glow behind character
            Circle()
                .fill(Color.simitSarisi.opacity(coinGlow ? 0.18 : 0.05))
                .frame(width: 80, height: 80)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: coinGlow)

            // Body (green hoodie — matches app icon)
            ZStack {
                // Hoodie body
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.25, green: 0.65, blue: 0.35))
                    .frame(width: 40, height: 34)
                    .offset(y: 20)
                // Hoodie pocket
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.20, green: 0.55, blue: 0.30))
                    .frame(width: 14, height: 8)
                    .offset(y: 26)
                // Head
                Circle()
                    .fill(Color(red: 0.96, green: 0.80, blue: 0.65))
                    .frame(width: 36, height: 36)
                // Hair
                Capsule()
                    .fill(Color(red: 0.30, green: 0.18, blue: 0.10))
                    .frame(width: 38, height: 10)
                    .offset(y: -15)
                // Glasses (matches icon)
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.cikolataKahvesi, lineWidth: 1.5)
                        .frame(width: 10, height: 8)
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.cikolataKahvesi, lineWidth: 1.5)
                        .frame(width: 10, height: 8)
                }
                .offset(y: 0)
                // Cheeks
                HStack(spacing: 20) {
                    Circle()
                        .fill(Color(red: 0.96, green: 0.60, blue: 0.60).opacity(0.5))
                        .frame(width: 7, height: 5)
                    Circle()
                        .fill(Color(red: 0.96, green: 0.60, blue: 0.60).opacity(0.5))
                        .frame(width: 7, height: 5)
                }
                .offset(y: 5)
                // Big smile
                Path { p in
                    p.move(to: CGPoint(x: -7, y: 8))
                    p.addQuadCurve(to: CGPoint(x: 7, y: 8),
                                   control: CGPoint(x: 0, y: 14))
                }
                .stroke(Color.cikolataKahvesi, lineWidth: 1.8)
            }

            // Coin held up proudly (right side)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.98, green: 0.85, blue: 0.30), Color(red: 0.85, green: 0.60, blue: 0.10)],
                            center: .topLeading,
                            startRadius: 2,
                            endRadius: 16
                        )
                    )
                    .frame(width: 22, height: 22)
                    .shadow(color: Color.simitSarisi.opacity(0.6), radius: coinGlow ? 8 : 3)
                Text("🙂")
                    .font(.system(size: 10))
            }
            .offset(x: 32, y: 2)
            .scaleEffect(coinGlow ? 1.08 : 0.96)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: coinGlow)

            // Floating stars
            ForEach(0..<3, id: \.self) { i in
                Text("⭐️")
                    .font(.system(size: 9 + CGFloat(i) * 2))
                    .offset(
                        x: -48 + CGFloat(i) * 16,
                        y: -30 - starOffset * (1 + CGFloat(i) * 0.3)
                    )
                    .opacity(0.7)
            }
        }
        .frame(width: 220, height: 90)
        .onAppear {
            coinGlow = true
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                starOffset = 6
            }
        }
    }
}

// MARK: - Difficulty Picker Sheet

private struct DifficultyPickerSheet: View {
    @Environment(GameManager.self) private var game
    let onStart: () -> Void
    @State private var selected: DifficultyLevel = .easy

    var body: some View {
        VStack(spacing: CanteenSpacing.l) {
            VStack(spacing: CanteenSpacing.s) {
                Text("🎯")
                    .font(.system(size: 48))

                Text("Choose Your Challenge")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.cikolataKahvesi)
                    .accessibilityAddTraits(.isHeader)

                Text("You can always play again at a harder level!")
                    .font(CanteenTypography.caption)
                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, CanteenSpacing.l)

            VStack(spacing: CanteenSpacing.s) {
                ForEach(DifficultyLevel.allCases) { level in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(duration: 0.3)) { selected = level }
                    } label: {
                        HStack(spacing: CanteenSpacing.m) {
                            Text(level.emoji)
                                .font(.system(size: 28))
                                .frame(width: 38)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.rawValue)
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                    .foregroundStyle(Color.cikolataKahvesi)
                                Text(level.description)
                                    .font(CanteenTypography.caption)
                                    .foregroundStyle(Color.cikolataKahvesi.opacity(0.55))
                            }

                            Spacer()

                            if selected == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color.basariYesili)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(CanteenSpacing.m)
                        .background(selected == level ? Color.simitSarisi.opacity(0.12) : Color.gray.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.m))
                        .overlay(
                            RoundedRectangle(cornerRadius: CanteenRadius.m)
                                .stroke(selected == level ? Color.simitSarisi : Color.gray.opacity(0.15), lineWidth: 2)
                        )
                    }
                    .accessibilityLabel("\(level.rawValue): \(level.description)")
                    .accessibilityHint(selected == level ? "Selected" : "Tap to select")
                }
            }
            .padding(.horizontal, CanteenSpacing.l)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                game.difficulty = selected
                onStart()
            } label: {
                Label("Start at \(selected.rawValue)!", systemImage: "storefront.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.canteenPrimary)
            .padding(.horizontal, CanteenSpacing.l)
            .padding(.bottom, CanteenSpacing.l)
            .accessibilityLabel("Start game at \(selected.rawValue) difficulty")
        }
    }
}
