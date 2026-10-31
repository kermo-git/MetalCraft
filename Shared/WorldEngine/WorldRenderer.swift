import simd
import Metal

private let renderDistanceChunks: Int32 = 8
private let renderDistanceChunksSquared = renderDistanceChunks * renderDistanceChunks
private let memoryDistanceChunks: Int32 = 64

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
    
    private var vertexConstants: VertexConstants
    private let vertexPosBuffer: MTLBuffer
    private let triangleNormalBuffer: MTLBuffer
    private let textureCoordinateBuffer: MTLBuffer
    private let rotationMatrixBuffer: MTLBuffer
    
    private var fragmentConstants: FragmentConstants
    private let textures: MTLTexture
    
    private let loader: ChunkLoader
    private var chunkBuffers: [Int2 : (MTLBuffer, Int)] = [:]
    
    init(generator: WorldGenerator,
         cameraPos: Int3) {
        
        let sunColor = Half4(x: 1, y: 1, z: 1, w: 1)
        let skyColor = Half4(x: 65.0/255, y: 166.0/255, z: 224/255, w: 1)
        clearColor = MTLClearColor(red: Double(skyColor.x),
                                   green: Double(skyColor.y),
                                   blue: Double(skyColor.z),
                                   alpha: Double(skyColor.w))
        
        let cameraFloatPos = Float3(0, 0, 0)
        camera = FlyingCamera(input: input, startPos: cameraFloatPos)
        cameraBlockPos = cameraPos
        cameraChunkPos = getChunkPos(cameraPos)
        
        let renderDistanceBlocks = Float(renderDistanceChunks * CHUNK_SIDE)
        
        renderPipeline = engine.getRenderPipelineState(
            vertexShaderName: "worldVertex",
            fragmentShaderName: "worldFragment",
            vertexDescriptor: createVertexDescriptor()
        )!
        sampler = engine.getSamplerState()
        depthStencilState = engine.getDepthStencilState()

        vertexConstants = VertexConstants(cameraOrigin: cameraPos)
        vertexPosBuffer = createVertexPosData(device: engine.device)
        triangleNormalBuffer = createTriangleNormalData(device: engine.device)
        textureCoordinateBuffer = createTextureCoordinateData(device: engine.device)
        rotationMatrixBuffer = createRotationMatrixData(device: engine.device)
        
        fragmentConstants = FragmentConstants(
            cameraPos: cameraFloatPos,
            sunDirection: Half3(normalize(Float3(0.8, 0.9, 1.3))),
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
            memoryDistanceChunks: memoryDistanceChunks,
            cameraPos: cameraChunkPos
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
        
        cameraBlockPos = vertexConstants.cameraOrigin &+ getBlockPos(camera.position)
        let newCameraChunkPos = getChunkPos(cameraBlockPos)
        let posChanged = cameraChunkPos != newCameraChunkPos
        cameraChunkPos = newCameraChunkPos
        
        if camera.position.x > 5000 || camera.position.z > 5000 {
            vertexConstants.cameraOrigin = cameraBlockPos
            camera.position = Float3(0, 0, 0)
        }
        
        vertexConstants.projectionViewMatrix = projectionMatrix * camera.viewMatrix
        fragmentConstants.cameraPos = camera.position
        
        Task {
            let updatedChunks = await loader.update(cameraPos: newCameraChunkPos, posChanged: posChanged)
            await MainActor.run {
                for (pos, faces) in updatedChunks {
                    if faces.isEmpty {
                        chunkBuffers.removeValue(forKey: pos)
                    } else {
                        let buffer = engine.device.makeBuffer(bytes: faces,
                                                              length: faces.memoryStride(),
                                                              options: [])!
                        chunkBuffers[pos] = (buffer, 6 * faces.count)
                    }
                }
            }
        }
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setCullMode(.back)
        encoder.setFrontFacing(.clockwise)
        
        encoder.setDepthStencilState(depthStencilState)
        encoder.setRenderPipelineState(renderPipeline)
        
        encoder.setVertexBytes(
            &vertexConstants,
            length: MemoryLayout<VertexConstants>.stride,
            index: 0
        )
        
        encoder.setVertexBuffer(vertexPosBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(triangleNormalBuffer, offset: 0, index: 2)
        encoder.setVertexBuffer(textureCoordinateBuffer, offset: 0, index: 3)
        encoder.setVertexBuffer(rotationMatrixBuffer, offset: 0, index: 4)
        
        encoder.setFragmentBytes(
            &fragmentConstants,
            length: MemoryLayout<FragmentConstants>.stride,
            index: 1
        )
        encoder.setFragmentSamplerState(sampler, index: 0)
        encoder.setFragmentTexture(textures, index: 0)
        
        let cameraViewX = -sin(camera.rotationY)
        let cameraViewZ = -cos(camera.rotationY)
        
        for (chunkPos, (buffer, vertexCount)) in chunkBuffers {
            let cameraToChunkX = Float(chunkPos.x - cameraChunkPos.x)
            let cameraToChunkZ = Float(chunkPos.y - cameraChunkPos.y)
            
            let inRenderDistance = distanceSquared(cameraChunkPos, chunkPos) <= renderDistanceChunksSquared
            let inCameraView = cameraToChunkX * cameraViewX + cameraToChunkZ * cameraViewZ >= 0
            
            if (inRenderDistance && inCameraView) {
                encoder.setVertexBuffer(buffer, offset: 0, index: 5)
                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
            }
        }
    }
}
