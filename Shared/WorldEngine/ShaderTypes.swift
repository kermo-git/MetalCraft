import simd
import Metal

struct BlockFace: Sizeable {
    let positionXZ: Int2
    let positionY: UInt8
    let orientation: UInt8
    let textureID: UInt16
}

func createVertexDescriptor() -> MTLVertexDescriptor {
    let descriptor = MTLVertexDescriptor()
    var offset = 0
    
    descriptor.attributes[0].format = .int2
    descriptor.attributes[0].bufferIndex = 0
    descriptor.attributes[0].offset = offset
    
    offset += MemoryLayout<Int2>.stride
    
    descriptor.attributes[1].format = .char
    descriptor.attributes[1].bufferIndex = 0
    descriptor.attributes[1].offset = offset
    
    offset += MemoryLayout<UInt8>.stride
    
    descriptor.attributes[2].format = .char
    descriptor.attributes[2].bufferIndex = 0
    descriptor.attributes[2].offset = offset
    
    offset += MemoryLayout<UInt8>.stride
    
    descriptor.attributes[3].format = .ushort2
    descriptor.attributes[3].bufferIndex = 0
    descriptor.attributes[3].offset = offset
    
    descriptor.layouts[0].stride = BlockFace.memorySize()
    return descriptor
}

struct VertexConstants: Sizeable {
    var cameraOrigin: Int3
    var projectionViewMatrix = matrix_identity_float4x4
}

struct FragmentConstants: Sizeable {
    var cameraPos: Float3
    var sunDirection: Half3
    var fogDistanceSquared: Float
    var fogColor: Half4
    var sunColor: Half4
}
