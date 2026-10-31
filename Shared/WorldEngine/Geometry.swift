import Metal

func createRotationMatrixData(device: MTLDevice) -> MTLBuffer {
    let data: [Half3x3] = [
        // NONE
        Half3x3(columns: (
            Half3(1, 0, 0),
            Half3(0, 1, 0),
            Half3(0, 0, 1)
        )),
        // Y90
        Half3x3(columns: (
            Half3(0, 0, -1),
            Half3(0, 1,  0),
            Half3(1, 0,  0)
        )),
        // YNEG90
        Half3x3(columns: (
            Half3( 0, 0, 1),
            Half3( 0, 1, 0),
            Half3(-1, 0, 0)
        )),
        // Y180
        Half3x3(columns: (
            Half3(-1, 0,  0),
            Half3( 0, 1,  0),
            Half3( 0, 0, -1)
        )),
        // X90
        Half3x3(columns: (
            Half3(1,  0, 0),
            Half3(0,  0, 1),
            Half3(0, -1, 0)
        )),
        // X90_Y90
        Half3x3(columns: (
            Half3(0,  0, -1),
            Half3(1,  0, 0),
            Half3(0, -1, 0)
        )),
        // X90_YNEG90
        Half3x3(columns: (
            Half3( 0,  0, 1),
            Half3(-1,  0, 0),
            Half3( 0, -1, 0)
        )),
        // X90_Y180
        Half3x3(columns: (
            Half3(-1,  0,  0),
            Half3( 0,  0, -1),
            Half3( 0, -1,  0)
        )),
        // Z90
        Half3x3(columns: (
            Half3( 0, 1, 0),
            Half3(-1, 0, 0),
            Half3( 0, 0, 1)
        )),
        // Z90_Y90
        Half3x3(columns: (
            Half3(0, 1, 0),
            Half3(0, 0, 1),
            Half3(1, 0, 0)
        )),
        // Z90_YNEG90
        Half3x3(columns: (
            Half3( 0, 1,  0),
            Half3( 0, 0, -1),
            Half3(-1, 0,  0)
        )),
        // Z90_Y180
        Half3x3(columns: (
            Half3(0, 1, 0),
            Half3(1, 0, 0),
            Half3(0, 0, -1)
        )),
    ]
    
    return device.makeBuffer(bytes: data,
                             length: data.memoryStride(),
                             options: [.storageModeShared])!
}

func createVertexPosData(device: MTLDevice) -> MTLBuffer {
    /*
     1 --- 2/4
     |     / |
     |    /  |
     |   /   |
     |  /    |
     0/3 --- 5
     */
    let data: [Half3] = [
        // UP
        Half3(-0.5,  0.5,  0.5), Half3(-0.5,  0.5, -0.5), Half3( 0.5,  0.5, -0.5),
        Half3(-0.5,  0.5,  0.5), Half3( 0.5,  0.5, -0.5), Half3( 0.5,  0.5,  0.5),
        // DOWN
        Half3( 0.5, -0.5,  0.5), Half3( 0.5, -0.5, -0.5), Half3(-0.5, -0.5, -0.5),
        Half3( 0.5, -0.5,  0.5), Half3(-0.5, -0.5, -0.5), Half3(-0.5, -0.5,  0.5),
        // WEST
        Half3(-0.5, -0.5, -0.5), Half3(-0.5,  0.5, -0.5), Half3(-0.5,  0.5,  0.5),
        Half3(-0.5, -0.5, -0.5), Half3(-0.5,  0.5,  0.5), Half3(-0.5, -0.5,  0.5),
        // EAST
        Half3( 0.5, -0.5,  0.5), Half3( 0.5,  0.5,  0.5), Half3( 0.5,  0.5, -0.5),
        Half3( 0.5, -0.5,  0.5), Half3( 0.5,  0.5, -0.5), Half3( 0.5, -0.5, -0.5),
        // SOUTH
        Half3(-0.5, -0.5,  0.5), Half3(-0.5,  0.5,  0.5), Half3( 0.5,  0.5,  0.5),
        Half3(-0.5, -0.5,  0.5), Half3( 0.5,  0.5,  0.5), Half3( 0.5, -0.5,  0.5),
        // NORTH
        Half3( 0.5, -0.5, -0.5), Half3( 0.5,  0.5, -0.5), Half3(-0.5,  0.5, -0.5),
        Half3( 0.5, -0.5, -0.5), Half3(-0.5,  0.5, -0.5), Half3(-0.5, -0.5, -0.5),
    ]
    
    return device.makeBuffer(bytes: data,
                             length: data.memoryStride(),
                             options: [.storageModeShared])!
}

func createTriangleNormalData(device: MTLDevice) -> MTLBuffer {
    let directions: [Direction] = [
        // UP
        .UP, .UP,
        // DOWN
        .DOWN, .DOWN,
        // WEST
        .WEST, .WEST,
        // EAST
        .EAST, .EAST,
        // SOUTH
        .SOUTH, .SOUTH,
        // NORTH
        .NORTH, .NORTH
    ]
    
    let data = directions.map { $0.rawValue }
    
    return device.makeBuffer(bytes: data,
                             length: data.memoryStride(),
                             options: [.storageModeShared])!
}

func createTextureCoordinateData(device: MTLDevice) -> MTLBuffer {
    let data = [
        // UP
        Half2(0, 1), Half2(0, 0), Half2(1, 0),
        Half2(0, 1), Half2(1, 0), Half2(1, 1),
        // DOWN
        Half2(0, 1), Half2(0, 0), Half2(1, 0),
        Half2(0, 1), Half2(1, 0), Half2(1, 1),
        // WEST
        Half2(0, 1), Half2(0, 0), Half2(1, 0),
        Half2(0, 1), Half2(1, 0), Half2(1, 1),
        // EAST
        Half2(0, 1), Half2(0, 0), Half2(1, 0),
        Half2(0, 1), Half2(1, 0), Half2(1, 1),
        // SOUTH
        Half2(0, 1), Half2(0, 0), Half2(1, 0),
        Half2(0, 1), Half2(1, 0), Half2(1, 1),
        // NORTH
        Half2(0, 1), Half2(0, 0), Half2(1, 0),
        Half2(0, 1), Half2(1, 0), Half2(1, 1),
    ]
    
    return device.makeBuffer(bytes: data,
                             length: data.memoryStride(),
                             options: [.storageModeShared])!
}
