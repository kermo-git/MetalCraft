import Metal

enum SceneType {
    case SandBox
}

class SceneManager {
    private static var currentScene: Scene!
    
    static func setScene(_ type: SceneType) {
        switch type {
            case .SandBox:
                currentScene = SandboxScene()
        }
    }
    
    static func tick(encoder: MTLRenderCommandEncoder, deltaTime: Float) {
        currentScene.update(deltaTime: deltaTime)
        currentScene.render(encoder)
    }
}
