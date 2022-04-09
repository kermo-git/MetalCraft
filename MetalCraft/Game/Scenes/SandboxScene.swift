
class SandboxScene: Scene {
    let cube = CubeObject()
    
    override func buildScene() {
        let camera = DebugCamera(speed: 3)
        cameraManager.addCamera(camera)
        addChild(cube)
        cube.rotation.y = 0.2
        cube.rotation.x = 0.2
        cube.position.z = -7
    }
}
