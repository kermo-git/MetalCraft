import SwiftUI

let camera = FlyingCamera(startPos: Float3(0, 60, 0))
let renderer = WorldRenderer(generator: generateChunk, camera: camera)

@main
struct MetalCraftApp: App {
    var body: some Scene {
        WindowGroup {
            MetalView(renderer: renderer)
                .background(KeyboardAndMouseHandler())
        }
    }
}
