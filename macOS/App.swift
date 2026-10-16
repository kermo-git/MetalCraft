import SwiftUI

@main
struct MetalCraftApp: App {
    @StateObject var renderer = WorldRenderer(
        generator: GameWorld(seed: UInt64.random(in: 0...0xFFFFFFFFFFFFFFFF)),
        cameraPos: Float3(0, 90, 0)
    )
    
    var body: some Scene {
        WindowGroup {
            MacOSGameView()
                .environmentObject(renderer)
        }
    }
}
