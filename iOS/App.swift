import SwiftUI

let camera = FlyingCamera(startPos: Float3(0, 60, 0))
let renderer = WorldRenderer(generator: generateChunk, camera: camera)
let DRAG_SENSITIVITY: Float = 0.05

@main
struct MetalCraftApp: App {
    var body: some Scene {
        WindowGroup {
            MetalView(renderer: renderer).gesture(
                DragGesture()
                    .onChanged { value in
                        let width = Float(value.translation.width)
                        let height = Float(value.translation.height)
                        Mouse.move(width * DRAG_SENSITIVITY, height * DRAG_SENSITIVITY)
                    }
            )
        }
    }
}
