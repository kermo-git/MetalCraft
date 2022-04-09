import Metal

class GameLogic {
    private static var scene: Scene!
    
    static func setScene(_ scene: Scene) {
        self.scene = scene
    }
    
    static func tick(encoder: MTLRenderCommandEncoder, deltaTime: Float) {
        scene.update(deltaTime: deltaTime)
        scene.render(encoder)
    }
}
