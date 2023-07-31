import simd
import Metal

let RENDER_DISTANCE_CHUNKS = Float(8)
let RENDER_DISTANCE_BLOCKS = RENDER_DISTANCE_CHUNKS * Float(CHUNK_SIDE)
let MEMORY_DISTANCE_CHUNKS = Float(64)

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency
// https://swiftbysundell.com/articles/swift-actors/

private let localRenderCircle: [ChunkPos] = generateCircle(radiusChunks: Int(RENDER_DISTANCE_CHUNKS))

class WorldRenderer: Renderer {
    private var cameraPos: ChunkPos
    private let loader: ChunkLoader
    
    init(generator: @escaping (_ pos: ChunkPos) -> Chunk, camera: Camera) {
        cameraPos = getChunkPos(camera.position)
        loader = ChunkLoader(generator: generator)
        
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
        let newCameraPos = getChunkPos(camera.position)
        let posChanged = cameraPos != newCameraPos
        
        Task {
            await loader.generationCycle(cameraPos: newCameraPos, posChanged: posChanged)
        }
        cameraPos = newCameraPos
        
        sceneConstants.projectionViewMatrix = projectionMatrix * camera.getViewMatrix()
        fragmentConstants.cameraPos = camera.position
        fragmentConstants.renderDistance = RENDER_DISTANCE_BLOCKS
    }
    
    override func renderScene(_ encoder: MTLRenderCommandEncoder) async {
        encoder.setFragmentSamplerState(Engine.SamplerState, index: 0)
        encoder.setFragmentTextures(textures, range: 0..<textures.count)
        
        encoder.setVertexBytes(&sceneConstants, length: SceneConstants.size(), index: 1)
        encoder.setFragmentBytes(&fragmentConstants, length: FragmentConstants.size(), index: 1)
        
        for (_, chunk) in await loader.renderedChunks {
            let (buffer, faceCount) = await chunk.getRenderData()
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: faceCount * 6)
        }
    }
}

private actor ChunkLoader {
    var renderedChunks: [ChunkPos : LoadedChunk] = [:]
    
    private var memoryChunks: [ChunkPos : LoadedChunk] = [:]
    private var generationQueue: [ChunkPos] = localRenderCircle
    private var generator: (_ pos: ChunkPos) -> Chunk
    
    init(generator: @escaping (_ pos: ChunkPos) -> Chunk) {
        self.generator = generator
    }
    
    func generationCycle(cameraPos: ChunkPos, posChanged: Bool) {
        if (posChanged) {
            for (pos, chunk) in memoryChunks {
                let distance = distance(pos, cameraPos)
                
                if (distance > MEMORY_DISTANCE_CHUNKS) {
                    memoryChunks.removeValue(forKey: pos)
                    renderedChunks.removeValue(forKey: pos)
                } else if (distance > RENDER_DISTANCE_CHUNKS) {
                    renderedChunks.removeValue(forKey: pos)
                } else {
                    renderedChunks[pos] = chunk
                }
            }
            
            let globalRenderCircle = localRenderCircle.map {
                ChunkPos(X: cameraPos.X + $0.X,
                         Z: cameraPos.Z + $0.Z)
            }
            
            for pos in globalRenderCircle {
                if (memoryChunks[pos] == nil) {
                    generationQueue.append(pos)
                }
            }
        } else if (!generationQueue.isEmpty) {
            let pos = generationQueue.remove(at: 0)
            let distance = distance(pos, cameraPos)
            
            if (distance <= RENDER_DISTANCE_CHUNKS) {
                addChunk(pos: pos, newChunk: generator(pos))
            }
        }
    }
    
    func addChunk(pos: ChunkPos, newChunk: Chunk) {
        @Sendable func getTopFaces() async -> Faces {
            return getBlockFaces(chunk: newChunk)
        }
        @Sendable func getSouthFaces() async -> Faces {
            let southPos = pos.move(.SOUTH)
            if let southChunk = await memoryChunks[southPos] {
                let (southChunkFaces, newChunkFaces) = getNorthBorderBlockFaces(southChunk: await southChunk.data,
                                                                                northChunk: newChunk)
                await southChunk.addFaces(southChunkFaces)
                return newChunkFaces
            }
            return Faces()
        }
        @Sendable func getNorthFaces() async -> Faces {
            let northPos = pos.move(.NORTH)
            if let northChunk = await memoryChunks[northPos] {
                let (newChunkFaces, northChunkFaces) = getNorthBorderBlockFaces(southChunk: newChunk,
                                                                                northChunk: await northChunk.data)
                await northChunk.addFaces(northChunkFaces)
                return newChunkFaces
            }
            return Faces()
        }
        @Sendable func getWestFaces() async -> Faces {
            let westPos = pos.move(.WEST)
            if let westChunk = await memoryChunks[westPos] {
                let (newChunkFaces, westChunkFaces) = getWestBorderBlockFaces(eastChunk: newChunk,
                                                                              westChunk: await westChunk.data)
                await westChunk.addFaces(westChunkFaces)
                return newChunkFaces
            }
            return Faces()
        }
        @Sendable func getEastFaces() async -> Faces {
            let eastPos = pos.move(.EAST)
            if let eastChunk = await memoryChunks[eastPos] {
                let (eastChunkFaces, newChunkFaces) = getWestBorderBlockFaces(eastChunk: await eastChunk.data,
                                                                              westChunk: newChunk)
                await eastChunk.addFaces(eastChunkFaces)
                return newChunkFaces
            }
            return Faces()
        }
        
        Task {
            async let topFaces = getTopFaces()
            async let northFaces = getNorthFaces()
            async let southFaces = getSouthFaces()
            async let westFaces = getWestFaces()
            async let eastFaces = getEastFaces()
            
            var faces = Faces()
            for sideFaces in await [topFaces, northFaces, southFaces, westFaces, eastFaces] {
                faces.append(sideFaces)
            }
            let newLoadedChunk = LoadedChunk(pos: pos, data: newChunk, faces: faces)
            memoryChunks[pos] = newLoadedChunk
            renderedChunks[pos] = newLoadedChunk
        }
    }
}

private actor LoadedChunk {
    var pos: ChunkPos
    var data: Chunk
    var faces: Faces
    var vertexBuffer: MTLBuffer!
    
    init(pos: ChunkPos, data: Chunk, faces: Faces) {
        self.pos = pos
        self.data = data
        self.faces = faces
        vertexBuffer = compile(chunkPos: pos, faces: faces)
    }
    
    func addFaces(_ newFaces: Faces) {
        faces.append(newFaces)
        vertexBuffer = compile(chunkPos: pos, faces: faces)
    }
    
    func getRenderData() -> (MTLBuffer, Int) {
        return (vertexBuffer, faces.count)
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
