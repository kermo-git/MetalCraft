import Metal

enum MeshType {
    case Triangle
    case Quad
}

class MeshLibrary {
    private static var meshes: [MeshType: Mesh] = [:]
    
    static func Initialize() {
        meshes.updateValue(Triangle(), forKey: .Triangle)
        meshes.updateValue(Quad(), forKey: .Quad)
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
