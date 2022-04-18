import simd

func buildQuad() -> Mesh {
    let x: Float = 0.5
    let y: Float = 0.5
    
    return Mesh(
        vertices: [
            Vertex(position: Float3(-x,  y, 0), normal: Float3(0, 0, 1), textureCoords: Float2(0, 0)),
            Vertex(position: Float3(-x, -y, 0), normal: Float3(0, 0, 1), textureCoords: Float2(0, 1)),
            Vertex(position: Float3( x, -y, 0), normal: Float3(0, 0, 1), textureCoords: Float2(1, 1)),
            Vertex(position: Float3( x,  y, 0), normal: Float3(0, 0, 1), textureCoords: Float2(1, 0)),
        ],
        indices: [
            0, 1, 2,
            3, 2, 0
        ]
    )
}

let RAD_90_DEG = toRadians(90)
let RAD_MINUS_90_DEG = toRadians(-90)
let RAD_180_DEG = toRadians(180)

func getTopFace(X: Int, Y: Int, Z: Int, textureType: TextureType) -> Node {
    let result = Node(textureType: textureType)
    result.rotation.x = RAD_MINUS_90_DEG
    
    result.position.x = Float(X) + 0.5
    result.position.y = Float(Y) + 1
    result.position.z = Float(Z) + 0.5
    result.updateMatrixes()
    
    return result
}

func getBottomFace(X: Int, Y: Int, Z: Int, textureType: TextureType) -> Node {
    let result = Node(textureType: textureType)
    result.rotation.x = RAD_90_DEG
    
    result.position.x = Float(X) + 0.5
    result.position.y = Float(Y)
    result.position.z = Float(Z) + 0.5
    result.updateMatrixes()
    
    return result
}

func getLeftFace(X: Int, Y: Int, Z: Int, textureType: TextureType) -> Node {
    let result = Node(textureType: textureType)
    result.rotation.y = RAD_MINUS_90_DEG
    
    result.position.x = Float(X)
    result.position.y = Float(Y) + 0.5
    result.position.z = Float(Z) + 0.5
    result.updateMatrixes()
    
    return result
}

func getRightFace(X: Int, Y: Int, Z: Int, textureType: TextureType) -> Node {
    let result = Node(textureType: textureType)
    result.rotation.y = RAD_90_DEG
    
    result.position.x = Float(X) + 1
    result.position.y = Float(Y) + 0.5
    result.position.z = Float(Z) + 0.5
    result.updateMatrixes()
    
    return result
}

func getNearFace(X: Int, Y: Int, Z: Int, textureType: TextureType) -> Node {
    let result = Node(textureType: textureType)
    
    result.position.x = Float(X) + 0.5
    result.position.y = Float(Y) + 0.5
    result.position.z = Float(Z) + 1
    result.updateMatrixes()
    
    return result
}

func getFarFace(X: Int, Y: Int, Z: Int, textureType: TextureType) -> Node {
    let result = Node(textureType: textureType)
    result.rotation.y = RAD_180_DEG
    
    result.position.x = Float(X) + 0.5
    result.position.y = Float(Y) + 0.5
    result.position.z = Float(Z)
    result.updateMatrixes()
    
    return result
}
