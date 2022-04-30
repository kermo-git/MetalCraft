import simd

func getNormal(_ direction: Direction) -> Float3 {
    switch direction {
        case .UP:
            return Float3( 0, 1, 0)
        case .DOWN:
            return Float3( 0, -1, 0)
        case .WEST:
            return Float3(-1, 0, 0)
        case .EAST:
            return Float3( 1, 0, 0)
        case .SOUTH:
            return Float3( 0, 0, 1)
        case .NORTH:
            return Float3( 0, 0, -1)
    }
}

let RAD_90_DEG = toRadians(90)

func getModelMatrix(rotX: Float = 0, rotY: Float = 0, rotZ: Float = 0,
                    posX: Float = 0, posY: Float = 0, posZ: Float = 0) -> Float4x4 {
    return translate(posX, posY, posZ) *
           rotateAroundZ(rotZ) *
           rotateAroundY(rotY) *
           rotateAroundX(rotX)
}

func getModelMatrix(face: BlockFace) -> Float4x4 {
    let X = face.pos.X
    let Y = face.pos.Y
    let Z = face.pos.Z
    
    switch face.direction {
        case .UP:
            return getModelMatrix(rotX: RAD_90_DEG,
                                  posX: Float(X) + 0.5,
                                  posY: Float(Y) + 1,
                                  posZ: Float(Z) + 0.5)
        case .DOWN:
            return getModelMatrix(rotX: RAD_90_DEG,
                                  posX: Float(X) + 0.5,
                                  posY: Float(Y),
                                  posZ: Float(Z) + 0.5)
        case .WEST:
            return getModelMatrix(rotY: RAD_90_DEG,
                                  posX: Float(X),
                                  posY: Float(Y) + 0.5,
                                  posZ: Float(Z) + 0.5)
        case .EAST:
            return getModelMatrix(rotY: RAD_90_DEG,
                                  posX: Float(X) + 1,
                                  posY: Float(Y) + 0.5,
                                  posZ: Float(Z) + 0.5)
        case .SOUTH:
            return getModelMatrix(posX: Float(X) + 0.5,
                                  posY: Float(Y) + 0.5,
                                  posZ: Float(Z) + 1)
        case .NORTH:
            return getModelMatrix(posX: Float(X) + 0.5,
                                  posY: Float(Y) + 0.5,
                                  posZ: Float(Z))
    }
}
