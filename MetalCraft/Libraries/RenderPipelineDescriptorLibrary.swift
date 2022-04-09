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
    var descriptor: MTLRenderPipelineDescriptor! {get}
}

class BasicRenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Basic Render Pipeline Descriptor"
    var descriptor: MTLRenderPipelineDescriptor!
    
    init() {
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.PixelFormat
        descriptor.depthAttachmentPixelFormat = Preferences.DepthPixelFormat
        descriptor.vertexFunction = ShaderLibrary.Vertex(.Basic)
        descriptor.fragmentFunction = ShaderLibrary.Fragment(.Basic)
        descriptor.vertexDescriptor = VertexDescriptorLibrary.Descriptor(.Basic)
    }
}
