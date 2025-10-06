import simd
import Dispatch
import Metal

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency
// https://swiftbysundell.com/articles/swift-actors/

actor ChunkLoader {
    var chunks: [Int2 : RenderableChunk] = [:]
    
    private var renderCircle: [Int2]
    private var generationQueue: [Int2]
    
    private var generator: WorldGenerator
    private var renderDistanceChunksSquared: Int
    private var memoryDistanceChunksSquared: Int
    
    init(generator: WorldGenerator,
         renderDistanceChunks: Int,
         memoryDistanceChunks: Int) {
        
        renderCircle = getChunkPosCircle(radiusChunks: renderDistanceChunks)
        generationQueue = renderCircle
        
        self.generator = generator
        renderDistanceChunksSquared = renderDistanceChunks * renderDistanceChunks
        memoryDistanceChunksSquared = memoryDistanceChunks * memoryDistanceChunks
    }
    
    func update(cameraPos: Int2, posChanged: Bool) async -> [Int2 : [Vertex]] {
        var updatedChunkVertices: [Int2 : [Vertex]] = [:]
        
        if (!generationQueue.isEmpty) {
            let pos = generationQueue.remove(at: 0)
            let d_sqr = distanceSquared(pos, cameraPos)
            
            if (d_sqr <= renderDistanceChunksSquared) {
                updatedChunkVertices = await addChunk(pos: pos)
            }
        }
        if (posChanged) {
            for (pos, _) in chunks {
                let d_sqr = distanceSquared(pos, cameraPos)
                
                if (d_sqr > memoryDistanceChunksSquared) {
                    chunks.removeValue(forKey: pos)
                    updatedChunkVertices[pos] = []
                }
            }
            
            let globalRenderCircle = renderCircle.map {
                Int2(x: cameraPos.x + $0.x,
                     y: cameraPos.y + $0.y)
            }
            
            for pos in globalRenderCircle {
                if (chunks[pos] == nil) {
                    generationQueue.append(pos)
                }
            }
        }
        return updatedChunkVertices
    }
    // https://medium.com/@jaredcassoutt/how-to-define-your-own-if-flags-in-swift-and-why-you-should-797508c243a2
    // Build Settings -> Swift Compiler — Custom Flags
    // -> Other Swift Flags -> add or remove -DMEASURE_TIME
    #if MEASURE_TIME
    var n_chunks_generated = 0
    var total_chunk_generation_ms: Float = 0
    #endif
    
    private func addChunk(pos: Int2) async -> [Int2 : [Vertex]] {
        #if MEASURE_TIME
        let start = DispatchTime.now()
        #endif
        let newChunk = generator.generateChunk(pos)
        var faces = getBlockFaces(chunk: newChunk)
        var result: [Int2 : [Vertex]] = [:]
        
        let northPos = pos.move(.NORTH)
        if let northChunk = chunks[northPos] {
            let (newChunkFaces, northChunkFaces) = getNorthBorderBlockFaces(
                southChunk: newChunk,
                northChunk: await northChunk.data
            )
            await northChunk.addFaces(newFaces: northChunkFaces)
            let northChunkVertices = await northChunk.createVertices(blocks: generator.blocks, chunkPos: northPos)
            
            if !northChunkVertices.isEmpty {
                result[northPos] = northChunkVertices
            }
            faces.append(newChunkFaces)
        }
        
        let southPos = pos.move(.SOUTH)
        if let southChunk = chunks[southPos] {
            let (southChunkFaces, newChunkFaces) = getNorthBorderBlockFaces(
                southChunk: await southChunk.data,
                northChunk: newChunk
            )
            await southChunk.addFaces(newFaces: southChunkFaces)
            let southChunkVertices = await southChunk.createVertices(blocks: generator.blocks, chunkPos: southPos)
            
            if !southChunkVertices.isEmpty {
                result[southPos] = southChunkVertices
            }
            faces.append(newChunkFaces)
        }
        
        let westPos = pos.move(.WEST)
        if let westChunk = chunks[westPos] {
            let (newChunkFaces, westChunkFaces) = getWestBorderBlockFaces(
                eastChunk: newChunk,
                westChunk: await westChunk.data
            )
            await westChunk.addFaces(newFaces: westChunkFaces)
            let westChunkVertices = await westChunk.createVertices(blocks: generator.blocks, chunkPos: westPos)
            
            if !westChunkVertices.isEmpty {
                result[westPos] = westChunkVertices
            }
            faces.append(newChunkFaces)
        }
        
        let eastPos = pos.move(.EAST)
        if let eastChunk = chunks[eastPos] {
            let (eastChunkFaces, newChunkFaces) = getWestBorderBlockFaces(
                eastChunk: await eastChunk.data,
                westChunk: newChunk
            )
            await eastChunk.addFaces(newFaces: eastChunkFaces)
            let eastChunkVertices = await eastChunk.createVertices(blocks: generator.blocks, chunkPos: eastPos)
            
            if !eastChunkVertices.isEmpty {
                result[eastPos] = eastChunkVertices
            }
            faces.append(newChunkFaces)
        }

        let newRenderableChunk = RenderableChunk(data: newChunk, faces: faces)
        chunks[pos] = newRenderableChunk
        result[pos] = await newRenderableChunk.createVertices(blocks: generator.blocks, chunkPos: pos)

        #if MEASURE_TIME
        let end = DispatchTime.now()
        total_chunk_generation_ms += Float(end.uptimeNanoseconds - start.uptimeNanoseconds)/1_000_000
        n_chunks_generated += 1
        print("Average generation time for \(n_chunks_generated) chunks: \(total_chunk_generation_ms/Float(n_chunks_generated)) ms")
        #endif
        
        return result
    }
}


private func getChunkPosCircle(radiusChunks: Int) -> [Int2] {
    var result: [Int2] = []
    
    for X in -radiusChunks...radiusChunks {
        for Z in -radiusChunks...radiusChunks {
            let pos = Int2(X, Z)
            
            if (simd_length(Float2(pos)) <= Float(radiusChunks)) {
                result.append(pos)
            }
        }
    }
    
    return result.sorted() {
        simd_length(Float2($0)) < simd_length(Float2($1))
    }
}
