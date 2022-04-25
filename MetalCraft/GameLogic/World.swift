
class World {
    static func getFaces() -> [BlockFace] {
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
        
        var faces: [BlockFace] = []
        
        for X in 0..<blocksX {
            for Y in 0..<blocksY {
                for Z in 0..<blocksZ {
                    if (chunk[X][Y][Z]) {
                        let txt: TextureType = [.LIME_BRICKS, .ORANGE_BRICKS].randomElement()!
                        
                        if (Y == 0 || !chunk[X][Y - 1][Z]) {
                            faces.append(BlockFace(direction: .DOWN, textureType: txt, X: X, Y: Y, Z: Z))
                        }
                        if (Y == blocksY - 1 || !chunk[X][Y + 1][Z]) {
                            faces.append(BlockFace(direction: .UP, textureType: txt, X: X, Y: Y, Z: Z))
                        }
                        if (X == 0 || !chunk[X - 1][Y][Z]) {
                            faces.append(BlockFace(direction: .LEFT, textureType: txt, X: X, Y: Y, Z: Z))
                        }
                        if (X == blocksX - 1 || !chunk[X + 1][Y][Z]) {
                            faces.append(BlockFace(direction: .RIGHT, textureType: txt, X: X, Y: Y, Z: Z))
                        }
                        if (Z == 0 || !chunk[X][Y][Z - 1]) {
                            faces.append(BlockFace(direction: .FAR, textureType: txt, X: X, Y: Y, Z: Z))
                        }
                        if (Z == blocksZ - 1 || !chunk[X][Y][Z + 1]) {
                            faces.append(BlockFace(direction: .NEAR, textureType: txt, X: X, Y: Y, Z: Z))
                        }
                    }
                }
            }
        }
        
        return faces
    }
}
