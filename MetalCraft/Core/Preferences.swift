import Metal

class ClearColors {
    static let BLACK = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let GRAY = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    static let GREEN = MTLClearColor(red: 0.22, green: 0.55, blue: 0.34, alpha: 1)
}

class Preferences {
    static let ClearColor = ClearColors.BLACK
    static let PixelFormat = MTLPixelFormat.bgra8Unorm
    static let InitialScene = SceneType.SandBox
}
