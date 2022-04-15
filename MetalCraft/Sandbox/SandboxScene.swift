import Darwin

func buildSandboxScene() -> Scene {
    let textures = [Textures.LimeBricks,
                    Textures.OrangeBricks,
                    Textures.YellowBricks,
                    Textures.Grass,
                    Textures.Sand]
    
    var cubes: [Node] = []
    var pyramids: [Node] = []
    
    let countX = 6
    let countY = 6
    let countZ = 6
    
    var index = 0
    var isCube = true
    var isRotatingAroundX = true
    
    for y in 0..<countY {
        let posY = Float(y) - Float(countY) * 0.5 + 0.5
        
        for x in 0..<countX {
            let posX = Float(x) - Float(countX) * 0.5 + 0.5
            
            for z in 0..<countZ {
                let posZ = Float(z) - Float(countZ) * 0.5 + 0.5
                
                var node: Node!
                if (isRotatingAroundX) {
                    node = RotateAroundX()
                } else {
                    node = RotateAroundZ()
                }
                node.position.y = posY
                node.position.x = posX
                node.position.z = posZ
                node.scaleFactor = Float3(repeating: 0.3)
                node.scaleFactor = Float3(repeating: 0.3)
                node.textureIdx = index % textures.count
                
                if (isCube) {
                    cubes.append(node)
                } else {
                    pyramids.append(node)
                }
                
                index += 1
                isCube = !isCube
                isRotatingAroundX = !isRotatingAroundX
            }
        }
    }
    
    let rotateAroundX = RotateAroundX()
    
    for cube in cubes {
        rotateAroundX.addChild(cube)
    }
    for pyramid in pyramids {
        rotateAroundX.addChild(pyramid)
    }
    rotateAroundX.position.z = -15
    
    let cubeCollection = InstanceCollection(mesh: Cube, instances: cubes)
    let pyramidCollection = InstanceCollection(mesh: Pyramid, instances: pyramids)
    
    return Scene(camera: FlyingCamera(speed: 3),
                 textures: textures,
                 children: [rotateAroundX],
                 instanceCollections: [cubeCollection, pyramidCollection])
}

class RotateAroundX: Node {
    override func updateModel(deltaTime: Float) {
        rotation.x += deltaTime
    }
}

class RotateAroundY: Node {
    override func updateModel(deltaTime: Float) {
        rotation.y += deltaTime
    }
}

class RotateAroundZ: Node {
    override func updateModel(deltaTime: Float) {
        rotation.z += deltaTime
    }
}
