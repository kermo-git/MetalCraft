
let Triangle = Mesh(
    vertices: [
        Vertex(position: Float3(-0.5,  0.5, 0), color: Float4(0.5,   0,   0, 1)),
        Vertex(position: Float3( 0.5,  0.5, 0), color: Float4(  0, 0.5,   0, 1)),
        Vertex(position: Float3(   0, -0.5, 0), color: Float4(  0,   0, 0.5, 1))
    ],
    indices: [0, 1, 2]
)

let Quad = Mesh(
    vertices: [
        Vertex(position: Float3(-0.5,  0.5, 0), color: Float4(0.5,   0,   0, 1)),
        Vertex(position: Float3(-0.5, -0.5, 0), color: Float4(  0, 0.5,   0, 1)),
        Vertex(position: Float3( 0.5, -0.5, 0), color: Float4(  0,   0, 0.5, 1)),
        Vertex(position: Float3( 0.5,  0.5, 0), color: Float4(0.5, 0.5,   0, 1)),
    ],
    indices: [
        0, 1, 2,
        3, 2, 0
    ]
)

let Cube = Mesh(
    vertices: [
        // Bottom vertices
        Vertex(position: Float3(-1, -1, -1), color: Float4(0.2, 0.2, 0.2, 1)),
        Vertex(position: Float3( 1, -1, -1), color: Float4(0.2, 0.2, 0.8, 1)),
        Vertex(position: Float3(-1, -1,  1), color: Float4(0.8, 0.8, 0.2, 1)),
        Vertex(position: Float3( 1, -1,  1), color: Float4(0.8, 0.8, 0.8, 1)),
        
        // Top vertices
        Vertex(position: Float3(-1,  1, -1), color: Float4(0.2, 0.2, 0.4, 1)),
        Vertex(position: Float3( 1,  1, -1), color: Float4(0.3, 0.8, 0.8, 1)),
        Vertex(position: Float3(-1,  1,  1), color: Float4(0.7,   0, 0.7, 1)),
        Vertex(position: Float3( 1,  1,  1), color: Float4(0.5, 0.5, 0.2, 1)),
    ],
    indices: [
        // Bottom face
        0, 1, 2,
        1, 2, 3,
        
        // Top face
        4, 5, 6,
        5, 6, 7,
        
        // Front face
        1, 0, 4,
        1, 5, 4,
        
        // Back face
        2, 3, 6,
        3, 7, 6,
        
        // Left face
        0, 2, 6,
        0, 4, 6,
        
        // Right face
        1, 3, 7,
        1, 5, 7
    ]
)
