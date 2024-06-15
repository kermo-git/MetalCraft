import SwiftUI

let DRAG_SENSITIVITY: Float = 0.3

struct MacOSGameView: View {
    @FocusState private var focused: Bool
    
    @EnvironmentObject var scene: WorldScene
    
    var body: some View {
        ZStack {
            MetalView(scene: scene)
                .focusable()
                .focused($focused)
                .onKeyPress(phases: .all, action: { press in
                    let isMoving = press.phase != .up
                    
                    switch press.characters {
                    case "w":
                        scene.camera.moveForward = isMoving
                    case "a":
                        scene.camera.moveLeft = isMoving
                    case "s":
                        scene.camera.moveBackward = isMoving
                    case "d":
                        scene.camera.moveRight = isMoving
                    default:
                        switch press.key {
                        case .space:
                            scene.camera.moveUp = isMoving
                        case .tab:
                            scene.camera.moveDown = isMoving
                        default:
                            break
                        }
                    }
                    return .handled
                })
                .background(MouseHandler(onMouseMove: {
                    deltaX, deltaY in
                        scene.camera.setRotationInput(
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
            WorldScene(generator: ExampleWorld(),
                       cameraPos: Float3(0, 70, 0))
        )
}
