import Metal

@MainActor
protocol MetalScene: ObservableObject {
    var engine: Engine { get }
    
    var clearColor: MTLClearColor { get }
    
    func setAspectRatio(_ aspectRatio: Float)
    
    func update(deltaTime: Float)
    
    func render(_ encoder: MTLRenderCommandEncoder)
}
