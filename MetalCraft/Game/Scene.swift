import simd
import Metal

class Scene {
    var camera: Camera
    private var textures: [MTLTexture]
    private var children: [Node] = []
    private var instanceCollections: [InstanceCollection] = []
    
    init(camera: Camera, textures: [MTLTexture], children: [Node], instanceCollections: [InstanceCollection]) {
        self.camera = camera
        self.textures = textures
        self.children = children
        self.instanceCollections = instanceCollections
    }
    
    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)

        for node in children {
            node.update(deltaTime: deltaTime, parentMatrix: camera.projectionViewMatrix)
        }
        for collection in instanceCollections {
            collection.update(deltaTime: deltaTime)
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(Engine.RenderPipelineState)
        encoder.setDepthStencilState(Engine.DepthPencilState)
        
        encoder.setFragmentSamplerState(Engine.SamplerState, index: 0)
        encoder.setFragmentTextures(textures, range: 0..<textures.count)
        
        for collection in instanceCollections {
            collection.render(encoder)
        }
    }
}
