import simd
import Metal

class Renderer {
    var camera: Camera
    var clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
    private var renderPipeline: MTLRenderPipelineState
    
    var projectionMatrix: Float4x4 = matrix_identity_float4x4
    var projectionViewMatrix: Float4x4 = matrix_identity_float4x4
    
    init(camera: Camera, renderPipeline: MTLRenderPipelineState) {
        self.camera = camera
        self.renderPipeline = renderPipeline
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
        projectionViewMatrix = projectionMatrix * camera.viewMatrix
        updateScene(deltaTime: deltaTime)
    }
    
    func updateScene(deltaTime: Float) {
        // Override in subclass
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) async {
        encoder.setRenderPipelineState(renderPipeline)
        await renderScene(encoder)
    }
    
    func renderScene(_ encoder: MTLRenderCommandEncoder) async {
        // Override in subclass
    }
}
