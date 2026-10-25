/*
 *    ___   NORTH
 *    | Y90   |
 *    v       |
 * WEST ------------- EAST --> x
 *            |
 *            |
 *          SOUTH
 *            |
 *            v z
 *
 *             ^ y
 *             |
 *             UP    ___
 *             |   X90 |
 *             |       v
 * NORTH ------------- SOUTH --> z
 *             |
 *             |
 *            DOWN
 */
enum BlockRotation: UInt8 {
    case NONE = 0,     Y90,     YNEG90,     Y180
    case      X90, X90_Y90, X90_YNEG90, X90_Y180
}

enum TextureRotation: UInt8 {
    case NONE = 0,
    case CW,
    case CCW,
    case FULL
}

func reverseOrientDirection(_ orientation: BlockRotation, _ direction: Direction) -> (Direction, TextureRotation) {
    switch orientation {
    case .NONE:
        direction
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
        case: .EAST: (.EAST, .CCW)
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
        case .DOWN: (.SOUTH, .CCW)
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
    }
}
