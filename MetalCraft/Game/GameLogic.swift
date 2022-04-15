import Metal

class GameLogic {
    private static var scene: Scene = buildSandboxScene()
    
    static func tick(encoder: MTLRenderCommandEncoder, deltaTime: Float) {
        scene.update(deltaTime: deltaTime)
        scene.render(encoder)
    }
}
