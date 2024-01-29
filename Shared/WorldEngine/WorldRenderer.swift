import simd
import Metal

let BACKGROUND_COLOR = Float4(x: 0.075,
                              y: 0.78,
                              z: 0.95,
                              w: 1)

class WorldRenderer: Renderer, ObservableObject {
    private var vertexConstants = VertexConstants()
    private var fragmentConstants = FragmentConstants()
    
    private let textures: [MTLTexture] =
        TextureType.allCases.map {
            Engine.loadTexture(fileName: $0.rawValue)
        }
    
    private var cameraPos: ChunkPos
    private let loader: ChunkLoader
    
    init(generator: @escaping (_ pos: ChunkPos) -> Chunk, camera: Camera) {
        cameraPos = getChunkPos(camera.position)
        loader = ChunkLoader(generator: generator)
        
        super.init(
            camera: camera,
            renderPipeline: Engine.getRenderPipelineState(
                vertexShaderName: "worldVertex",
                fragmentShaderName: "worldFragment",
                vDescriptor: createVertexDescriptor()
            )!
        )
        clearColor = MTLClearColor(red: Double(BACKGROUND_COLOR.x),
                                   green: Double(BACKGROUND_COLOR.y),
                                   blue: Double(BACKGROUND_COLOR.z),
                                   alpha: Double(BACKGROUND_COLOR.w))
    }
    
    override func updateScene(deltaTime: Float) async {
        let newCameraPos = getChunkPos(camera.position)
        let posChanged = cameraPos != newCameraPos
        
        cameraPos = newCameraPos
        
        vertexConstants.projectionViewMatrix = projectionMatrix * camera.viewMatrix
        fragmentConstants.cameraPos = camera.position
        fragmentConstants.renderDistance = RENDER_DISTANCE_BLOCKS
        
        await loader.update(cameraPos: newCameraPos, posChanged: posChanged)
    }
    
    override func renderScene(_ encoder: MTLRenderCommandEncoder) async {
        encoder.setFragmentSamplerState(Engine.SamplerState, index: 0)
        encoder.setFragmentTextures(textures, range: 0..<textures.count)
        
        encoder.setVertexBytes(&vertexConstants, length: VertexConstants.size(), index: 1)
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.size(), index: 1)
        
        for (_, chunk) in await loader.renderedChunks {
            let (buffer, vertexCount) = await chunk.getRenderData()
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
        }
    }
}
