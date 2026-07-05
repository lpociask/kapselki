import SwiftUI

@main
struct KapselkiApp: App {
    var body: some Scene {
        WindowGroup {
            KapselkiGameView()
                .preferredColorScheme(.light)
        }
    }
}
