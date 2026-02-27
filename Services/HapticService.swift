import AudioToolbox
import CoreHaptics
import UIKit



@MainActor
final class HapticService {

    static let shared = HapticService()
    private init() { prepareEngine() }

    // MARK: - Engine

    private var engine: CHHapticEngine?
    private var engineReady = false

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()

            // Restart engine after audio interruptions or backgrounding
            engine?.resetHandler = { [weak self] in
                do { try self?.engine?.start() } catch {}
            }
            engine?.stoppedHandler = { [weak self] _ in
                self?.engineReady = false
            }

            try engine?.start()
            engineReady = true
        } catch {
            engineReady = false
        }
    }

    // Try restarting the engine if it has stopped
    private func ensureEngineRunning() {
        guard !engineReady, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        prepareEngine()
    }

    // MARK: - Private Player

    private func play(_ pattern: CHHapticPattern) {
        ensureEngineRunning()
        guard let engine, engineReady else { return }
        do {
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    // MARK: - 1. ✅ Correct Change (Duolingo celebration style)
    // 3-phase escalating tap: soft → medium → strong crisp
    // A short "glow" sustain is added to the final tap, then fades out.
    // Message: "Perfect, exactly right!"

    func correctChange() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        do {
            let tap1 = try makeTransient(time: 0.00, intensity: 0.40, sharpness: 0.6)
            let tap2 = try makeTransient(time: 0.13, intensity: 0.70, sharpness: 0.75)
            let tap3 = try makeTransient(time: 0.27, intensity: 1.00, sharpness: 0.95)

            // Short sustained "victory" vibration
            let glow = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
                ],
                relativeTime: 0.27,
                duration: 0.35
            )

            // Glow → fade to 0
            let fade = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.27, value: 0.45),
                    .init(relativeTime: 0.62, value: 0.00)
                ],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(events: [tap1, tap2, tap3, glow],
                                              parameterCurves: [fade])
            play(pattern)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    // MARK: - 2. ❌ Too Much Change (dull double-bump)
    // Two muffled (low sharpness) taps: "blocked / wrong"
    // Not punishingly intense — child-friendly, warning-style.

    func tooMuchChange() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        do {
            let bump1 = try makeTransient(time: 0.00, intensity: 0.80, sharpness: 0.10)
            let bump2 = try makeTransient(time: 0.11, intensity: 0.55, sharpness: 0.10)
            let pattern = try CHHapticPattern(events: [bump1, bump2], parameters: [])
            play(pattern)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    // MARK: - 3. 🪙 Coin Tap (crisp click)
    // Physical coin pickup feel.
    // High sharpness = crisp "click" sensation.
    // Fires on every coin tap — kept very light.

    func coinTap() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }
        do {
            let click = try makeTransient(time: 0.00, intensity: 0.50, sharpness: 1.00)
            let pattern = try CHHapticPattern(events: [click], parameters: [])
            play(pattern)
        } catch {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    // MARK: - 4. 🏅 Achievement Unlock (heartbeat pulse)
    // Small anticipation tap + strong main tap + soft "glow" fade.
    // Synced with badge animation: small bounce → big bounce.

    func achievementUnlock() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        do {
            let anticipation = try makeTransient(time: 0.00, intensity: 0.45, sharpness: 0.40)
            let punch        = try makeTransient(time: 0.16, intensity: 1.00, sharpness: 0.55)

            let glow = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.38),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.20)
                ],
                relativeTime: 0.16,
                duration: 0.65
            )

            let glowFade = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0.16, value: 0.38),
                    .init(relativeTime: 0.81, value: 0.00)
                ],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(events: [anticipation, punch, glow],
                                              parameterCurves: [glowFade])
            play(pattern)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    // MARK: - 5. 🛒 Purchase Confirm (satisfying thud)
    // Fires when a product is purchased: medium intensity, mid sharpness.
    // "Decision made and confirmed" feel — neither too light nor too heavy.

    func purchaseConfirm() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        do {
            let thud = try makeTransient(time: 0.00, intensity: 0.80, sharpness: 0.60)
            // Small secondary "settle" tap
            let settle = try makeTransient(time: 0.09, intensity: 0.30, sharpness: 0.50)
            let pattern = try CHHapticPattern(events: [thud, settle], parameters: [])
            play(pattern)
        } catch {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - 6. 🎯 Goal Selected (rising double-tap)
    // Fires when a goal is selected: two upward taps, feels optimistic.

    func goalSelected() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        do {
            let first  = try makeTransient(time: 0.00, intensity: 0.55, sharpness: 0.70)
            let second = try makeTransient(time: 0.14, intensity: 0.90, sharpness: 0.85)
            let pattern = try CHHapticPattern(events: [first, second], parameters: [])
            play(pattern)
        } catch {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - 7. 🪙 Coin Value Haptic (for CoinIntro screen)
    // Each coin value has a distinct "finger language" vibration:
    //   1  → single light click    ("tick")
    //   5  → double click          ("tick-tick")
    //  10  → thud + vibration      ("THUD~")
    //  20  → BOOM + deep rumble    ("KABOOM~~~")
    // The child's hand "feels" the coin — understands size without reading.

    func coinValueHaptic(value: Int) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            let style: UIImpactFeedbackGenerator.FeedbackStyle
            switch value {
            case 1:  style = .light
            case 5:  style = .light
            case 10: style = .medium
            default: style = .heavy
            }
            UIImpactFeedbackGenerator(style: style)
                .impactOccurred(intensity: min(Double(value) / 20.0, 1.0))
            return
        }
        do {
            switch value {
            case 1:
                // Single light transient — feather-touch feel
                let tap = try makeTransient(time: 0.00, intensity: 0.22, sharpness: 0.95)
                let pattern = try CHHapticPattern(events: [tap], parameters: [])
                play(pattern)

            case 5:
                // Double quick clicks — rhythm differentiates
                let tap1 = try makeTransient(time: 0.00, intensity: 0.45, sharpness: 0.80)
                let tap2 = try makeTransient(time: 0.07, intensity: 0.55, sharpness: 0.80)
                let pattern = try CHHapticPattern(events: [tap1, tap2], parameters: [])
                play(pattern)

            case 10:
                // Medium thud + short vibration decay
                let thud = try makeTransient(time: 0.00, intensity: 0.80, sharpness: 0.35)
                let resonance = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
                    ],
                    relativeTime: 0.00,
                    duration: 0.28
                )
                let resFade = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [
                        .init(relativeTime: 0.00, value: 0.45),
                        .init(relativeTime: 0.28, value: 0.00)
                    ],
                    relativeTime: 0
                )
                let pattern = try CHHapticPattern(events: [thud, resonance], parameterCurves: [resFade])
                play(pattern)

            default: // 20
                // BOOM + long deep rumble + aftershock
                let boom = try makeTransient(time: 0.00, intensity: 1.00, sharpness: 0.05)
                let rumble = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.08)
                    ],
                    relativeTime: 0.00,
                    duration: 0.55
                )
                let rumbleFade = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [
                        .init(relativeTime: 0.00, value: 0.75),
                        .init(relativeTime: 0.30, value: 0.40),
                        .init(relativeTime: 0.55, value: 0.00)
                    ],
                    relativeTime: 0
                )
                let aftershock = try makeTransient(time: 0.60, intensity: 0.30, sharpness: 0.50)
                let pattern = try CHHapticPattern(events: [boom, rumble, aftershock], parameterCurves: [rumbleFade])
                play(pattern)
            }
        } catch {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - System Sound Effects (AudioToolbox)

    func playCorrectSound() {
        AudioServicesPlaySystemSound(1025)   // Tri-tone ding
    }

    func playWrongSound() {
        AudioServicesPlaySystemSound(1053)   // Low beep
    }

    func playCoinSound() {
        AudioServicesPlaySystemSound(1104)   // Key press click
    }

    func playCelebrationSound() {
        AudioServicesPlaySystemSound(1335)   // Mail sent swoosh
    }

    // MARK: - Helper

    private func makeTransient(time: TimeInterval,
                               intensity: Float,
                               sharpness: Float) throws -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: time
        )
    }
}
