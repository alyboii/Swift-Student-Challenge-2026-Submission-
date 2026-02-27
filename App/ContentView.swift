import SwiftUI
import SwiftData

// MARK: - Content View
// Root navigation switch. Each screen transition uses a spring animation.

struct ContentView: View {
    @State private var game = GameManager()
    @State private var hasSetup = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            switch game.screen {
            case .splash:
                SplashView()
                    .transition(.opacity)

            case .story:
                StoryView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))

            case .goalPicker:
                GoalPickerView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))

            case .coinIntro:
                CoinIntroView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))

            case .canteen:
                CanteenView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))

            case .changeGame:
                ChangeGameView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))

            case .summary:
                SummaryView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .opacity
                    ))

            case .goalSetting:
                GoalSettingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .opacity
                    ))
            }
        }
        .animation(.spring(duration: 0.42, bounce: 0.08), value: game.screen)
        .environment(game)
        .onAppear {
            guard !hasSetup else { return }
            hasSetup = true
            game.setup(with: modelContext)
        }
    }
}
