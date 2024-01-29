import SwiftUI

struct GameView: View {
    @FocusState private var focused: Bool
    
    @EnvironmentObject var renderer: WorldRenderer
    
    var body: some View {
        MetalView(renderer: renderer)
            .focusable()
            .focused($focused)
            .onKeyPress(phases: .down, action: { press in
                switch press.characters {
                case "w":
                    renderer.camera.moveForward = true
                case "a":
                    renderer.camera.moveLeft = true
                case "s":
                    renderer.camera.moveBackward = true
                case "d":
                    renderer.camera.moveRight = true
                default:
                    break
                }
                return .handled
            })
            .onKeyPress(phases: .up, action: { press in
                switch press.characters {
                case "w":
                    renderer.camera.moveForward = false
                case "a":
                    renderer.camera.moveLeft = false
                case "s":
                    renderer.camera.moveBackward = false
                case "d":
                    renderer.camera.moveRight = false
                default:
                    break
                }
                return .handled
            })
            .onKeyPress(.space, phases: .down, action: { _ in
                renderer.camera.moveUp = true
                return .handled
            })
            .onKeyPress(.space, phases: .up, action: { _ in
                renderer.camera.moveUp = false
                return .handled
            })
            .onKeyPress(.tab, phases: .down, action: { _ in
                renderer.camera.moveDown = true
                return .handled
            })
            .onKeyPress(.tab, phases: .up, action: { _ in
                renderer.camera.moveDown = false
                return .handled
            })
            .background(MouseHandler(onMouseMove: {
                deltaX, deltaY in
                    renderer.camera.setRotationInput(deltaX, deltaY)
            }))
    }
}

#Preview {
    GameView()
        .environmentObject(
            WorldRenderer(generator: generateChunk,
                          camera: Camera(startPos: Float3(0, 70, 0)))
        )
}
