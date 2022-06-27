
class Mouse {
    static var leftPressed = false
    static var rightPressed = false
    
    private static var position = Float2(repeating: 0)
    private static var positionDelta = Float2(repeating: 0)
    
    static func changePosition(newPosition: Float2, delta: Float2) {
        position = newPosition
        positionDelta = delta
    }
    
    static func getPosition() -> Float2 {
        return position;
    }
    
    static func getPositionDeltaX() -> Float {
        let result = positionDelta.x
        positionDelta.x = 0
        return result
    }
    
    static func getPositionDeltaY() -> Float {
        let result = positionDelta.y
        positionDelta.y = 0
        return result
    }
    
    private static var scrollPos: Float = 0
    private static var lastScrollPos: Float = 0
    private static var scrollPosDelta: Float = 0
    
    static func scroll(deltaY: Float) {
        scrollPos += deltaY
        scrollPosDelta += deltaY
    }
    
    static func getScrollPosDelta() -> Float {
        let result = scrollPosDelta
        scrollPosDelta = 0
        return result
    }
    
    static func GetMouseViewportPosition() -> Float2 {
        let x = (position.x - _screenSize.x * 0.5) / (_screenSize.x * 0.5)
        let y = (position.y - _screenSize.y * 0.5) / (_screenSize.y * 0.5)
        return Float2(x, y)
    }
}
