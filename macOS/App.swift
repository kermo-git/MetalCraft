import SwiftUI

@main
struct MetalCraftApp: App {
    @StateObject var renderer = WorldRenderer(
        generator: GameWorld(),
        cameraPos: Float3(0, 90, 0)
    )
    
    var body: some Scene {
        WindowGroup {
            MacOSGameView()
                .environmentObject(renderer)
        }
    }
}
