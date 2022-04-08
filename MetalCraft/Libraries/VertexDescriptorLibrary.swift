import Metal

enum VertexDescriptorType {
    case Basic
}

class VertexDescriptorLibrary {
    static var descriptors: [VertexDescriptorType: VertexDescriptor] = [:]
    
    static func Initialize() {
        descriptors.updateValue(BasicVertexDescriptor(), forKey: .Basic)
    }
    
    static func Descriptor(_ type: VertexDescriptorType) -> MTLVertexDescriptor {
        return descriptors[type]!.descriptor
    }
}

protocol VertexDescriptor {
    var name: String {get}
    var descriptor: MTLVertexDescriptor! {get}
}

class BasicVertexDescriptor: VertexDescriptor {
    var name: String = "Basic Vertex Descriptor"
    var descriptor: MTLVertexDescriptor!
    
    init() {
        descriptor = MTLVertexDescriptor()
        
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = 0
        
        descriptor.attributes[1].format = .float4
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = Float3.size()
        
        descriptor.layouts[0].stride = Vertex.size()
    }
}
