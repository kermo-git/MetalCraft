protocol WorldGenerator {
    var blocks: [Block] { get }
    func generate(_ pos: Int2) -> Chunk
}
