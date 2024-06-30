protocol WorldGenerator {
    var blocks: [Block] { get }
    func generate(_ pos: ChunkPos) -> Chunk
}
