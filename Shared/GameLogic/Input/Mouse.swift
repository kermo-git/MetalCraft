
class Mouse {
    static var leftPressed = false
    static var rightPressed = false
    
    private static var deltaX: Float = 0
    private static var deltaY: Float = 0
    
    static func move(_ deltaX: Float, _ deltaY: Float) {
        self.deltaX = deltaX
        self.deltaY = deltaY
    }
    
    static func getPositionDeltaX() -> Float {
        let result = deltaX
        deltaX = 0
        return result
    }
    
    static func getPositionDeltaY() -> Float {
        let result = deltaY
        deltaY = 0
        return result
    }
}
