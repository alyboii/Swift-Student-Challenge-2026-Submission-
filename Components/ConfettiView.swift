import SwiftUI

// MARK: - Confetti Particle System
// Canvas-based particle animation. Used in the success overlay and goal screen.

// MARK: - Particle Model

private struct ConfettiParticle: Sendable {
    let id: Int
    let x: CGFloat           // 0.0 - 1.0 (normalized width)
    let color: Color
    let size: CGFloat
    let speed: CGFloat        // pixels per second
    let wobbleFreq: CGFloat   // horizontal oscillation frequency
    let wobbleAmp: CGFloat    // horizontal oscillation amplitude
    let rotation: Double      // initial rotation
    let rotationSpeed: Double // degrees per second
    let birth: Date
    let shape: ParticleShape

    enum ParticleShape: Int, CaseIterable, Sendable {
        case circle, square, triangle, coin
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    var isActive: Bool
    var intensity: Int = 40  // number of particles

    @State private var particles: [ConfettiParticle] = []
    private let lifeDuration: Double = 2.8

    // Apple Pride colors — celebrate inclusivity with every correct answer
    private let colors: [Color] = Color.prideColors

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: particles.isEmpty)) { timeline in
            Canvas(rendersAsynchronously: true) { context, size in
                let now = timeline.date

                for particle in particles {
                    let age = now.timeIntervalSince(particle.birth)
                    guard age >= 0 && age < lifeDuration else { continue }

                    let progress = age / lifeDuration
                    let opacity = progress < 0.7 ? 1.0 : (1.0 - (progress - 0.7) / 0.3)

                    let startX = particle.x * size.width
                    let x = startX + sin(age * particle.wobbleFreq) * particle.wobbleAmp
                    let y = age * particle.speed

                    guard y < size.height + 20 else { continue }

                    let rotation = Angle.degrees(particle.rotation + age * particle.rotationSpeed)
                    let sz = particle.size

                    context.opacity = opacity
                    context.translateBy(x: x, y: y)
                    context.rotate(by: rotation)

                    let rect = CGRect(x: -sz / 2, y: -sz / 2, width: sz, height: sz)

                    switch particle.shape {
                    case .circle:
                        context.fill(Path(ellipseIn: rect), with: .color(particle.color))
                    case .square:
                        context.fill(Path(rect), with: .color(particle.color))
                    case .triangle:
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: -sz / 2))
                        path.addLine(to: CGPoint(x: sz / 2, y: sz / 2))
                        path.addLine(to: CGPoint(x: -sz / 2, y: sz / 2))
                        path.closeSubpath()
                        context.fill(path, with: .color(particle.color))
                    case .coin:
                        // Mini coin: circle + inner ring
                        context.fill(Path(ellipseIn: rect), with: .color(particle.color))
                        let innerRect = rect.insetBy(dx: sz * 0.25, dy: sz * 0.25)
                        context.fill(Path(ellipseIn: innerRect), with: .color(particle.color.opacity(0.5)))
                    }

                    // Reset transform
                    context.rotate(by: -rotation)
                    context.translateBy(x: -x, y: -y)
                    context.opacity = 1.0
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { _, active in
            if active { spawnParticles() }
            else { particles = [] }
        }
        .onAppear {
            if isActive { spawnParticles() }
        }
    }

    // MARK: - Spawn

    private func spawnParticles() {
        let now = Date()
        particles = (0..<intensity).map { i in
            ConfettiParticle(
                id: i,
                x: CGFloat.random(in: 0.05...0.95),
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 6...14),
                speed: CGFloat.random(in: 90...200),
                wobbleFreq: CGFloat.random(in: 2...5),
                wobbleAmp: CGFloat.random(in: 15...40),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -180...180),
                birth: now.addingTimeInterval(Double.random(in: 0...0.5)),
                shape: ConfettiParticle.ParticleShape.allCases.randomElement() ?? .circle
            )
        }

        // Auto-clear after animation
        Task {
            try? await Task.sleep(nanoseconds: UInt64((lifeDuration + 0.6) * 1_000_000_000))
            particles = []
        }
    }
}

// MARK: - Preview Helper

#Preview {
    ZStack {
        Color.ayranBeyazi.ignoresSafeArea()
        ConfettiView(isActive: true, intensity: 50)
    }
}
