import SwiftUI

let DRAG_SENSITIVITY: Float = 0.01

struct iOSGameView: View {
    @EnvironmentObject var scene: WorldRenderer
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
                                scene.input.moveForward = true
                            },
                            onTouchEnd: {
                                scene.input.moveForward = false
                            })
                        EmptyGridCell()
                    }
                    GridRow {
                        GameButton(
                            systemName: "arrowshape.left.fill",
                            onTouchStart: {
                                scene.input.moveLeft = true
                            },
                            onTouchEnd: {
                                scene.input.moveLeft = false
                            })
                        
                        EmptyGridCell()
                        
                        GameButton(
                            systemName: "arrowshape.right.fill",
                            onTouchStart: {
                                scene.input.moveRight = true
                            },
                            onTouchEnd: {
                                scene.input.moveRight = false
                            })
                    }
                    GridRow {
                        EmptyGridCell()
                        GameButton(
                            systemName: "arrowshape.down.fill",
                            onTouchStart: {
                                scene.input.moveBackward = true
                            },
                            onTouchEnd: {
                                scene.input.moveBackward = false
                            })
                        EmptyGridCell()
                    }
                }
                Spacer()
                VStack {
                    GameButton(
                        systemName: "square.and.arrow.up",
                        onTouchStart: {
                            scene.input.moveUp = true
                        },
                        onTouchEnd: {
                            scene.input.moveUp = false
                        })
                    GameButton(
                        systemName: "square.and.arrow.down",
                        onTouchStart: {
                            scene.input.moveDown = true
                        },
                        onTouchEnd: {
                            scene.input.moveDown = false
                        })
                }
            }
        }
        
        ZStack {
            MetalView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let width = Float(value.translation.width)
                            let height = Float(value.translation.height)
                            scene.input.setRotationInput(
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
            WorldRenderer(generator: GameWorld(),
                       cameraPos: Float3(0, 90, 0))
        )
}
