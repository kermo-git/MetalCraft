
struct Mesh {
    var vertices: [Vertex]
    var indices: [UInt16]
}

func buildQuad() -> Mesh {
    let x: Float = 0.5
    let y: Float = 0.5
    
    return Mesh(
        vertices: [
            Vertex(position: Float3(-x,  y, 0), textureCoords: Float2(0, 0)),
            Vertex(position: Float3(-x, -y, 0), textureCoords: Float2(0, 1)),
            Vertex(position: Float3( x, -y, 0), textureCoords: Float2(1, 1)),
            Vertex(position: Float3( x,  y, 0), textureCoords: Float2(1, 0)),
        ],
        indices: [
            0, 1, 2,
            3, 2, 0
        ]
    )
}
