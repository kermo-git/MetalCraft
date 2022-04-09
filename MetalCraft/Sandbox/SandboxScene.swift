import Darwin

class SandboxScene: Scene {
    override func buildScene() {
        let debugCamera = FlyingCamera()
        debugCamera.speed = 3
        camera = debugCamera
        
        let node1 = RotatingQuad()
        let node2 = RotatingCube()
        
        addChild(node1)
        node1.addChild(node2)
    }
}

class RotatingCube: Node {
    init() {
        super.init(mesh: Cube)
        scaleFactor = Float3(repeating: 0.3)
        position.z = 1
    }
    
    override func updateModel(deltaTime: Float) {
        rotation.y += deltaTime
    }
}

class RotatingQuad: Node {
    init() {
        super.init(mesh: Quad)
        position.z = -7
        scaleFactor = Float3(repeating: 1.6)
    }
    
    var time: Float = 0
    override func updateModel(deltaTime: Float) {
        time += deltaTime
        position.y = sin(time)
        rotation.y += deltaTime
    }
}
