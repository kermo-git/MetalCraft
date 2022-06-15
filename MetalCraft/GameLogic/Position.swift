import Darwin

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

struct ChunkPos: Hashable {
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

func distance(_ chunk1: ChunkPos, _ chunk2: ChunkPos) -> Float {
    let fX = Float(chunk1.X - chunk2.X)
    let fZ = Float(chunk1.Z - chunk2.Z)
    return sqrt(fX * fX + fZ * fZ)
}

func toGlobalPos(chunk: ChunkPos, local: BlockPos) -> BlockPos {
    return BlockPos(X: chunk.X * CHUNK_SIDE + local.X,
                    Y: local.Y,
                    Z: chunk.Z * CHUNK_SIDE + local.Z)
}

func getChunkPos(_ globalPos: Float3) -> ChunkPos {
    let x = globalPos.x / Float(CHUNK_SIDE)
    let z = globalPos.z / Float(CHUNK_SIDE)
    
    return ChunkPos(X: Int(floor(x)),
                    Z: Int(floor(z)))
}

func getChunkPos(_ globalPos: BlockPos) -> ChunkPos {
    ChunkPos(X: globalPos.X / CHUNK_SIDE,
             Z: globalPos.Z / CHUNK_SIDE)
}
