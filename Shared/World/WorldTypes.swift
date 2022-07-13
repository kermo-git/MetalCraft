
enum Direction: Hashable {
    case UP
    case DOWN
    case WEST
    case EAST
    case SOUTH
    case NORTH
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
