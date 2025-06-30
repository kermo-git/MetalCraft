import Metal

protocol MetalScene: ObservableObject {
    var clearColor: MTLClearColor { get }
    
    func setAspectRatio(_ aspectRatio: Float)
    
    func update(deltaTime: Float)
    
    func render(_ encoder: MTLRenderCommandEncoder) async
}
