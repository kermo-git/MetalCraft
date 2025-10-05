import SwiftUI

@main
struct MetalCraftApp: App {
    @StateObject var scene = WorldScene(
        generator: ExampleWorld(),
        cameraPos: Float3(0, 90, 0)
    )
    
    var body: some Scene {
        WindowGroup {
            iOSGameView()
                .environmentObject(scene)
        }
    }
}
