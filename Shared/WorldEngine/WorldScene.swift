import simd
import Metal

class WorldScene: GameScene {
    @Published var cameraBlockPos = BlockPos(X: 0, Y: 0, Z: 0)
    private var cameraChunkPos = ChunkPos(X: 0, Z: 0)
    
    private var vertexConstants = VertexConstants()
    private var fragmentConstants: FragmentConstants
    
    private let blocks: [BlockShaderInfo]
    private let textures: MTLTexture
    
    private let loader: ChunkLoader
    
    let input = Input()
    
    init(generator: WorldGenerator,
         cameraPos: Float3) {
        let sunColor = Float4(x: 1, y: 1, z: 1, w: 1)
        let skyColor = Float4(x: 0.93, y: 1, z: 0.64, w: 1)
        
        fragmentConstants = FragmentConstants(cameraPos: cameraPos,
                                              sunDirection: normalize(Float3(0.8, 0.9, 1.3)),
                                              renderDistance: RENDER_DISTANCE_BLOCKS,
                                              fogColor: skyColor,
                                              sunColor: sunColor)
        
        let (blocks, textures) = compileBlockCollection(generator.blocks)
        self.blocks = blocks
        self.textures = textures
        
        loader = ChunkLoader(blocks: blocks, generator: generator)
        
        super.init(
            renderPipeline: Engine.getRenderPipelineState(
                vertexShaderName: "worldVertex",
                fragmentShaderName: "worldFragment",
                vertexDescriptor: createVertexDescriptor()
            )!,
            camera: FlyingCamera(input: input, startPos: cameraPos)
        )
        cameraBlockPos = getBlockPos(cameraPos)
        cameraChunkPos = getChunkPos(cameraPos)
        
        clearColor = MTLClearColor(red: Double(skyColor.x),
                                   green: Double(skyColor.y),
                                   blue: Double(skyColor.z),
                                   alpha: Double(skyColor.w))
    }
    
    override func updateScene(deltaTime: Float) async {
        let newCameraChunkPos = getChunkPos(camera.position)
        let posChanged = cameraChunkPos != newCameraChunkPos
        
        cameraChunkPos = newCameraChunkPos
        
        vertexConstants.projectionViewMatrix = projectionViewMatrix
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
