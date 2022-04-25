import simd

func getNormal(_ direction: Direction) -> Float3 {
    switch direction {
        case .UP:
            return Float3( 0, 1, 0)
        case .DOWN:
            return Float3( 0, -1, 0)
        case .LEFT:
            return Float3(-1, 0, 0)
        case .RIGHT:
            return Float3( 1, 0, 0)
        case .NEAR:
            return Float3( 0, 0, 1)
        case .FAR:
            return Float3( 0, 0, -1)
    }
}

let RAD_90_DEG = toRadians(90)
let RAD_MINUS_90_DEG = toRadians(-90)
let RAD_180_DEG = toRadians(180)

func getModelMatrix(rotX: Float = 0, rotY: Float = 0, rotZ: Float = 0,
                    posX: Float = 0, posY: Float = 0, posZ: Float = 0) -> Float4x4 {
    return translate(posX, posY, posZ) *
           rotateAroundZ(rotZ) *
           rotateAroundY(rotY) *
           rotateAroundX(rotX)
}

func getModelMatrix(face: BlockFace) -> Float4x4 {
    let X = face.X
    let Y = face.Y
    let Z = face.Z
    
    switch face.direction {
        case .UP:
            return getModelMatrix(rotX: RAD_MINUS_90_DEG,
                                  posX: Float(X) + 0.5,
                                  posY: Float(Y) + 1,
                                  posZ: Float(Z) + 0.5)
        case .DOWN:
            return getModelMatrix(rotX: RAD_90_DEG,
                                  posX: Float(X) + 0.5,
                                  posY: Float(Y),
                                  posZ: Float(Z) + 0.5)
        case .LEFT:
            return getModelMatrix(rotY: RAD_MINUS_90_DEG,
                                  posX: Float(X),
                                  posY: Float(Y) + 0.5,
                                  posZ: Float(Z) + 0.5)
        case .RIGHT:
            return getModelMatrix(rotY: RAD_90_DEG,
                                  posX: Float(X) + 1,
                                  posY: Float(Y) + 0.5,
                                  posZ: Float(Z) + 0.5)
        case .NEAR:
            return getModelMatrix(posX: Float(X) + 0.5,
                                  posY: Float(Y) + 0.5,
                                  posZ: Float(Z) + 1)
        case .FAR:
            return getModelMatrix(posX: Float(X) + 0.5,
                                  posY: Float(Y) + 0.5,
                                  posZ: Float(Z))
    }
}
