
struct BlockPos {
    let X: Int
    let Y: Int
    let Z: Int
    
    func move(_ direction: Direction) -> BlockPos {
        switch direction {
            case .UP:
                return BlockPos(X: X, Y: Y + 1, Z: Z)
            case .DOWN:
                return BlockPos(X: X, Y: Y - 1, Z: Z)
            case .WEST:
                return BlockPos(X: X - 1, Y: Y, Z: Z)
            case .EAST:
                return BlockPos(X: X + 1, Y: Y, Z: Z)
            case .SOUTH:
                return BlockPos(X: X, Y: Y, Z: Z + 1)
            case .NORTH:
                return BlockPos(X: X, Y: Y, Z: Z - 1)
        }
    }
}

struct ChunkPos {
    let X: Int
    let Z: Int
    
    func move(_ direction: Direction) -> ChunkPos {
        switch direction {
            case .WEST:
                return ChunkPos(X: X - 1, Z: Z)
            case .EAST:
                return ChunkPos(X: X + 1, Z: Z)
            case .SOUTH:
                return ChunkPos(X: X, Z: Z + 1)
            case .NORTH:
                return ChunkPos(X: X, Z: Z - 1)
            default:
                return self
        }
    }
}

func toGlobalPos(chunk: ChunkPos, local: BlockPos) -> BlockPos {
    return BlockPos(X: chunk.X * CHUNK_SIDE + local.X,
                    Y: local.Y,
                    Z: chunk.Z * CHUNK_SIDE + local.Z)
}
