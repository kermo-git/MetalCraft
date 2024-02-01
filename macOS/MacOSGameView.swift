import SwiftUI

struct MacOSGameView: View {
    @FocusState private var focused: Bool
    
    @EnvironmentObject var scene: WorldScene
    
    var body: some View {
        ZStack {
            MetalView(scene: scene)
                .focusable()
                .focused($focused)
                .onKeyPress(phases: .down, action: { press in
                    switch press.characters {
                    case "w":
                        scene.camera.moveForward = true
                    case "a":
                        scene.camera.moveLeft = true
                    case "s":
                        scene.camera.moveBackward = true
                    case "d":
                        scene.camera.moveRight = true
                    default:
                        break
                    }
                    return .handled
                })
                .onKeyPress(phases: .up, action: { press in
                    switch press.characters {
                    case "w":
                        scene.camera.moveForward = false
                    case "a":
                        scene.camera.moveLeft = false
                    case "s":
                        scene.camera.moveBackward = false
                    case "d":
                        scene.camera.moveRight = false
                    default:
                        break
                    }
                    return .handled
                })
                .onKeyPress(.space, phases: .down, action: { _ in
                    scene.camera.moveUp = true
                    return .handled
                })
                .onKeyPress(.space, phases: .up, action: { _ in
                    scene.camera.moveUp = false
                    return .handled
                })
                .onKeyPress(.tab, phases: .down, action: { _ in
                    scene.camera.moveDown = true
                    return .handled
                })
                .onKeyPress(.tab, phases: .up, action: { _ in
                    scene.camera.moveDown = false
                    return .handled
                })
                .background(MouseHandler(onMouseMove: {
                    deltaX, deltaY in
                        scene.camera.setRotationInput(deltaX, deltaY)
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
            WorldScene(generator: generateChunk,
                          cameraPos: Float3(0, 70, 0))
        )
}
