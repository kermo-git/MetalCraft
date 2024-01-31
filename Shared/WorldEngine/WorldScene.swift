import simd
import Metal

let BACKGROUND_COLOR = Float4(x: 0.075,
                              y: 0.78,
                              z: 0.95,
                              w: 1)

class WorldScene: GameScene {
    @Published var cameraBlockPos = BlockPos(X: 0, Y: 0, Z: 0)
    private var cameraChunkPos = ChunkPos(X: 0, Z: 0)
    
    private var vertexConstants = VertexConstants()
    private var fragmentConstants = FragmentConstants()
    
    private let textures: [MTLTexture] =
        TextureType.allCases.map {
            Engine.loadTexture(fileName: $0.rawValue)
        }
    
    private let loader: ChunkLoader
    
    init(generator: @escaping (_ pos: ChunkPos) -> Chunk, cameraPos: Float3) {
        loader = ChunkLoader(generator: generator)
        
        super.init(
            renderPipeline: Engine.getRenderPipelineState(
                vertexShaderName: "worldVertex",
                fragmentShaderName: "worldFragment",
                vDescriptor: createVertexDescriptor()
            )!
        )
        camera.position = cameraPos
        self.cameraBlockPos = getBlockPos(camera.position)
        cameraChunkPos = getChunkPos(cameraPos)
        
        clearColor = MTLClearColor(red: Double(BACKGROUND_COLOR.x),
                                   green: Double(BACKGROUND_COLOR.y),
                                   blue: Double(BACKGROUND_COLOR.z),
                                   alpha: Double(BACKGROUND_COLOR.w))
    }
    
    override func updateScene(deltaTime: Float) async {
        let newCameraChunkPos = getChunkPos(camera.position)
        let posChanged = cameraChunkPos != newCameraChunkPos
        
        cameraChunkPos = newCameraChunkPos
        cameraBlockPos = getBlockPos(camera.position)
        
        vertexConstants.projectionViewMatrix = projectionMatrix * camera.viewMatrix
        fragmentConstants.cameraPos = camera.position
        fragmentConstants.renderDistance = RENDER_DISTANCE_BLOCKS
        
        await loader.update(cameraPos: newCameraChunkPos, posChanged: posChanged)
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
