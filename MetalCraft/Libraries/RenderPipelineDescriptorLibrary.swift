import Metal

enum RenderPipelineDescriptorType {
    case Basic
}

class RenderPipelineDescriptorLibrary {
    private static var descriptors: [RenderPipelineDescriptorType: RenderPipelineDescriptor] = [:]
    
    static func Initialize() {
        descriptors.updateValue(BasicRenderPipelineDescriptor(), forKey: .Basic)
    }
    
    static func get(_ type: RenderPipelineDescriptorType) -> MTLRenderPipelineDescriptor {
        return descriptors[type]!.descriptor
    }
}

protocol RenderPipelineDescriptor {
    var name: String {get}
    var descriptor: MTLRenderPipelineDescriptor {get}
}

class BasicRenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Basic Render Pipeline Descriptor"
    
    var descriptor: MTLRenderPipelineDescriptor {
        let result = MTLRenderPipelineDescriptor()
        
        result.colorAttachments[0].pixelFormat = Preferences.PixelFormat
        result.vertexFunction = ShaderLibrary.Vertex(.Basic)
        result.fragmentFunction = ShaderLibrary.Fragment(.Basic)
        result.vertexDescriptor = VertexDescriptorLibrary.Descriptor(.Basic)
        
        return result
    }
}
