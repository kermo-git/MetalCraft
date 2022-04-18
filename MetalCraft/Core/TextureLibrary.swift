import Metal

enum TextureType: CaseIterable {
    case ORANGE_BRICKS
    case LIME_BRICKS
}

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
            case .ORANGE_BRICKS:
                return Engine.loadTexture(fileName: "orange_bricks")
            case .LIME_BRICKS:
                return Engine.loadTexture(fileName: "lime_bricks")
        }
    }
}

