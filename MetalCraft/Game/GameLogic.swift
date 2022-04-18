import Metal

class GameLogic {
    static var scene: Scene = buildSandboxScene()
    
    static func tick(encoder: MTLRenderCommandEncoder, deltaTime: Float) {
        scene.update(deltaTime: deltaTime)
        scene.render(encoder)
    }
}
