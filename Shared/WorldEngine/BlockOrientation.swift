
enum BlockOrientation {
    case NONE, Y90, YNEG90, Y180
    case X90, X90_Y90, X90_YNEG90, X90_Y180
}

func orientVector(_ vec: Float3, _ orientation: BlockOrientation) -> Float3 {
    switch orientation {
    case .NONE:       vec
    case .Y90:        Float3( vec.z,  vec.y, -vec.x)
    case .YNEG90:     Float3(-vec.z,  vec.y,  vec.x)
    case .Y180:       Float3(-vec.x,  vec.y, -vec.z)
    case .X90:        Float3( vec.x, -vec.z,  vec.y)
    case .X90_Y90:    Float3( vec.y, -vec.z, -vec.x)
    case .X90_YNEG90: Float3(-vec.y, -vec.z,  vec.x)
    case .X90_Y180:   Float3(-vec.x, -vec.z, -vec.y)
    }
}

func reverseOrientDirections(_ orientation: BlockOrientation, _ directions: Set<Direction>) -> Set<Direction> {
    switch orientation {
    case .NONE:
        directions
    case .Y90:
        Set(directions.map {
            switch $0 {
            case .WEST: .NORTH
            case .EAST: .SOUTH
            case .SOUTH: .WEST
            case .NORTH: .EAST
            default: $0
            }
        })
    case .YNEG90:
        Set(directions.map {
            switch $0 {
            case .WEST: .SOUTH
            case .EAST: .NORTH
            case .SOUTH: .EAST
            case .NORTH: .WEST
            default: $0
            }
        })
    case .Y180:
        Set(directions.map {
            switch $0 {
            case .WEST: .EAST
            case .EAST: .WEST
            case .SOUTH: .NORTH
            case .NORTH: .SOUTH
            default: $0
            }
        })
    case .X90:
        Set(directions.map {
            switch $0 {
            case .UP: .NORTH
            case .DOWN: .SOUTH
            case .SOUTH: .UP
            case .NORTH: .DOWN
            default: $0
            }
        })
    case .X90_Y90:
        Set(directions.map {
            switch $0 {
            case .UP: .NORTH
            case .DOWN: .SOUTH
            case .WEST: .DOWN
            case .EAST: .UP
            case .SOUTH: .WEST
            case .NORTH: .EAST
            }
        })
    case .X90_YNEG90:
        Set(directions.map {
            switch $0 {
            case .UP: .NORTH
            case .DOWN: .SOUTH
            case .WEST: .UP
            case .EAST: .DOWN
            case .SOUTH: .EAST
            case .NORTH: .WEST
            }
        })
    case .X90_Y180:
        Set(directions.map {
            switch $0 {
            case .UP: .NORTH
            case .DOWN: .SOUTH
            case .WEST: .EAST
            case .EAST: .WEST
            case .SOUTH: .DOWN
            case .NORTH: .UP
            }
        })
    }
}
