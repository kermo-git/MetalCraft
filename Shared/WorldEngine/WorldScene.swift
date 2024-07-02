import simd
import Metal

class WorldScene: GameScene {
    @Published var cameraBlockPos = Int3(0, 0, 0)
    private var cameraChunkPos = Int2(0, 0)
    var camera: FlyingCamera
    
    var clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)

    private var renderPipeline = Engine.getRenderPipelineState(
        vertexShaderName: "worldVertex",
        fragmentShaderName: "worldFragment",
        vertexDescriptor: createVertexDescriptor()
    )!
    private var vertexConstants = VertexConstants()
    private var fragmentConstants: FragmentConstants
    
    private let blocks: [Block]
    private let textures: MTLTexture
    
    private let loader: ChunkLoader
    
    let input = Input()
    
    init(generator: WorldGenerator,
         cameraPos: Float3) {
        let sunColor = Float4(x: 1, y: 1, z: 1, w: 1)
        let skyColor = Float4(x: 0.93, y: 1, z: 0.64, w: 1)
        let renderDistanceBlocks = Float(RENDER_DISTANCE_CHUNKS * CHUNK_SIDE)
        
        fragmentConstants = FragmentConstants(
            cameraPos: cameraPos,
            sunDirection: normalize(Float3(0.8, 0.9, 1.3)),
            renderDistanceSquared: pow(renderDistanceBlocks, 2),
            fogColor: skyColor,
            sunColor: sunColor
        )
        
        let (blocks, textures) = compileBlockCollection(generator.blocks)
        self.blocks = blocks
        self.textures = textures
        
        loader = ChunkLoader(blocks: blocks, generator: generator)
        
        camera = FlyingCamera(input: input, startPos: cameraPos)
        cameraBlockPos = getBlockPos(cameraPos)
        cameraChunkPos = getChunkPos(cameraPos)
        
        clearColor = MTLClearColor(red: Double(skyColor.x),
                                   green: Double(skyColor.y),
                                   blue: Double(skyColor.z),
                                   alpha: Double(skyColor.w))
        setAspectRatio(1)
    }
    
    var projectionMatrix: Float4x4 = matrix_identity_float4x4
    
    func setAspectRatio(_ aspectRatio: Float) {
        projectionMatrix = perspective(degreesFov: camera.degreesFov,
                                       aspectRatio: aspectRatio,
                                       near: 0.1,
                                       far: 1000)
    }
    
    func update(deltaTime: Float) async {
        camera.update(deltaTime: deltaTime)
        vertexConstants.projectionViewMatrix = projectionMatrix * camera.viewMatrix
        
        let newCameraChunkPos = getChunkPos(camera.position)
        let posChanged = cameraChunkPos != newCameraChunkPos
        
        cameraChunkPos = newCameraChunkPos
        
        fragmentConstants.cameraPos = camera.position
        
        await loader.update(cameraPos: newCameraChunkPos, posChanged: posChanged)
        await MainActor.run {
            cameraBlockPos = getBlockPos(camera.position)
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) async {
        encoder.setRenderPipelineState(renderPipeline)
        
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.memorySize(), index: 1)
        encoder.setFragmentSamplerState(Engine.sampler, index: 0)
        encoder.setFragmentTexture(textures, index: 0)

        encoder.setVertexBytes(&vertexConstants, length: VertexConstants.memorySize(), index: 1)
        
        for (_, chunk) in await loader.renderedChunks {
            let buffer = await chunk.vertexBuffer
            let vertexCount = await chunk.vertexCount
            
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
        }
    }
}
