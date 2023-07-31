
class Input {
    static var moveForward = false
    static var moveBackward = false
    static var moveLeft = false
    static var moveRight = false
    static var flyUp = false
    static var flyDown = false
    
    private static var camRotationX: Float = 0
    private static var camRotationY: Float = 0
    
    static func rotateCamera(_ deltaX: Float, _ deltaY: Float) {
        self.camRotationX = deltaX
        self.camRotationY = deltaY
    }
    
    static func getCamRotationX() -> Float {
        let result = camRotationX
        camRotationX = 0
        return result
    }
    
    static func getCamRotationY() -> Float {
        let result = camRotationY
        camRotationY = 0
        return result
    }
}
