import AudioToolbox
import UIKit

@MainActor
final class HapticService {

    static let shared = HapticService()
    private init() {}

    // MARK: - 1. Correct Change

    func correctChange() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - 2. Too Much Change

    func tooMuchChange() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    // MARK: - 3. Coin Tap

    func coinTap() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    // MARK: - 4. Achievement Unlock

    func achievementUnlock() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - 5. Purchase Confirm

    func purchaseConfirm() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - 6. Goal Selected

    func goalSelected() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - 7. Coin Value Haptic

    func coinValueHaptic(value: Int) {
        switch value {
        case 1:
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.3)
        case 5:
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.6)
        case 10:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        default:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    // MARK: - System Sound Effects

    func playCorrectSound() {
        AudioServicesPlaySystemSound(1025)
    }

    func playWrongSound() {
        AudioServicesPlaySystemSound(1053)
    }

    func playCoinSound() {
        AudioServicesPlaySystemSound(1104)
    }

    func playCelebrationSound() {
        AudioServicesPlaySystemSound(1335)
    }
}
