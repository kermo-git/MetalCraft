import Metal

class Engine {
    static let Device: MTLDevice = MTLCreateSystemDefaultDevice()!
    static let CommandQueue: MTLCommandQueue = Device.makeCommandQueue()!
    static let DefaultLibrary: MTLLibrary = Device.makeDefaultLibrary()!
    static var DepthPencilState: MTLDepthStencilState!
    static var RenderPipelineState: MTLRenderPipelineState!
    
    static func Ignite() {
        DepthPencilState = getDepthStencilState()

        let renderPipelineDescriptor = getRenderPipelineDescriptor(
            vertexFunction: getShaderFunction(name: "basic_vertex_shader"),
            fragmentFunction: getShaderFunction(name: "basic_fragment_shader"),
            vDescriptor: getVertexDescriptor()
        )
        RenderPipelineState = getRenderPipelineState(descriptor: renderPipelineDescriptor)
        
        GameLogic.setScene(Preferences.InitialScene)
    }

    static func getDepthStencilState() -> MTLDepthStencilState {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = true
        descriptor.depthCompareFunction = .less
        return Device.makeDepthStencilState(descriptor: descriptor)!
    }
    
    static func getShaderFunction(name: String) -> MTLFunction {
        return DefaultLibrary.makeFunction(name: name)!
    }

    static func getVertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = 0
        
        descriptor.attributes[1].format = .float4
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = Float3.size()
        
        descriptor.layouts[0].stride = Vertex.size()
        
        return descriptor
    }
    
    static func getRenderPipelineDescriptor(
        vertexFunction: MTLFunction,
        fragmentFunction: MTLFunction,
        vDescriptor: MTLVertexDescriptor) -> MTLRenderPipelineDescriptor {
            
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.PixelFormat
        descriptor.depthAttachmentPixelFormat = Preferences.DepthPixelFormat
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.vertexDescriptor = vDescriptor
            
        return descriptor
    }

    static func getRenderPipelineState(descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
        do {
            return try Device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
