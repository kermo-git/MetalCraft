import Metal

enum MeshType {
    case Triangle
    case Quad
    case Cube
}

class MeshLibrary {
    private static var meshes: [MeshType: Mesh] = [:]
    
    static func Initialize() {
        meshes.updateValue(Triangle(), forKey: .Triangle)
        meshes.updateValue(Quad(), forKey: .Quad)
        meshes.updateValue(Cube(), forKey: .Cube)
    }
    
    static func Mesh(_ type: MeshType) -> Mesh {
        return meshes[type]!
    }
}

protocol Mesh {
    var vertexBuffer: MTLBuffer! {get}
    var indexBuffer: MTLBuffer! {get}
    var vertexCount: Int! {get}
    var indexCount: Int! {get}
}

class CustomMesh: Mesh {
    var vertices: [Vertex]!
    var indices: [UInt16]!
    
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    var vertexCount: Int! {
        vertices.count
    }
    var indexCount: Int! {
        indices.count
    }
    
    init() {
        createVerticesAndIndices()
        createBuffers()
    }
    
    func createVerticesAndIndices() {}
    
    func createBuffers() {
        vertexBuffer = Engine.Device.makeBuffer(bytes: vertices,
                                                length: Vertex.size(vertices.count),
                                                options: [])
        
        indexBuffer = Engine.Device.makeBuffer(bytes: indices,
                                               length: UInt16.size(indices.count),
                                               options: [])
    }
}

class Triangle: CustomMesh {
    override func createVerticesAndIndices() {
        vertices = [
            Vertex(position: Float3(-0.5,  0.5, 0), color: Float4(0.5,   0,   0, 1)),
            Vertex(position: Float3( 0.5,  0.5, 0), color: Float4(  0, 0.5,   0, 1)),
            Vertex(position: Float3(   0, -0.5, 0), color: Float4(  0,   0, 0.5, 1))
        ]
        indices = [0, 1, 2]
    }
}

class Quad: CustomMesh {
    override func createVerticesAndIndices() {
        vertices = [
            Vertex(position: Float3(-0.5,  0.5, 0), color: Float4(0.5,   0,   0, 1)),
            Vertex(position: Float3(-0.5, -0.5, 0), color: Float4(  0, 0.5,   0, 1)),
            Vertex(position: Float3( 0.5, -0.5, 0), color: Float4(  0,   0, 0.5, 1)),
            Vertex(position: Float3( 0.5,  0.5, 0), color: Float4(0.5, 0.5,   0, 1)),
        ]
        indices = [
            0, 1, 2,
            3, 2, 0
        ]
    }
}

class Cube: CustomMesh {
    override func createVerticesAndIndices() {
        vertices = [
            // Bottom vertices
            Vertex(position: Float3(-1, -1, -1), color: Float4(0,   0.2, 0.8, 1)),
            Vertex(position: Float3( 1, -1, -1), color: Float4(0.3, 0.7,   0, 1)),
            Vertex(position: Float3(-1, -1,  1), color: Float4(0.6, 0.4, 0.2, 1)),
            Vertex(position: Float3( 1, -1,  1), color: Float4(0.9, 0.3, 0.8, 1)),
            
            // Top vertices
            Vertex(position: Float3(-1,  1, -1), color: Float4(0.2, 0.2, 0.4, 1)),
            Vertex(position: Float3( 1,  1, -1), color: Float4(0.3, 0.8, 0.8, 1)),
            Vertex(position: Float3(-1,  1,  1), color: Float4(0.7,   0, 0.7, 1)),
            Vertex(position: Float3( 1,  1,  1), color: Float4(0.5, 0.5, 0.2, 1)),
        ]
        indices = [
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
    }
}
