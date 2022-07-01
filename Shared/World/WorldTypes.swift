
enum Direction {
    case UP
    case DOWN
    case WEST
    case EAST
    case SOUTH
    case NORTH
}

struct BlockFace {
    var direction: Direction
    var textureType: TextureType
    var pos: BlockPos
}

enum Block: Equatable {
    case AIR
    case SOLID_BLOCK(topTexture: TextureType,
                     sideTexture: TextureType,
                     bottomTexture: TextureType)
}

enum TextureType: CaseIterable {
    case GRASS
    case WHITE_FLOWERS
    case DIRT_GRASS
    case DIRT
}