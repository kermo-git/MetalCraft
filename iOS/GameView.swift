import SwiftUI

let DRAG_SENSITIVITY: Float = 0.05

struct GameView: View {
    let renderer: Renderer
    
    var body: some View {
        ZStack {
            MetalView(renderer: renderer)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let width = Float(value.translation.width)
                            let height = Float(value.translation.height)
                            Input.rotateCamera(width * DRAG_SENSITIVITY, height * DRAG_SENSITIVITY)
                        }
            )
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(renderer: gameRenderer)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
