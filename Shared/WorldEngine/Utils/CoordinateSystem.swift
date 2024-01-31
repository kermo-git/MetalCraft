import Darwin

/* * * * * * * * * * * * * * * * * *
 * BLOCK & POINT COORDINATE SYSTEM *
 * * * * * * * * * * * * * * * * * *
 *
 * TOP DOWN VIEW                                   SIDE VIEW
 *
 *           - - - - - -                           - - - - - -
 *           | North   |                           | Top     |
 *           |         |                           |         |
 *           |         |                           |         |
 *           |         |                           |         |
 * - - - - - NW- - - - NE- - - - -       - - - - - A - - - - B - - - - -
 * | West    | Center  | East    |       | North   | Center  | South   |
 * |         |         |         |       |         |         |         |
 * |         |         |         |       |         |         |         |
 * |         |         |         |       |         |         |         |
 * - - - - - SW- - - - SE- - - - -       - - - - - NW- - - - SW- - - - -
 *           | South   |                           | Bottom  |
 *           |         |                           |         |
 *           |         |                           |         |
 *           |         |                           |         |
 *           - - - - - -                           - - - - - -
 *
 *  Block coordinates                Point coordinates
 *
 *  Center: (X,     Y,     Z    )    NW: (X,     Y,     Z    )
 *   North: (X,     Y,     Z - 1)    NE: (X + 1, Y,     Z    )
 *   South: (X,     Y,     Z + 1)    SW: (X,     Y,     Z + 1)
 *    West: (X - 1, Y,     Z    )    SE: (X + 1, Y,     Z + 1)
 *    East: (X + 1, Y,     Z    )     A: (X,     Y + 1, Z    )
 *  Bottom: (X,     Y - 1, Z    )     B: (X,     Y + 1, Z + 1)
 *     Top: (X,     Y + 1, Z    )
 *
 * * * * * * * * * * * * * *
 * CHUNK COORDINATE SYSTEM *
 * * * * * * * * * * * * * *
 *
 * TOP DOWN VIEW
 *
 *           - - - - - -
 *           | North   |
 *           |         |
 *           |         |
 *           |         |
 * - - - - - - - - - - - - - - - -
 * | West    | Center  | East    |
 * |         |         |         |
 * |         |         |         |
 * |         |         |         |
 * - - - - - - - - - - - - - - - -
 *           | South   |
 *           |         |
 *           |         |
 *           |         |
 *           - - - - - -
 *
 * Chunk coordinates
 *
 * Center: (X,     Z    )
 * North:  (X,     Z - 1)
 * South:  (X,     Z + 1)
 * West:   (X - 1, Z    )
 * East:   (X + 1, Z    )
 *
 * DETAILED VIEW OF A SINGLE CHUNK
 *
 *   NW # # # # # # # # # # # # # # NE
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *    # # # # # # # # # # # # # # # #
 *   SW # # # # # # # # # # # # # # SE
 *
 * Corner block local coordinates (Y is omitted)
 *
 * NW: (0,  0 )
 * NE: (15, 0 )
 * SW: (0,  15)
 * SE: (15, 15)
 *
 * Block with global position of (0, 0) is NW corner of Chunk (0, 0)
 */

enum Direction: Hashable {
    case UP
    case DOWN
    case WEST
    case EAST
    case SOUTH
    case NORTH
}

struct BlockPos: Hashable {
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

func getBlockPos(_ pointPos: Float3) -> BlockPos {
    return BlockPos(X: Int(floor(pointPos.x)),
                    Y: Int(floor(pointPos.y)),
                    Z: Int(floor(pointPos.z)))
}

func getChunkPos(_ pos: BlockPos) -> ChunkPos {
    func toChunkCoordinate(_ blockCoordinate: Int) -> Int {
        return (blockCoordinate >= 0) ?
            blockCoordinate / CHUNK_SIDE :
            ((blockCoordinate + 1) / CHUNK_SIDE) - 1
    }
    return ChunkPos(X: toChunkCoordinate(pos.X),
                    Z: toChunkCoordinate(pos.Z))
}

func getChunkPos(_ pointPos: Float3) -> ChunkPos {
    return getChunkPos(getBlockPos(pointPos))
}

func getGlobalPos(chunk: ChunkPos, local: BlockPos) -> BlockPos {
    return BlockPos(X: chunk.X * CHUNK_SIDE + local.X,
                    Y: local.Y,
                    Z: chunk.Z * CHUNK_SIDE + local.Z)
}

func distance(_ chunk1: ChunkPos, _ chunk2: ChunkPos) -> Float {
    let fX = Float(chunk1.X - chunk2.X)
    let fZ = Float(chunk1.Z - chunk2.Z)
    return sqrt(fX * fX + fZ * fZ)
}
