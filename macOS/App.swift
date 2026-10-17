import SwiftUI

@main
struct MetalCraftApp: App {
    @StateObject var renderer = WorldRenderer(
        generator: GameWorld(seed: UInt32.random(in: 0...0xFFFFFFFF)),
        cameraPos: Float3(0, 90, 0)
    )
    
    var body: some Scene {
        WindowGroup {
            MacOSGameView()
                .environmentObject(renderer)
        }
    }
}
