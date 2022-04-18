import simd
import Metal

class Scene { 
    var camera: Camera
    private var rootNode: Node
    private var instanceCollections: [InstanceCollection] = []
    
    init(camera: Camera, rootNode: Node, instanceCollections: [InstanceCollection]) {
        self.camera = camera
        self.rootNode = rootNode
        self.instanceCollections = instanceCollections
    }
    
    var mat: Float4x4!
    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
        rootNode.update(deltaTime: deltaTime,
                        parentPVM: camera.projectionViewMatrix)
        
        for collection in instanceCollections {
            collection.update(deltaTime: deltaTime)
        }
    }
    
    var fragmentConstants = FragmentConstants()
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(Engine.RenderPipelineState)
        encoder.setDepthStencilState(Engine.DepthPencilState)
        
        TextureLibrary.render(encoder)
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.size(), index: 1)
        
        for collection in instanceCollections {
            collection.render(encoder)
        }
    }
}
