import simd
import Metal

class WorldRenderer {
    var sceneConstants = SceneConstants()
    var fragmentConstants = FragmentConstants()
    var projectionMatrix: Float4x4 = matrix_identity_float4x4
    
    var meshIndexCount: Int
    var meshVertexBuffer: MTLBuffer
    var meshIndexBuffer: MTLBuffer
    
    init() {
        let mesh = buildQuad()
        meshIndexCount = mesh.indices.count
        
        meshVertexBuffer = Engine.Device.makeBuffer(bytes: mesh.vertices,
                                                length: Vertex.size(mesh.vertices.count),
                                                options: [])!
        
        meshIndexBuffer = Engine.Device.makeBuffer(bytes: mesh.indices,
                                               length: UInt16.size(mesh.indices.count),
                                               options: [])!
        
        updateAspectRatio(aspectRatio: Renderer.aspectRatio)
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
        
        encoder.setVertexBuffer(meshVertexBuffer, offset: 0, index: 0)
        encoder.setVertexBytes(&sceneConstants, length: SceneConstants.size(), index: 1)
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.size(), index: 1)
        
        for (_, chunk) in WorldState.renderedChunks {
            encoder.setVertexBuffer(chunk.buffer, offset: 0, index: 2)
            encoder.drawIndexedPrimitives(type: .triangle,
                                          indexCount: meshIndexCount,
                                          indexType: .uint16,
                                          indexBuffer: meshIndexBuffer,
                                          indexBufferOffset: 0,
                                          instanceCount: chunk.faces.count)
        }
    }
}

