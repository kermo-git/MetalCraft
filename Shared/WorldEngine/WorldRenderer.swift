import simd
import Metal

private let renderDistanceChunks = 8
private let renderDistanceChunksSquared = renderDistanceChunks * renderDistanceChunks
private let memoryDistanceChunks = 64

@MainActor
class WorldRenderer: Renderer {
    var clearColor: MTLClearColor
    var engine = Engine()
    
    let input = Input()
    var camera: FlyingCamera
    @Published var cameraBlockPos: Int3
    private var cameraChunkPos: Int2
    
    private var renderPipeline: MTLRenderPipelineState
    private var sampler: MTLSamplerState
    private var depthStencilState: MTLDepthStencilState
    
    private var vertexConstants = VertexConstants()
    private var fragmentConstants: FragmentConstants
    private let textures: MTLTexture
    
    private let loader: ChunkLoader
    private var chunkVertexBuffers: [Int2 : (MTLBuffer, Int)] = [:]
    
    init(generator: WorldGenerator,
         cameraPos: Float3) {
        
        let sunColor = Float4(x: 1, y: 1, z: 1, w: 1)
        let skyColor = Float4(x: 65.0/255, y: 166.0/255, z: 224/255, w: 1)
        clearColor = MTLClearColor(red: Double(skyColor.x),
                                   green: Double(skyColor.y),
                                   blue: Double(skyColor.z),
                                   alpha: Double(skyColor.w))
        
        camera = FlyingCamera(input: input, startPos: cameraPos)
        cameraBlockPos = getBlockPos(cameraPos)
        cameraChunkPos = getChunkPos(cameraPos)
        
        let renderDistanceBlocks = Float(renderDistanceChunks * CHUNK_SIDE)
        
        renderPipeline = getRenderPipelineState(
            device: engine.device,
            vertexShaderName: "worldVertex",
            fragmentShaderName: "worldFragment",
            vertexDescriptor: createVertexDescriptor()
        )!
        sampler = getSamplerState(engine.device)
        depthStencilState = getDepthStencilState(engine.device)

        fragmentConstants = FragmentConstants(
            cameraPos: cameraPos,
            sunDirection: normalize(Float3(0.8, 0.9, 1.3)),
            fogDistanceSquared: pow(renderDistanceBlocks, 2),
            fogColor: skyColor,
            sunColor: sunColor
        )
        textures = engine.loadTextureArray(fileNames: generator.textureNames,
                                           imageWidth: 16,
                                           imageHeight: 16)
        loader = ChunkLoader(
            generator: generator,
            renderDistanceChunks: renderDistanceChunks,
            memoryDistanceChunks: memoryDistanceChunks
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
    
    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
        vertexConstants.projectionViewMatrix = projectionMatrix * camera.viewMatrix
        
        let newCameraChunkPos = getChunkPos(camera.position)
        let posChanged = cameraChunkPos != newCameraChunkPos
        
        cameraChunkPos = newCameraChunkPos
        
        fragmentConstants.cameraPos = camera.position
        cameraBlockPos = getBlockPos(camera.position)
        
        Task {
            let updatedChunks = await loader.update(cameraPos: newCameraChunkPos, posChanged: posChanged)
            await MainActor.run {
                for (pos, vertices) in updatedChunks {
                    if vertices.isEmpty {
                        chunkVertexBuffers.removeValue(forKey: pos)
                    } else {
                        let buffer = createVertexBuffer(device: engine.device, vertices: vertices)
                        chunkVertexBuffers[pos] = (buffer, vertices.count)
                    }
                }
            }
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setDepthStencilState(depthStencilState)
        encoder.setRenderPipelineState(renderPipeline)
        
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.memorySize(), index: 1)
        encoder.setFragmentSamplerState(sampler, index: 0)
        encoder.setFragmentTexture(textures, index: 0)

        encoder.setVertexBytes(&vertexConstants, length: VertexConstants.memorySize(), index: 1)
        
        let cameraViewX = -sin(camera.rotationY)
        let cameraViewZ = -cos(camera.rotationY)
        
        for (chunkPos, (buffer, vertexCount)) in chunkVertexBuffers {
            let cameraToChunkX = Float(chunkPos.x - cameraChunkPos.x)
            let cameraToChunkZ = Float(chunkPos.y - cameraChunkPos.y)
            
            let inRenderDistance = distanceSquared(cameraChunkPos, chunkPos) <= renderDistanceChunksSquared
            let inCameraView = cameraToChunkX * cameraViewX + cameraToChunkZ * cameraViewZ >= 0
            
            if (inRenderDistance && inCameraView) {
                encoder.setVertexBuffer(buffer, offset: 0, index: 0)
                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
            }
        }
    }
}
