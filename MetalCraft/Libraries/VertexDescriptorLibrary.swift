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
    var descriptor: MTLVertexDescriptor {get}
}

class BasicVertexDescriptor: VertexDescriptor {
    var name: String = "Basic Vertex Descriptor"
    
    var descriptor: MTLVertexDescriptor {
        let result = MTLVertexDescriptor()
        
        result.attributes[0].format = .float3
        result.attributes[0].bufferIndex = 0
        result.attributes[0].offset = 0
        
        result.attributes[1].format = .float4
        result.attributes[1].bufferIndex = 0
        result.attributes[1].offset = Float3.size()
        
        result.layouts[0].stride = Vertex.size()
        
        return result
    }
}
