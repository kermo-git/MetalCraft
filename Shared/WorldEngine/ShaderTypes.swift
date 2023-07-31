import simd
import Metal

struct Vertex: Sizeable {
    let position: Float3
    let textureCoords: Float2
    private let textureID: Int
    
    init(position: Float3, textureCoords: Float2, texture: TextureType) {
        self.position = position
        self.textureCoords = textureCoords
        textureID = getTextureID(texture)
    }
}

func getVertexDescriptor() -> MTLVertexDescriptor {
    let descriptor = MTLVertexDescriptor()
    
    descriptor.attributes[0].format = .float3
    descriptor.attributes[0].bufferIndex = 0
    descriptor.attributes[0].offset = 0
    
    descriptor.attributes[1].format = .float2
    descriptor.attributes[1].bufferIndex = 0
    descriptor.attributes[1].offset = Float3.size()
    
    descriptor.attributes[2].format = .int
    descriptor.attributes[2].bufferIndex = 0
    descriptor.attributes[2].offset = Float3.size() + Float2.size()
    
    descriptor.layouts[0].stride = Vertex.size()
    
    return descriptor
}

struct SceneConstants: Sizeable {
    var projectionViewMatrix: Float4x4 = matrix_identity_float4x4
}

struct FragmentConstants: Sizeable {
    var cameraPos: Float3 = Float3(0, 0, 0)
    var renderDistance: Float = RENDER_DISTANCE_BLOCKS
    var fogColor: Float4 = BACKGROUND_COLOR
}
