import simd
import Metal

struct Vertex: Sizeable {
    let position: Float3
    let textureCoords: Float2
    let textureID: Int
}

func createVertexDescriptor() -> MTLVertexDescriptor {
    let descriptor = MTLVertexDescriptor()
    
    descriptor.attributes[0].format = .float3
    descriptor.attributes[0].bufferIndex = 0
    descriptor.attributes[0].offset = 0
    
    descriptor.attributes[1].format = .float2
    descriptor.attributes[1].bufferIndex = 0
    descriptor.attributes[1].offset = Float3.memorySize()
    
    descriptor.attributes[2].format = .int
    descriptor.attributes[2].bufferIndex = 0
    descriptor.attributes[2].offset = Float3.memorySize() + Float2.memorySize()
    
    descriptor.layouts[0].stride = Vertex.memorySize()
    return descriptor
}

struct VertexConstants: Sizeable {
    var projectionViewMatrix = matrix_identity_float4x4
}

struct FragmentConstants: Sizeable {
    var cameraPos = Float3(0, 0, 0)
    var renderDistance: Float = RENDER_DISTANCE_BLOCKS
    var fogColor: Float4 = BACKGROUND_COLOR
}
