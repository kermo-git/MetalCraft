
struct BlockFace {
    var direction: Direction
    var textureType: TextureType
    var X: Int
    var Y: Int
    var Z: Int
}

enum TextureType: CaseIterable {
    case ORANGE_BRICKS
    case LIME_BRICKS
}

enum Direction {
    case UP
    case DOWN
    case LEFT
    case RIGHT
    case NEAR
    case FAR
}

