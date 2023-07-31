import SwiftUI

@main
struct MetalCraftApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(renderer: gameRenderer)
        }
    }
}
