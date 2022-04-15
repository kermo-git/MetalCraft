
let Triangle = Mesh(
    vertices: [
        Vertex(position: Float3(-1,  1, 0), textureCoords: Float2(0, 0)),
        Vertex(position: Float3( 1,  1, 0), textureCoords: Float2(1, 0)),
        Vertex(position: Float3( 0, -1, 0), textureCoords: Float2(0.5, 1))
    ],
    indices: [0, 1, 2]
)

let Quad = Mesh(
    vertices: [
        Vertex(position: Float3(-1,  1, 0), textureCoords: Float2(0, 0)),
        Vertex(position: Float3(-1, -1, 0), textureCoords: Float2(0, 1)),
        Vertex(position: Float3( 1, -1, 0), textureCoords: Float2(1, 1)),
        Vertex(position: Float3( 1,  1, 0), textureCoords: Float2(1, 0)),
    ],
    indices: [
        0, 1, 2,
        3, 2, 0
    ]
)

let Cube = Mesh(
    vertices: [
        // Bottom vertices
        Vertex(position: Float3(-1, -1, -1), textureCoords: Float2(0, 0)),
        Vertex(position: Float3( 1, -1, -1), textureCoords: Float2(1, 0)),
        Vertex(position: Float3(-1, -1,  1), textureCoords: Float2(0, 1)),
        Vertex(position: Float3( 1, -1,  1), textureCoords: Float2(1, 1)),
        
        // Top vertices
        Vertex(position: Float3(-1,  1, -1), textureCoords: Float2(0, 1)),
        Vertex(position: Float3( 1,  1, -1), textureCoords: Float2(1, 1)),
        Vertex(position: Float3(-1,  1,  1), textureCoords: Float2(0, 0)),
        Vertex(position: Float3( 1,  1,  1), textureCoords: Float2(1, 0)),
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

let Pyramid = Mesh(
    vertices: [
        // Apex
        Vertex(position: Float3(0, 1, 0), textureCoords: Float2(0.5, 0)),
        
        // Bottom vertices
        Vertex(position: Float3(-1, -1, -1), textureCoords: Float2(0, 1)),
        Vertex(position: Float3( 1, -1, -1), textureCoords: Float2(1, 1)),
        Vertex(position: Float3(-1, -1,  1), textureCoords: Float2(1, 1)),
        Vertex(position: Float3( 1, -1,  1), textureCoords: Float2(0, 1)),
    ],
    indices: [
        // Bottom
        1, 2, 3,
        2, 3, 4,
        
        // Sides
        1, 0, 2,
        2, 0, 4,
        4, 0, 3,
        3, 0, 1,
    ]
)
