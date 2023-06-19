import simd
import Metal

let RENDER_DISTANCE_CHUNKS = Float(8)
let RENDER_DISTANCE_BLOCKS = RENDER_DISTANCE_CHUNKS * Float(CHUNK_SIDE)
let MEMORY_DISTANCE_CHUNKS = Float(64)

class WorldRenderer: Renderer {
    private let localRenderCircle: [ChunkPos] = generateCircle(radiusChunks: Int(RENDER_DISTANCE_CHUNKS))
    
    private var cameraChunkPos: ChunkPos
    private var memoryChunks: [ChunkPos : LoadedChunk] = [:]
    private var renderedChunks: [ChunkPos : LoadedChunk] = [:]
    private var toBeGenerated: [ChunkPos]
    
    private var generator: (_ pos: ChunkPos) -> Chunk
    
    init(generator: @escaping (_ pos: ChunkPos) -> Chunk, camera: Camera) {
        self.cameraChunkPos = getChunkPos(camera.position)
        self.generator = generator
        self.toBeGenerated = localRenderCircle
        
        super.init(
            camera: camera,
            renderPipelineState: Engine.getRenderPipelineState(
                vertexShaderName: "vertexShader",
                fragmentShaderName: "fragmentShader",
                vDescriptor: getVertexDescriptor()
            )!
        )
    }
    
    private let textures: [MTLTexture] =
        TextureType.allCases.map {
            Engine.loadTexture(fileName: $0.rawValue)
        }
    
    private var sceneConstants = SceneConstants()
    private var fragmentConstants = FragmentConstants()
    
    override func updateScene(deltaTime: Float) {
        let newPlayerChunkPos = getChunkPos(camera.position)
        
        if (cameraChunkPos != newPlayerChunkPos) {
            for (pos, chunk) in memoryChunks {
                let distanceFromPlayer = distance(pos, newPlayerChunkPos)
                
                if (distanceFromPlayer > RENDER_DISTANCE_CHUNKS) {
                    renderedChunks.removeValue(forKey: pos)
                } else {
                    renderedChunks[pos] = chunk
                }
                if (distanceFromPlayer > MEMORY_DISTANCE_CHUNKS) {
                    memoryChunks.removeValue(forKey: pos)
                }
            }
            
            let globalRenderCircle = localRenderCircle.map {
                ChunkPos(X: newPlayerChunkPos.X + $0.X,
                         Z: newPlayerChunkPos.Z + $0.Z)
            }
            
            for pos in globalRenderCircle {
                if (memoryChunks[pos] == nil) {
                    toBeGenerated.append(pos)
                }
            }
            cameraChunkPos = newPlayerChunkPos
        }
        if (!toBeGenerated.isEmpty) {
            let pos = toBeGenerated.remove(at: 0)
            let distanceFromPlayer = distance(pos, newPlayerChunkPos)
            
            if (distanceFromPlayer <= RENDER_DISTANCE_CHUNKS) {
                // addChunk(pos: pos, newChunk: generateChunk(pos: pos))
                // This makes the game faster, but may occasionally crash:
                Task {
                    addChunk(pos: pos, newChunk: generateChunk(pos: pos))
                }
            }
        }
        
        sceneConstants.projectionViewMatrix = projectionMatrix * camera.getViewMatrix()
        fragmentConstants.cameraPos = camera.position
        fragmentConstants.renderDistance = RENDER_DISTANCE_BLOCKS
    }
    
    override func renderScene(_ encoder: MTLRenderCommandEncoder) {
        encoder.setFragmentSamplerState(Engine.SamplerState, index: 0)
        encoder.setFragmentTextures(textures, range: 0..<textures.count)
        
        encoder.setVertexBytes(&sceneConstants, length: SceneConstants.size(), index: 1)
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.size(), index: 1)
        
        for (_, chunk) in renderedChunks {
            encoder.setVertexBuffer(chunk.vertexBuffer, offset: 0, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: chunk.faces.count * 6)
        }
    }
    
    private func addChunk(pos: ChunkPos, newChunk: Chunk) {
        var faces = getBlockFaces(chunk: newChunk)
        
        let southPos = pos.move(.SOUTH)
        if let southChunk = memoryChunks[southPos] {
            let (southChunkFaces, newChunkFaces) = getNorthBorderBlockFaces(southChunk: southChunk.data,
                                                                            northChunk: newChunk)
            southChunk.faces.append(southChunkFaces)
            southChunk.reCompile(pos: southPos)
            faces.append(newChunkFaces)
        }
        let northPos = pos.move(.NORTH)
        if let northChunk = memoryChunks[northPos] {
            let (newChunkFaces, northChunkFaces) = getNorthBorderBlockFaces(southChunk: newChunk,
                                                                            northChunk: northChunk.data)
            northChunk.faces.append(northChunkFaces)
            northChunk.reCompile(pos: northPos)
            faces.append(newChunkFaces)
        }
        let westPos = pos.move(.WEST)
        if let westChunk = memoryChunks[westPos] {
            let (newChunkFaces, westChunkFaces) = getWestBorderBlockFaces(eastChunk: newChunk,
                                                                          westChunk: westChunk.data)
            westChunk.faces.append(westChunkFaces)
            westChunk.reCompile(pos: westPos)
            faces.append(newChunkFaces)
        }
        let eastPos = pos.move(.EAST)
        if let eastChunk = memoryChunks[eastPos] {
            let (eastChunkFaces, newChunkFaces) = getWestBorderBlockFaces(eastChunk: eastChunk.data,
                                                                          westChunk: newChunk)
            eastChunk.faces.append(eastChunkFaces)
            eastChunk.reCompile(pos: eastPos)
            faces.append(newChunkFaces)
        }
        let newLoadedChunk = LoadedChunk(pos: pos, data: newChunk, faces: faces)
        renderedChunks[pos] = newLoadedChunk
        memoryChunks[pos] = newLoadedChunk
    }
}

private class LoadedChunk {
    var data: Chunk
    var faces: Faces
    var vertexBuffer: MTLBuffer!
    
    init(pos: ChunkPos, data: Chunk, faces: Faces) {
        self.data = data
        self.faces = faces
        reCompile(pos: pos)
    }
    
    func reCompile(pos: ChunkPos) {
        vertexBuffer = compile(chunkPos: pos, faces: faces)
    }
}

private func compile(chunkPos: ChunkPos, faces: Faces) -> MTLBuffer {
    var vertices: [Vertex] = []
    
    for (facePos, block) in faces {
        let globalPos = getGlobalPos(chunk: chunkPos, local: facePos.blockPos)
        vertices.append(contentsOf: createVertices(pos: globalPos,
                                                   dir: facePos.direction,
                                                   block: block))
    }
    
    return Engine.Device.makeBuffer(bytes: vertices,
                                    length: Vertex.size(vertices.count),
                                    options: [])!
}


private func generateCircle(radiusChunks: Int) -> [ChunkPos] {
    var result: [ChunkPos] = []
    
    func distanceFromCenter(_ pos: ChunkPos) -> Float {
        let fX = Float(pos.X)
        let fZ = Float(pos.Z)
        return sqrt(fX * fX + fZ * fZ)
    }
    
    for X in -radiusChunks...radiusChunks {
        for Z in -radiusChunks...radiusChunks {
            let pos = ChunkPos(X: X, Z: Z)
            
            if (distanceFromCenter(pos) <= Float(radiusChunks)) {
                result.append(pos)
            }
        }
    }
    
    return result.sorted() {
        distanceFromCenter($0) < distanceFromCenter($1)
    }
}
