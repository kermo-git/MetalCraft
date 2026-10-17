import simd
import Metal

struct Vertex: Sizeable {
    let position: Float3
    let normal: Half3
    let textureCoords: Half2
    let textureID: UInt16
}

func createVertexDescriptor() -> MTLVertexDescriptor {
    let descriptor = MTLVertexDescriptor()
    var offset = 0
    
    descriptor.attributes[0].format = .float3
    descriptor.attributes[0].bufferIndex = 0
    descriptor.attributes[0].offset = offset
    
    offset += Float3.memorySize()
    
    descriptor.attributes[1].format = .half3
    descriptor.attributes[1].bufferIndex = 0
    descriptor.attributes[1].offset = offset
    
    offset += MemoryLayout<Half3>.stride
    
    descriptor.attributes[2].format = .half2
    descriptor.attributes[2].bufferIndex = 0
    descriptor.attributes[2].offset = offset
    
    offset += MemoryLayout<Half2>.stride
    
    descriptor.attributes[3].format = .ushort2
    descriptor.attributes[3].bufferIndex = 0
    descriptor.attributes[3].offset = offset
    
    descriptor.layouts[0].stride = Vertex.memorySize()
    return descriptor
}

struct VertexConstants: Sizeable {
    var projectionViewMatrix = matrix_identity_float4x4
}

struct FragmentConstants: Sizeable {
    var cameraPos: Float3
    var sunDirection: Half3
    var fogDistanceSquared: Float
    var fogColor: Half4
    var sunColor: Half4
}
