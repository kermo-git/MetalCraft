import simd
import Metal

class SceneRenderer {
    var blockRenderer = BlockRenderer()
    var sceneConstants = SceneConstants()
    var fragmentConstants = FragmentConstants()
    var projectionMatrix: Float4x4 = matrix_identity_float4x4
    
    init() {
        blockRenderer.setFaces(faces: World.getFaces())
        updateAspectRatio(aspectRatio: Renderer.aspectRatio)
    }
    
    func updateAspectRatio(aspectRatio: Float) {
        projectionMatrix = perspective(degreesFov: 45,
                                       aspectRatio: aspectRatio,
                                       near: 0.1,
                                       far: 1000)
    }
    
    func update(deltaTime: Float) {
        Player.update(deltaTime: deltaTime)
        sceneConstants.projectionViewMatrix = projectionMatrix * Player.camera.getViewMatrix()
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(Engine.RenderPipelineState)
        encoder.setDepthStencilState(Engine.DepthPencilState)
        
        TextureLibrary.render(encoder)
        encoder.setVertexBytes(&sceneConstants, length: SceneConstants.size(), index: 1)
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.size(), index: 1)
        
        blockRenderer.render(encoder)
    }
}
