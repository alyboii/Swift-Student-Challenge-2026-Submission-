import SwiftUI

// MARK: - Goal Celebration Overlay

struct GoalCelebrationOverlay: View {
    let goal: SavingsGoal
    let onDismiss: () -> Void

    @State private var emojiScale: CGFloat = 0.3
    @State private var emojiOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var confettiPhase: Int = 0
    @State private var ringProgress: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            // Confetti particles
            CelebrationConfettiView(phase: confettiPhase)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: CanteenSpacing.l) {
                // Animated ring + emoji
                ZStack {
                    // Glowing ring
                    Circle()
                        .stroke(Color.gray.opacity(0.12), lineWidth: 8)
                        .frame(width: 120, height: 120)

                    ProgressArc(progress: ringProgress)
                        .stroke(
                            LinearGradient(
                                colors: Color.prideColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .animation(.spring(duration: 1.2, bounce: 0.1), value: ringProgress)

                    Text(goal.emoji)
                        .font(.system(size: 56))
                        .scaleEffect(emojiScale)
                        .opacity(emojiOpacity)
                }

                VStack(spacing: CanteenSpacing.s) {
                    Text("🎉 Goal Reached! 🎉")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.basariYesili)
                        .accessibilityAddTraits(.isHeader)

                    Text("You saved enough for a **\(goal.name)**!")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.cikolataKahvesi)
                        .multilineTextAlignment(.center)

                    Text("Champion saver! Every coin counted. 🏆")
                        .font(CanteenTypography.caption)
                        .foregroundStyle(Color.cikolataKahvesi.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .opacity(textOpacity)

                VStack(spacing: CanteenSpacing.s) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onDismiss()
                    } label: {
                        Label("Continue", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityLabel("Continue to summary")
                }
                .opacity(textOpacity)
            }
            .padding(CanteenSpacing.xl)
            .background(.white.opacity(0.97))
            .clipShape(RoundedRectangle(cornerRadius: CanteenRadius.l + 4))
            .shadow(color: Color.basariYesili.opacity(0.35), radius: 32, x: 0, y: 16)
            .padding(.horizontal, CanteenSpacing.xl)
        }
        .accessibilityElement(children: .contain)
        .onAppear {
            SpeechService.shared.speak("Congratulations! You reached your savings goal for \(goal.name)! You're a champion saver!")
            HapticService.shared.purchaseConfirm()

            let delay1: Double = 0.15
            let delay2: Double = 0.5
            let delay3: Double = 0.8

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(delay1))
                withAnimation(.spring(duration: 0.7, bounce: 0.45)) {
                    emojiScale = 1.0
                    emojiOpacity = 1.0
                }
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(delay2))
                ringProgress = 1.0
                withAnimation(.easeOut(duration: 0.5)) {
                    textOpacity = 1.0
                }
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(delay3))
                confettiPhase += 1
            }
        }
    }
}

// MARK: - Confetti View

private struct CelebrationConfettiView: View {
    let phase: Int
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.x * size.width - 4,
                    y: particle.y * size.height - 4,
                    width: 8,
                    height: 8
                )
                context.fill(
                    RoundedRectangle(cornerRadius: 2).path(in: rect),
                    with: .color(particle.color.opacity(particle.opacity))
                )
            }
        }
        .onChange(of: phase) { _, _ in
            spawnConfetti()
        }
    }

    private func spawnConfetti() {
        let colors: [Color] = Color.prideColors + [.simitSarisi, .basariYesili]
        var newParticles: [ConfettiParticle] = []
        for _ in 0..<60 {
            newParticles.append(ConfettiParticle(
                x: Double.random(in: 0.1...0.9),
                y: Double.random(in: -0.2...(-0.05)),
                color: colors.randomElement() ?? .simitSarisi,
                opacity: 1.0
            ))
        }
        particles = newParticles

        // Animate particles falling
        Task { @MainActor in
            for step in 1...30 {
                try? await Task.sleep(for: .milliseconds(50))
                particles = particles.map { p in
                    var updated = p
                    updated.y += 0.035 + Double.random(in: 0...0.015)
                    updated.x += Double.random(in: -0.008...0.008)
                    if step > 20 {
                        updated.opacity = max(0, p.opacity - 0.1)
                    }
                    return updated
                }
            }
            particles = []
        }
    }
}

private struct ConfettiParticle {
    var x: Double
    var y: Double
    var color: Color
    var opacity: Double
}
