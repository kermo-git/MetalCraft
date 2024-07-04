protocol WorldGenerator {
    var textureNames: [String] { get }
    var blocks: [Block] { get }
    func generateChunk(_ pos: Int2) -> Chunk
}
