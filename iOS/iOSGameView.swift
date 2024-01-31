import SwiftUI

let DRAG_SENSITIVITY: Float = 0.05

struct iOSGameView: View {
    @EnvironmentObject var scene: WorldScene
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        let uiComponents = VStack {
            HStack {
                PositionLabel()
                Spacer()
            }
            Spacer()
            HStack {
                Grid {
                    GridRow {
                        EmptyGridCell()
                        GameButton(
                            systemName: "arrowshape.up.fill",
                            onTouchStart: {
                                scene.camera.moveForward = true
                            },
                            onTouchEnd: {
                                scene.camera.moveForward = false
                            })
                        EmptyGridCell()
                    }
                    GridRow {
                        GameButton(
                            systemName: "arrowshape.left.fill",
                            onTouchStart: {
                                scene.camera.moveLeft = true
                            },
                            onTouchEnd: {
                                scene.camera.moveLeft = false
                            })
                        
                        EmptyGridCell()
                        
                        GameButton(
                            systemName: "arrowshape.right.fill",
                            onTouchStart: {
                                scene.camera.moveRight = true
                            },
                            onTouchEnd: {
                                scene.camera.moveRight = false
                            })
                    }
                    GridRow {
                        EmptyGridCell()
                        GameButton(
                            systemName: "arrowshape.down.fill",
                            onTouchStart: {
                                scene.camera.moveBackward = true
                            },
                            onTouchEnd: {
                                scene.camera.moveBackward = false
                            })
                        EmptyGridCell()
                    }
                }
                Spacer()
                VStack {
                    GameButton(
                        systemName: "square.and.arrow.up",
                        onTouchStart: {
                            scene.camera.moveUp = true
                        },
                        onTouchEnd: {
                            scene.camera.moveUp = false
                        })
                    GameButton(
                        systemName: "square.and.arrow.down",
                        onTouchStart: {
                            scene.camera.moveDown = true
                        },
                        onTouchEnd: {
                            scene.camera.moveDown = false
                        })
                }
            }
        }
        
        ZStack {
            MetalView(renderer: scene)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let width = Float(value.translation.width)
                            let height = Float(value.translation.height)
                            scene.camera.setRotationInput(
                                width * DRAG_SENSITIVITY,
                                height * DRAG_SENSITIVITY
                            )
                        }
                )
            
            if horizontalSizeClass == .compact {
                uiComponents.padding([.top])
            } else {
                uiComponents.padding([.leading, .trailing])
            }
        }
    }
}

struct EmptyGridCell: View {
    var body: some View {
        Spacer().gridCellUnsizedAxes([.horizontal, .vertical])
    }
}

#Preview(traits: .landscapeRight) {
    iOSGameView()
        .environmentObject(
            WorldScene(generator: generateChunk,
                          cameraPos: Float3(0, 70, 0))
        )
}
