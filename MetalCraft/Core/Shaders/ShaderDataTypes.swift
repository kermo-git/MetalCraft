import simd
import Metal

struct Vertex: Sizeable {
    var position: Float3 = Float3(0, 0, 0)
    var textureCoords: Float2 = Float2(0, 0)
}

func getVertexDescriptor() -> MTLVertexDescriptor {
    let descriptor = MTLVertexDescriptor()
    
    descriptor.attributes[0].format = .float3
    descriptor.attributes[0].bufferIndex = 0
    descriptor.attributes[0].offset = 0
    
    descriptor.attributes[1].format = .float2
    descriptor.attributes[1].bufferIndex = 0
    descriptor.attributes[1].offset = Float3.size()
    
    descriptor.layouts[0].stride = Vertex.size()
    
    return descriptor
}

struct SceneConstants: Sizeable {
    var projectionViewMatrix: Float4x4 = matrix_identity_float4x4
}

struct ShaderBlockFace: Sizeable {
    var modelMatrix: Float4x4 = matrix_identity_float4x4
    var normal: Float3 = Float3(0, 0, 0)
    private var textureID: Int = 0
    
    mutating func setTexture(_ type: TextureType) {
        textureID = TextureLibrary.getTextureID(type)
    }
}

struct FragmentConstants: Sizeable {
    var sunDirection: Float3 = normalize(Float3(0.1, 0.2, 0.3))
}
