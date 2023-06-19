import Metal

let BACKGROUND_COLOR = Float4(x: 0.075,
                              y: 0.78,
                              z: 0.95,
                              w: 1)

class Preferences {
    static let ClearColor = MTLClearColor(red: Double(BACKGROUND_COLOR.x),
                                          green: Double(BACKGROUND_COLOR.y),
                                          blue: Double(BACKGROUND_COLOR.z),
                                          alpha: Double(BACKGROUND_COLOR.w))
    static let PixelFormat = MTLPixelFormat.bgra8Unorm
    static let DepthPixelFormat = MTLPixelFormat.depth32Float
}
