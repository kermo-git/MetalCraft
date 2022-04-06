import Metal

class Engine {
    static let Device: MTLDevice = MTLCreateSystemDefaultDevice()!
    static let CommandQueue: MTLCommandQueue = Device.makeCommandQueue()!
    
    static func Ignite() {
        ShaderLibrary.Initialize()
        VertexDescriptorLibrary.Initialize()
        RenderPipelineDescriptorLibrary.Initialize()
        RenderPipelineStateLibrary.Initialize()
        MeshLibrary.Initialize()
    }
}
