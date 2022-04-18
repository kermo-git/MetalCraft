import Darwin

func buildSandboxScene() -> Scene {
    let blocksX = 50
    let blocksY = 10
    let blocksZ = 50
    
    var chunk: [[[Bool]]] = []
    for _ in 1...blocksX {
        var slice: [[Bool]] = []
        for _ in 1...blocksY {
            let row: [Bool] = Array(repeating: false, count: blocksZ)
            slice.append(row)
        }
        chunk.append(slice)
    }
    
    for X in 0..<blocksX {
        for Z in 0..<blocksZ {
            let height = Int.random(in: 1...blocksY)
            for y in 0..<height {
                chunk[X][y][Z] = true
            }
        }
    }
    
    var faces: [Node] = []
    
    for X in 0..<blocksX {
        for Y in 0..<blocksY {
            for Z in 0..<blocksZ {
                if (chunk[X][Y][Z]) {
                    let txt: TextureType = [.LIME_BRICKS, .ORANGE_BRICKS].randomElement()!
                    
                    if (Y == 0 || !chunk[X][Y - 1][Z]) {
                        faces.append(getBottomFace(X: X, Y: Y, Z: Z, textureType: txt))
                    }
                    if (Y == blocksY - 1 || !chunk[X][Y + 1][Z]) {
                        faces.append(getTopFace(X: X, Y: Y, Z: Z, textureType: txt))
                    }
                    if (X == 0 || !chunk[X - 1][Y][Z]) {
                        faces.append(getLeftFace(X: X, Y: Y, Z: Z, textureType: txt))
                    }
                    if (X == blocksX - 1 || !chunk[X + 1][Y][Z]) {
                        faces.append(getRightFace(X: X, Y: Y, Z: Z, textureType: txt))
                    }
                    if (Z == 0 || !chunk[X][Y][Z - 1]) {
                        faces.append(getFarFace(X: X, Y: Y, Z: Z, textureType: txt))
                    }
                    if (Z == blocksZ - 1 || !chunk[X][Y][Z + 1]) {
                        faces.append(getNearFace(X: X, Y: Y, Z: Z, textureType: txt))
                    }
                }
            }
        }
    }
    let root = Node(children: faces)
    root.position.z = -40
    root.position.x = -20
    root.position.y = -10
    root.updateMatrixes()
    let collection = InstanceCollection(mesh: buildQuad(),
                                        instances: faces)
    
    return Scene(camera: FlyingCamera(),
                 rootNode: root,
                 instanceCollections: [collection])
}
