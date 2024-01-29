import SwiftUI

let DRAG_SENSITIVITY: Float = 0.05

struct GameView: View {
    @EnvironmentObject var renderer: WorldRenderer
    
    var body: some View {
        MetalView(renderer: renderer)
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let width = Float(value.translation.width)
                        let height = Float(value.translation.height)
                        renderer.camera.setRotationInput(
                            width * DRAG_SENSITIVITY,
                            height * DRAG_SENSITIVITY
                        )
                    }
            )
    }
}

#Preview(traits: .landscapeLeft) {
    GameView()
        .environmentObject(
            WorldRenderer(generator: generateChunk,
                          camera: Camera(startPos: Float3(0, 70, 0)))
        )
}
