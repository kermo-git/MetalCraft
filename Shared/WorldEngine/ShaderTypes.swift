import simd
import Metal

struct Quad {
    let blockPosXZ: Int2
    let blockPosY: UInt8
    let quadPos: UInt16
    let quadSize_quadOrientation_texRotation: UInt16
    let textureID: UInt16
}

func createVertexDescriptor() -> MTLVertexDescriptor {
    let descriptor = MTLVertexDescriptor()
    var offset = 0
    
    // blockPosXZ
    descriptor.attributes[0].format = .int2
    descriptor.attributes[0].bufferIndex = 0
    descriptor.attributes[0].offset = offset
    
    offset += MemoryLayout<Int2>.stride
    
    // blockPosY
    descriptor.attributes[1].format = .uchar
    descriptor.attributes[1].bufferIndex = 0
    descriptor.attributes[1].offset = offset
    
    offset += MemoryLayout<UInt8>.stride
    
    // quadPos
    descriptor.attributes[2].format = .ushort
    descriptor.attributes[2].bufferIndex = 0
    descriptor.attributes[2].offset = offset
    
    offset += MemoryLayout<UInt16>.stride
    
    // quadSize_quadOrientation_texRotation
    descriptor.attributes[3].format = .ushort
    descriptor.attributes[3].bufferIndex = 0
    descriptor.attributes[3].offset = offset
    
    offset += MemoryLayout<UInt16>.stride
    
    // textureID
    descriptor.attributes[4].format = .ushort
    descriptor.attributes[4].bufferIndex = 0
    descriptor.attributes[4].offset = offset
    
    descriptor.layouts[0].stride = MemoryLayout<Quad>.stride
    return descriptor
}

struct VertexConstants {
    var cameraOrigin: Int3
    var projectionViewMatrix = matrix_identity_float4x4
}

struct FragmentConstants {
    var cameraPos: Float3
    var sunDirection: Half3
    var fogDistanceSquared: Float
    var fogColor: Half4
    var sunColor: Half4
}
