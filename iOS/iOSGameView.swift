import SwiftUI

let DRAG_SENSITIVITY: Float = 0.01

struct iOSGameView: View {
    @EnvironmentObject var renderer: WorldRenderer
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
                                renderer.input.moveForward = true
                            },
                            onTouchEnd: {
                                renderer.input.moveForward = false
                            })
                        EmptyGridCell()
                    }
                    GridRow {
                        GameButton(
                            systemName: "arrowshape.left.fill",
                            onTouchStart: {
                                renderer.input.moveLeft = true
                            },
                            onTouchEnd: {
                                renderer.input.moveLeft = false
                            })
                        
                        EmptyGridCell()
                        
                        GameButton(
                            systemName: "arrowshape.right.fill",
                            onTouchStart: {
                                renderer.input.moveRight = true
                            },
                            onTouchEnd: {
                                renderer.input.moveRight = false
                            })
                    }
                    GridRow {
                        EmptyGridCell()
                        GameButton(
                            systemName: "arrowshape.down.fill",
                            onTouchStart: {
                                renderer.input.moveBackward = true
                            },
                            onTouchEnd: {
                                renderer.input.moveBackward = false
                            })
                        EmptyGridCell()
                    }
                }
                Spacer()
                VStack {
                    GameButton(
                        systemName: "square.and.arrow.up",
                        onTouchStart: {
                            renderer.input.moveUp = true
                        },
                        onTouchEnd: {
                            renderer.input.moveUp = false
                        })
                    GameButton(
                        systemName: "square.and.arrow.down",
                        onTouchStart: {
                            renderer.input.moveDown = true
                        },
                        onTouchEnd: {
                            renderer.input.moveDown = false
                        })
                }
            }
        }
        
        ZStack {
            MetalView(renderer: renderer)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let width = Float(value.translation.width)
                            let height = Float(value.translation.height)
                            renderer.input.setRotationInput(
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
