protocol WorldGenerator {
    var blocks: [BlockDescriptor] { get }
    func generate(_ pos: ChunkPos) -> Chunk
}
