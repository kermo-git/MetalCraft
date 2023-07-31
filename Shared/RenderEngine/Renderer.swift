import simd
import Metal

class Renderer {
    var camera: Camera
    private var renderPipelineState: MTLRenderPipelineState
    
    var projectionMatrix: Float4x4 = matrix_identity_float4x4
    var projectionViewMatrix: Float4x4 = matrix_identity_float4x4
    
    init(camera: Camera, renderPipelineState: MTLRenderPipelineState) {
        self.camera = camera
        self.renderPipelineState = renderPipelineState
        setAspectRatio(1)
    }
    
    func setAspectRatio(_ aspectRatio: Float) {
        projectionMatrix = perspective(degreesFov: camera.degreesFov,
                                       aspectRatio: aspectRatio,
                                       near: 0.1,
                                       far: 1000)
    }
    
    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
        projectionViewMatrix = projectionMatrix * camera.getViewMatrix()
        updateScene(deltaTime: deltaTime)
    }
    
    func updateScene(deltaTime: Float) {
        // Override in subclass
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) async {
        encoder.setRenderPipelineState(renderPipelineState)
        await renderScene(encoder)
    }
    
    func renderScene(_ encoder: MTLRenderCommandEncoder) async {
        // Override in subclass
    }
}
