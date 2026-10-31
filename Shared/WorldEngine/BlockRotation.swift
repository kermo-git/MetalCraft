/*
 *         UP (+y)
 *          /  \   | NORTH (-z)
 *          \-> \  |
 *          Y90  \ |
 *                \|
 * WEST (-x) ------------- /  EAST (+x)
 *                 |\      \->
 *                 | \     X90
 *                 |  \
 *      SOUTH (+z) |   \ DOWN (-y)
 *                Z90
 *                <-\
 *                  /
 */
enum BlockRotation: UInt8 {
    case NONE = 0,     Y90,     YNEG90,     Y180
    case      X90, X90_Y90, X90_YNEG90, X90_Y180
    case      Z90, Z90_Y90, Z90_YNEG90, Z90_Y180
}

func rotateVector<I: SignedInteger>(_ vec: SIMD3<I>, _ rotation: BlockRotation) -> SIMD3<I> {
    switch rotation {
    case .NONE:       vec
    case .Y90:        SIMD3<I>( vec.z,  vec.y, -vec.x)
    case .YNEG90:     SIMD3<I>(-vec.z,  vec.y,  vec.x)
    case .Y180:       SIMD3<I>(-vec.x,  vec.y, -vec.z)
    case .X90:        SIMD3<I>( vec.x, -vec.z,  vec.y)
    case .X90_Y90:    SIMD3<I>( vec.y, -vec.z, -vec.x)
    case .X90_YNEG90: SIMD3<I>(-vec.y, -vec.z,  vec.x)
    case .X90_Y180:   SIMD3<I>(-vec.x, -vec.z, -vec.y)
    case .Z90:        SIMD3<I>(-vec.y,  vec.x,  vec.z)
    case .Z90_Y90:    SIMD3<I>( vec.z,  vec.x,  vec.y)
    case .Z90_YNEG90: SIMD3<I>(-vec.z,  vec.x, -vec.y)
    case .Z90_Y180:   SIMD3<I>( vec.y,  vec.x, -vec.z)
    }
}

func reverseRotation(_ rotation: BlockRotation, _ direction: Direction) -> Direction {
    switch rotation {
    case .NONE: direction
    case .Y90:
        switch direction {
        case .WEST: .NORTH
        case .EAST: .SOUTH
        case .SOUTH: .WEST
        case .NORTH: .EAST
        case .UP: .UP
        case .DOWN: .DOWN
        }
    case .YNEG90:
        switch direction {
        case .WEST: .SOUTH
        case .EAST: .NORTH
        case .SOUTH: .EAST
        case .NORTH: .WEST
        case .UP: .UP
        case .DOWN: .DOWN
        }
    case .Y180:
        switch direction {
        case .WEST: .EAST
        case .EAST: .WEST
        case .SOUTH: .NORTH
        case .NORTH: .SOUTH
        default: direction
        }
    case .X90:
        switch direction {
        case .UP: .NORTH
        case .DOWN: .SOUTH
        case .SOUTH: .UP
        case .NORTH: .DOWN
        case .WEST: .WEST
        case .EAST: .EAST
        }
    case .X90_Y90:
        switch direction {
        case .UP: .NORTH
        case .DOWN: .SOUTH
        case .WEST: .DOWN
        case .EAST: .UP
        case .SOUTH: .WEST
        case .NORTH: .EAST
        }
    case .X90_YNEG90:
        switch direction {
        case .UP: .NORTH
        case .DOWN: .SOUTH
        case .WEST: .UP
        case .EAST: .DOWN
        case .SOUTH: .EAST
        case .NORTH: .WEST
        }
    case .X90_Y180:
        switch direction {
        case .UP: .NORTH
        case .DOWN: .SOUTH
        case .WEST: .EAST
        case .EAST: .WEST
        case .SOUTH: .DOWN
        case .NORTH: .UP
        }
    case .Z90:
        switch direction {
        case .UP: .EAST
        case .DOWN: .WEST
        case .SOUTH: .SOUTH
        case .NORTH: .NORTH
        case .WEST: .UP
        case .EAST: .DOWN
        }
    case .Z90_Y90:
        switch direction {
        case .UP: .EAST
        case .DOWN: .WEST
        case .WEST: .NORTH
        case .EAST: .SOUTH
        case .SOUTH: .UP
        case .NORTH: .DOWN
        }
    case .Z90_YNEG90:
        switch direction {
        case .UP: .EAST
        case .DOWN: .WEST
        case .WEST: .SOUTH
        case .EAST: .NORTH
        case .SOUTH: .DOWN
        case .NORTH: .UP
        }
    case .Z90_Y180:
        switch direction {
        case .UP: .EAST
        case .DOWN: .WEST
        case .WEST: .DOWN
        case .EAST: .UP
        case .SOUTH: .NORTH
        case .NORTH: .SOUTH
        }
    }
}
