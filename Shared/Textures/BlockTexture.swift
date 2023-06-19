enum TextureType: String, CaseIterable {
    case GRASS, WHITE_FLOWERS, DIRT_GRASS, DIRT, STONE
}

func getTextureID(_ type: TextureType) -> Int {
    return TextureType.allCases.firstIndex(of: type)!
}

func getTextureType(block: Block, direction: Direction) -> TextureType {
    switch block {
    case .AIR: return .STONE
    case .STONE: return .STONE
    case .DIRT: return .DIRT
    case .GRASS:
        switch direction {
        case .UP:
            return .GRASS
        case .DOWN:
            return .DIRT
        default:
            return .DIRT_GRASS
        }
    case .WHITE_FLOWERS:
        switch direction {
        case .UP:
            return .WHITE_FLOWERS
        case .DOWN:
            return .DIRT
        default:
            return .DIRT_GRASS
        }
    }
}
