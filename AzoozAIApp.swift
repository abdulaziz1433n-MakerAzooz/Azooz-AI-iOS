import SwiftUI

@main
struct AzoozAIApp: App {
    var body: some Scene {
        WindowGroup {
            ChatView()
                .preferredColorScheme(nil)
        }
    }
}
