import SwiftUI

@main
struct MetalCraftApp: App {
    @StateObject var scene = WorldScene(
        generator: generateChunk,
        cameraPos: Float3(0, 70, 0)
    )
    
    var body: some Scene {
        WindowGroup {
            iOSGameView()
                .environmentObject(scene)
        }
    }
}
