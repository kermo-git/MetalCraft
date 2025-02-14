import Metal

protocol MetalScene: ObservableObject {
    var clearColor: MTLClearColor { get }
    
    func setAspectRatio(_ aspectRatio: Float)
    
    func update(deltaTime: Float) async
    
    func render(_ encoder: MTLRenderCommandEncoder) async
}
