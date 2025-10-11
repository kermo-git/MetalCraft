import Metal

@MainActor
protocol Renderer: ObservableObject {
    var engine: Engine { get }
    
    var clearColor: MTLClearColor { get }
    
    func setAspectRatio(_ aspectRatio: Float)
    
    func update(deltaTime: Float)
    
    func render(_ encoder: MTLRenderCommandEncoder)
}
