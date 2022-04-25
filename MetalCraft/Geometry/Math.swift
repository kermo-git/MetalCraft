import simd

func toRadians(_ degrees: Float) -> Float {
    return degrees * Float.pi / 180
}

func toDegrees(_ radians: Float) -> Float {
    return (radians * 180) / Float.pi
}

func turnClockwise(_ vector: Float2) -> Float2 {
    return Float2(vector.y, -vector.x)
}

func turnCounterClockwise(_ vector: Float2) -> Float2 {
    return Float2(-vector.y, vector.x)
}

func transform(vec3: Float3, matrix: Float4x4) -> Float3 {
    let vec4 = Float4(vec3.x, vec3.y, vec3.z, 1)
    let result4 = vec4 * matrix
    return Float3(result4.x, result4.y, result4.z)
}

func translate(_ x: Float, _ y: Float, _ z: Float) -> Float4x4 {
    return Float4x4(
        Float4(1, 0, 0, 0),
        Float4(0, 1, 0, 0),
        Float4(0, 0, 1, 0),
        Float4(x, y, z, 1)
    )
}

func scale(_ x: Float, _ y: Float, _ z: Float) -> Float4x4 {
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

// https://gamedev.stackexchange.com/questions/120338/what-does-a-perspective-projection-matrix-look-like-in-opengl
func perspective(degreesFov: Float, aspectRatio: Float, near: Float, far: Float) -> Float4x4 {
    let fov = toRadians(degreesFov)
    let t: Float = tan(fov/2)
    
    let x = 1 / (aspectRatio * t)
    let y = 1 / t
    let z = -((far + near) / (far - near))
    let w = -((2 * far * near) / (far - near))
    
    return Float4x4(
        Float4(x, 0, 0,  0),
        Float4(0, y, 0,  0),
        Float4(0, 0, z, -1),
        Float4(0, 0, w,  0)
    )
}
