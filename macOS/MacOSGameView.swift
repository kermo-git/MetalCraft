import SwiftUI

let DRAG_SENSITIVITY: Float = 0.3

struct MacOSGameView: View {
    @FocusState private var focused: Bool
    
    @EnvironmentObject var renderer: WorldRenderer
    
    var body: some View {
        ZStack {
            MetalView(renderer: renderer)
                .focusable()
                .focused($focused)
                .onKeyPress(phases: .all, action: { press in
                    let isMoving = press.phase != .up
                    
                    switch press.characters {
                    case "w":
                        renderer.input.moveForward = isMoving
                    case "a":
                        renderer.input.moveLeft = isMoving
                    case "s":
                        renderer.input.moveBackward = isMoving
                    case "d":
                        renderer.input.moveRight = isMoving
                    default:
                        switch press.key {
                        case .space:
                            renderer.input.moveUp = isMoving
                        case .tab:
                            renderer.input.moveDown = isMoving
                        default:
                            break
                        }
                    }
                    return .handled
                })
                .background(MouseHandler(onMouseMove: {
                    deltaX, deltaY in
                        renderer.input.setRotationInput(
                            deltaX * DRAG_SENSITIVITY,
                            deltaY * DRAG_SENSITIVITY
                        )
                }))
            VStack {
                HStack {
                    PositionLabel()
                    Spacer()
                }
                Spacer()
            }
            .padding([.top, .leading])
        }
    }
}

#Preview {
    MacOSGameView()
        .environmentObject(
            WorldRenderer(generator: GameWorld(),
                          cameraPos: Float3(0, 90, 0))
        )
}
