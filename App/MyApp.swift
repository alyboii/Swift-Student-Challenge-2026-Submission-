import SwiftUI
import SwiftData

@main
struct MyApp: App {
    let container: ModelContainer = {
        do {
            return try ModelContainer(for: GameState.self)
        } catch {
            // Persistent store failed — fall back to in-memory so the app still launches
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try! ModelContainer(for: GameState.self, configurations: config)
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
