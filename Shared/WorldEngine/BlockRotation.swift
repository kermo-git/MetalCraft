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

enum TextureRotation: UInt8 {
    case NONE = 0
    case CW
    case CCW
    case FULL
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

func findRotatedFace(_ rotation: BlockRotation, _ direction: Direction) -> (Direction, TextureRotation) {
    switch rotation {
    case .NONE:
        (direction, .NONE)
    case .Y90:
        switch direction {
        case .WEST: (.NORTH, .NONE)
        case .EAST: (.SOUTH, .NONE)
        case .SOUTH: (.WEST, .NONE)
        case .NORTH: (.EAST, .NONE)
        case .UP: (.UP, .CCW)
        case .DOWN: (.DOWN, .CW)
        }
    case .YNEG90:
        switch direction {
        case .WEST: (.SOUTH, .NONE)
        case .EAST: (.NORTH, .NONE)
        case .SOUTH: (.EAST, .NONE)
        case .NORTH: (.WEST, .NONE)
        case .UP: (.UP, .CW)
        case .DOWN: (.DOWN, .CCW)
        }
    case .Y180:
        switch direction {
        case .WEST: (.EAST, .NONE)
        case .EAST: (.WEST, .NONE)
        case .SOUTH: (.NORTH, .NONE)
        case .NORTH: (.SOUTH, .NONE)
        default: (direction, .FULL)
        }
    case .X90:
        switch direction {
        case .UP: (.NORTH, .FULL)
        case .DOWN: (.SOUTH, .FULL)
        case .SOUTH: (.UP, .NONE)
        case .NORTH: (.DOWN, .NONE)
        case .WEST: (.WEST, .CW)
        case .EAST: (.EAST, .CCW)
        }
    case .X90_Y90:
        switch direction {
        case .UP: (.NORTH, .CW)
        case .DOWN: (.SOUTH, .CW)
        case .WEST: (.DOWN, .NONE)
        case .EAST: (.UP, .NONE)
        case .SOUTH: (.WEST, .CW)
        case .NORTH: (.EAST, .CCW)
        }
    case .X90_YNEG90:
        switch direction {
        case .UP: (.NORTH, .CCW)
        case .DOWN: (.SOUTH, .CW)
        case .WEST: (.UP, .NONE)
        case .EAST: (.DOWN, .NONE)
        case .SOUTH: (.EAST, .CCW)
        case .NORTH: (.WEST, .CW)
        }
    case .X90_Y180:
        switch direction {
        case .UP: (.NORTH, .NONE)
        case .DOWN: (.SOUTH, .NONE)
        case .WEST: (.EAST, .CCW)
        case .EAST: (.WEST, .CW)
        case .SOUTH: (.DOWN, .NONE)
        case .NORTH: (.UP, .NONE)
        }
    case .Z90:
        switch direction {
        case .UP: (.EAST, .CCW)
        case .DOWN: (.WEST, .CW)
        case .SOUTH: (.SOUTH, .CCW)
        case .NORTH: (.NORTH, .CW)
        case .WEST: (.UP, .CCW)
        case .EAST: (.DOWN, .CW)
        }
    case .Z90_Y90:
        switch direction {
        case .UP: (.EAST, .FULL)
        case .DOWN: (.WEST, .FULL)
        case .WEST: (.NORTH, .CW)
        case .EAST: (.SOUTH, .CCW)
        case .SOUTH: (.UP, .CCW)
        case .NORTH: (.DOWN, .CW)
        }
    case .Z90_YNEG90:
        switch direction {
        case .UP: (.EAST, .NONE)
        case .DOWN: (.WEST, .NONE)
        case .WEST: (.SOUTH, .CCW)
        case .EAST: (.NORTH, .CW)
        case .SOUTH: (.DOWN, .CW)
        case .NORTH: (.UP, .CCW)
        }
    case .Z90_Y180:
        switch direction {
        case .UP: (.EAST, .CW)
        case .DOWN: (.WEST, .CCW)
        case .WEST: (.DOWN, .CW)
        case .EAST: (.UP, .CCW)
        case .SOUTH: (.NORTH, .CW)
        case .NORTH: (.SOUTH, .CCW)
        }
    }
}
