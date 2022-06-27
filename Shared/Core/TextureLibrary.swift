import Metal

class TextureLibrary {
    static let count: Int = TextureType.allCases.count
    private static let textures: [MTLTexture] = TextureType.allCases.map(loadTexture)
    
    static func getTextureID(_ type: TextureType) -> Int {
        return TextureType.allCases.firstIndex(of: type)!
    }
    
    static func getRandomTexture() -> TextureType {
        return TextureType.allCases.randomElement()!
    }
    
    static func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setFragmentSamplerState(Engine.SamplerState, index: 0)
        encoder.setFragmentTextures(textures, range: 0..<textures.count)
    }
    
    private static func loadTexture(type: TextureType) -> MTLTexture {
        switch type {
            case .GRASS:
                return Engine.loadTexture(fileName: "grass")
            case .WHITE_FLOWERS:
                return Engine.loadTexture(fileName: "white_flowers")
            case .DIRT_GRASS:
                return Engine.loadTexture(fileName: "dirt_grass")
            case .DIRT:
                return Engine.loadTexture(fileName: "dirt")
        }
    }
}

