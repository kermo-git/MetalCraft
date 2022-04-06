import simd

func toRadians(_ degrees: Float) -> Float {
    degrees * Float.pi / 180
}

func translate(dir: Float3) -> Float4x4 {
    let x = dir.x
    let y = dir.y
    let z = dir.z
    
    return Float4x4(
        Float4(1, 0, 0, 0),
        Float4(0, 1, 0, 0),
        Float4(0, 0, 1, 0),
        Float4(x, y, z, 1)
    )
}

func scale(axis: Float3) -> Float4x4 {
    let x = axis.x
    let y = axis.y
    let z = axis.z
    
    return Float4x4(
        Float4(x, 0, 0, 0),
        Float4(0, y, 0, 0),
        Float4(0, 0, z, 0),
        Float4(0, 0, 0, 1)
    )
}

func rotateAroundX(_ radians: Float) -> Float4x4 {
    let sin = sin(radians)
    let cos = cos(radians)
    
    return Float4x4(
        Float4(1,  0,   0,   0),
        Float4(0,  cos, sin, 0),
        Float4(0, -sin, cos, 0),
        Float4(0,  0,   0,   1)
    )
}

func rotateAroundY(_ radians: Float) -> Float4x4 {
    let sin = sin(radians)
    let cos = cos(radians)
    
    return Float4x4(
        Float4(cos, 0, -sin, 0),
        Float4(0,   1,  0,   0),
        Float4(sin, 0,  cos, 0),
        Float4(0,   0,  0,   1)
    )
}

func rotateAroundZ(_ radians: Float) -> Float4x4 {
    let sin = sin(radians)
    let cos = cos(radians)
    
    return Float4x4(
        Float4( cos, sin, 0, 0),
        Float4(-sin, cos, 0, 0),
        Float4( 0,   0,   1, 0),
        Float4( 0,   0,   0, 1)
    )
}
