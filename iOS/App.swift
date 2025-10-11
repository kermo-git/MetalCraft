import SwiftUI

@main
struct MetalCraftApp: App {
    @StateObject var scene = WorldRenderer(
        generator: GameWorld(),
        cameraPos: Float3(0, 90, 0)
    )
    
    var body: some Scene {
        WindowGroup {
            iOSGameView()
                .environmentObject(scene)
        }
    }
}
