
class SandboxScene: Scene {
    
    override func buildScene() {
        let count = 10
        let scale: Float = 0.2
        
        for y in -count..<count {
            for x in -count..<count {
                let player = Player()
                player.position.x = (Float(x) + 0.5) / Float(count)
                player.position.y = (Float(y) + 0.5) / Float(count)
                player.scaleFactor = Float3(scale, scale, scale)
                addChild(player)
            }
        }
    }
}
