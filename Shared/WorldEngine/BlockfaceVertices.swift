import Metal

func createVertices(pos: BlockPos, dir: Direction, block: Block) -> [Vertex] {
    let texture = getTextureType(block: block, direction: dir)
    
    let X = Float(pos.X)
    let Y = Float(pos.Y)
    let Z = Float(pos.Z)
    
    switch dir {
        case .DOWN:
            return [
                Vertex(position: Float3(X,     Y,     Z    ), textureCoords: Float2(0, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y,     Z + 1), textureCoords: Float2(1, 1), texture: texture)
            ]
        case .UP:
            return [
                Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(0, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 1), texture: texture),
                Vertex(position: Float3(X,     Y + 1, Z + 1), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(0, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z    ), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 1), texture: texture)
            ]
        case .WEST:
            return [
                Vertex(position: Float3(X,     Y,     Z    ), textureCoords: Float2(1, 1), texture: texture),
                Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X,     Y + 1, Z + 1), textureCoords: Float2(0, 0), texture: texture),
                Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), texture: texture)
            ]
        case .EAST:
            return [
                Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y,     Z + 1), textureCoords: Float2(1, 1), texture: texture),
                Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z    ), textureCoords: Float2(0, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 0), texture: texture)
            ]
        case .NORTH:
            return [
                Vertex(position: Float3(X,     Y,     Z    ), textureCoords: Float2(1, 1), texture: texture),
                Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X,     Y + 1, Z    ), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z    ), textureCoords: Float2(0, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y,     Z    ), textureCoords: Float2(0, 1), texture: texture)
            ]
        case .SOUTH:
            return [
                Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y,     Z + 1), textureCoords: Float2(1, 1), texture: texture),
                Vertex(position: Float3(X,     Y,     Z + 1), textureCoords: Float2(0, 1), texture: texture),
                Vertex(position: Float3(X,     Y + 1, Z + 1), textureCoords: Float2(0, 0), texture: texture),
                Vertex(position: Float3(X + 1, Y + 1, Z + 1), textureCoords: Float2(1, 0), texture: texture)
            ]
    }
}
