import simd
import Metal

class WorldRenderer {
    var sceneConstants = SceneConstants()
    var fragmentConstants = FragmentConstants()
    var projectionMatrix: Float4x4 = matrix_identity_float4x4
    
    init() {
        updateAspectRatio(aspectRatio: _aspectRatio)
    }
    
    func updateAspectRatio(aspectRatio: Float) {
        projectionMatrix = perspective(degreesFov: 45,
                                       aspectRatio: aspectRatio,
                                       near: 0.1,
                                       far: 1000)
    }
    
    func update(deltaTime: Float) {
        sceneConstants.projectionViewMatrix = projectionMatrix * Player.getViewMatrix()
        fragmentConstants.playerPos = Player.position
        fragmentConstants.renderDistance = RENDER_DISTANCE
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(Engine.RenderPipelineState)
        encoder.setDepthStencilState(Engine.DepthPencilState)
        
        TextureLibrary.render(encoder)
        
        encoder.setVertexBytes(&sceneConstants, length: SceneConstants.size(), index: 1)
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.size(), index: 1)
        
        for (_, chunk) in WorldState.renderedChunks {
            encoder.setVertexBuffer(chunk.vertexBuffer, offset: 0, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: chunk.faces.count * 6)
        }
    }
}

