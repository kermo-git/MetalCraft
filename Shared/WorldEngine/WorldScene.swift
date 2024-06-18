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
    
    private let blocks: [BlockShaderInfo]
    private let textures: MTLTexture
    
    private let loader: ChunkLoader
    
    init(generator: WorldGenerator,
         cameraPos: Float3) {
        
        let (blocks, textures) = compileBlockCollection(generator.blocks)
        self.blocks = blocks
        self.textures = textures
        
        loader = ChunkLoader(blocks: blocks, generator: generator)
        
        super.init(
            renderPipeline: Engine.getRenderPipelineState(
                vertexShaderName: "worldVertex",
                fragmentShaderName: "worldFragment",
                vertexDescriptor: createVertexDescriptor()
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
        
        vertexConstants.projectionViewMatrix = projectionMatrix * camera.viewMatrix
        fragmentConstants.cameraPos = camera.position
        fragmentConstants.renderDistance = RENDER_DISTANCE_BLOCKS
        
        await loader.update(cameraPos: newCameraChunkPos, posChanged: posChanged)
        await MainActor.run {
            cameraBlockPos = getBlockPos(camera.position)
        }
    }
    
    override func renderScene(_ encoder: MTLRenderCommandEncoder) async {
        encoder.setFragmentSamplerState(Engine.sampler, index: 0)
        encoder.setFragmentTexture(textures, index: 0)
        
        encoder.setVertexBytes(&vertexConstants, length: VertexConstants.memorySize(), index: 1)
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.memorySize(), index: 1)
        
        for (_, chunk) in await loader.renderedChunks {
            let buffer = await chunk.vertexBuffer
            let vertexCount = await chunk.vertexCount
            
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
        }
    }
}
