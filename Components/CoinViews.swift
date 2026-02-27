import SwiftUI

// MARK: - Coin Bank Button
// Tappable + draggable coin in the coin bank row
// Size is adaptive: 64 on iPhone, 80 on iPad

struct CoinBankButton: View {
    let denomination: CoinDenomination
    var size: CGFloat = 64
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            pressed = true
            Task {
                try? await Task.sleep(for: .seconds(0.1))
                pressed = false
            }
            onTap()
        } label: {
            Image(systemName: "\(denomination.rawValue).circle.fill")
                .font(.system(size: size))
                .foregroundStyle(.white, denomination.coinColor, denomination.coinColor.opacity(0.8))
                .symbolRenderingMode(.palette)
                .symbolEffect(.wiggle.byLayer, options: .repeating, value: pressed)
                .shadow(color: denomination.coinColor.opacity(0.55), radius: 6, x: 0, y: 4)
                .scaleEffect(pressed ? 0.86 : 1.0)
                .animation(.spring(duration: 0.15), value: pressed)
        }
        .accessibilityLabel("\(denomination.rawValue) coin")
        .accessibilityHint("Adds a \(denomination.rawValue) coin to your change tray")
        .draggable(String(denomination.rawValue))
    }
}

// MARK: - Tray Chip View
// A coin placed in the tray — tap to remove

struct TrayChipView: View {
    let denomination: CoinDenomination
    let onRemove: () -> Void

    var body: some View {
        Button(action: onRemove) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "\(denomination.rawValue).circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.white, denomination.coinColor, denomination.coinColor.opacity(0.8))
                    .symbolRenderingMode(.palette)
                    .shadow(color: denomination.coinColor.opacity(0.4), radius: 3, x: 0, y: 2)

                ZStack {
                    Circle()
                        .fill(Color.hataKirmizisi)
                        .frame(width: 18, height: 18)
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: 5, y: -5)
            }
        }
        .frame(width: 62, height: 62)
        .accessibilityLabel("\(denomination.rawValue) coin in tray")
        .accessibilityHint("Removes this \(denomination.rawValue) coin from your tray")
    }
}

// MARK: - Celebration Emoji with PhaseAnimator

struct CelebrationEmojiView: View {
    @State private var trigger = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Phase: CaseIterable {
        case idle, pop, float, bounce, settle

        var scale: Double {
            switch self {
            case .idle:   return 0.3
            case .pop:    return 1.35
            case .float:  return 1.15
            case .bounce: return 1.25
            case .settle: return 1.0
            }
        }

        var yOffset: Double {
            switch self {
            case .idle:   return 20
            case .pop:    return -18
            case .float:  return -26
            case .bounce: return -14
            case .settle: return 0
            }
        }

        var opacity: Double { self == .idle ? 0 : 1 }
    }

    var body: some View {
        Text("🎉")
            .font(.system(size: 78))
            .phaseAnimator(Phase.allCases, trigger: trigger) { view, phase in
                view
                    .scaleEffect(reduceMotion ? 1.0 : phase.scale)
                    .offset(y: reduceMotion ? 0 : phase.yOffset)
                    .opacity(phase.opacity)
            } animation: { phase in
                switch phase {
                case .idle:   return .easeOut(duration: 0.01)
                case .pop:    return .spring(duration: 0.30, bounce: 0.55)
                case .float:  return .easeInOut(duration: 0.22)
                case .bounce: return .spring(duration: 0.25, bounce: 0.45)
                case .settle: return .spring(duration: 0.35, bounce: 0.20)
                }
            }
            .onAppear { trigger = true }
    }
}
