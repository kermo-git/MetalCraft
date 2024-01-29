import SwiftUI

@main
struct MetalCraftApp: App {
    @StateObject var renderer = WorldRenderer(
        generator: generateChunk,
        camera: Camera(startPos: Float3(0, 0, 0))
    )
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(renderer)
        }
    }
}
