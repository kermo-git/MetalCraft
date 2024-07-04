import simd
import Metal

class WorldScene: MetalScene {
    var clearColor: MTLClearColor
    
    let input = Input()
    var camera: FlyingCamera
    @Published var cameraBlockPos: Int3
    private var cameraChunkPos: Int2

    private var renderPipeline = Engine.getRenderPipelineState(
        vertexShaderName: "worldVertex",
        fragmentShaderName: "worldFragment",
        vertexDescriptor: createVertexDescriptor()
    )!
    private var vertexConstants = VertexConstants()
    private var fragmentConstants: FragmentConstants
    private let textures: MTLTexture
    
    private let loader: ChunkLoader
    
    init(generator: WorldGenerator,
         cameraPos: Float3) {
        
        let sunColor = Float4(x: 1, y: 1, z: 1, w: 1)
        let skyColor = Float4(x: 0.93, y: 1, z: 0.64, w: 1)
        clearColor = MTLClearColor(red: Double(skyColor.x),
                                   green: Double(skyColor.y),
                                   blue: Double(skyColor.z),
                                   alpha: Double(skyColor.w))
        
        camera = FlyingCamera(input: input, startPos: cameraPos)
        cameraBlockPos = getBlockPos(cameraPos)
        cameraChunkPos = getChunkPos(cameraPos)
        
        let renderDistanceChunks = 8
        let renderDistanceBlocks = Float(renderDistanceChunks * CHUNK_SIDE)
        
        fragmentConstants = FragmentConstants(
            cameraPos: cameraPos,
            sunDirection: normalize(Float3(0.8, 0.9, 1.3)),
            fogDistanceSquared: pow(renderDistanceBlocks, 2),
            fogColor: skyColor,
            sunColor: sunColor
        )
        textures = Engine.loadTextureArray(fileNames: generator.textureNames,
                                           imageWidth: 16,
                                           imageHeight: 16)
        loader = ChunkLoader(
            generator: generator,
            renderDistanceChunks: renderDistanceChunks,
            memoryDistanceChunks: 64
        )
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
