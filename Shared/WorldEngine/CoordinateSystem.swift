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

extension Int3 {
    func move(_ direction: Direction) -> Int3 {
        switch direction {
            case .UP:
                return Int3(x, y + 1, z)
            case .DOWN:
                return Int3(x, y - 1, z)
            case .WEST:
                return Int3(x - 1, y, z)
            case .EAST:
                return Int3(x + 1, y, z)
            case .SOUTH:
                return Int3(x, y, z + 1)
            case .NORTH:
                return Int3(x, y, z - 1)
        }
    }
}

extension Int2 {
    func move(_ direction: Direction) -> Int2 {
        switch direction {
            case .WEST:
                return Int2(x - 1, y)
            case .EAST:
                return Int2(x + 1, y)
            case .SOUTH:
                return Int2(x, y + 1)
            case .NORTH:
                return Int2(x, y - 1)
            default:
                return self
        }
    }
}

let CHUNK_SIDE = 16
let CHUNK_HEIGHT = 256

let CHUNK_SIDE_MASK = 15
let CHUNK_SIDE_SHIFT = 4

func getBlockPos(_ pointPos: Float3) -> Int3 {
    return Int3(x: Int(floor(pointPos.x)),
                y: Int(floor(pointPos.y)),
                z: Int(floor(pointPos.z)))
}

func getChunkPos(_ blockPos: Int3) -> Int2 {
    return Int2(x: blockPos.x >> CHUNK_SIDE_SHIFT,
                y: blockPos.z >> CHUNK_SIDE_SHIFT)
}

func getChunkPos(_ pointPos: Float3) -> Int2 {
    return Int2(x: Int(floor(pointPos.x)) >> CHUNK_SIDE_SHIFT,
                y: Int(floor(pointPos.z)) >> CHUNK_SIDE_SHIFT)
}

func getLocalBlockPos(_ globalBlockPos: Int3) -> Int3 {
    return Int3(x: globalBlockPos.x & CHUNK_SIDE_MASK,
                y: globalBlockPos.y,
                z: globalBlockPos.z & CHUNK_SIDE_MASK)
}

func getGlobalBlockPos(chunkPos: Int2, localBlockPos: Int3) -> Int3 {
    return Int3(x: chunkPos.x * CHUNK_SIDE + localBlockPos.x,
                y: localBlockPos.y,
                z: chunkPos.y * CHUNK_SIDE + localBlockPos.z)
}

func distanceSquared(_ chunk1: Int2, _ chunk2: Int2) -> Int {
    let fX = chunk1.x - chunk2.x
    let fZ = chunk1.y - chunk2.y
    return fX * fX + fZ * fZ
}
