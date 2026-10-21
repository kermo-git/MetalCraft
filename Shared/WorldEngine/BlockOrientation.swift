
enum BlockOrientation: UInt8 {
    case NONE = 0, Y90, YNEG90, Y180
    case X90, X90_Y90, X90_YNEG90, X90_Y180
}

func reverseOrientDirection(_ orientation: BlockOrientation, _ direction: Direction) -> Direction {
    switch orientation {
    case .NONE:
        direction
    case .Y90:
        switch direction {
        case .WEST: .NORTH
        case .EAST: .SOUTH
        case .SOUTH: .WEST
        case .NORTH: .EAST
        default: direction
        }
    case .YNEG90:
        switch direction {
        case .WEST: .SOUTH
        case .EAST: .NORTH
        case .SOUTH: .EAST
        case .NORTH: .WEST
        default: direction
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
        default: direction
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
    }
}
