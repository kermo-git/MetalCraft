
class Mouse {
    // SetMouseButtonPressed, IsMouseButtonPressed
    static var leftPressed = false
    static var rightPressed = false
    static var centerPressed = false
    
    static var position = Float2(repeating: 0) // SetOverallMousePosition, GetMouseWindowPosition
    private static var positionDelta = Float2(repeating: 0)
    
    // SetMousePositionChange
    static func changePosition(newPosition: Float2, delta: Float2) {
        position = newPosition
        positionDelta = delta
    }
    
    // GetDX
    static func getPositionDeltaX() -> Float {
        let result = positionDelta.x
        positionDelta.x = 0
        return result
    }
    
    // GetDY
    static func getPositionDeltaY() -> Float {
        let result = positionDelta.y
        positionDelta.y = 0
        return result
    }
    
    private static var scrollPos: Float = 0
    private static var lastScrollPos: Float = 0
    private static var scrollPosDelta: Float = 0
    
    // ScrollMouse
    static func scroll(deltaY: Float) {
        scrollPos += deltaY
        scrollPosDelta += deltaY
    }
    
    // GetDWheel
    static func getScrollPosDelta() -> Float {
        let result = scrollPosDelta
        scrollPosDelta = 0
        return result
    }
    
    //Returns the mouse position in screen-view coordinates [-1, 1]
    static func GetMouseViewportPosition() -> Float2 {
        let x = (position.x - Renderer.screenSize.x * 0.5) / (Renderer.screenSize.x * 0.5)
        let y = (position.y - Renderer.screenSize.y * 0.5) / (Renderer.screenSize.y * 0.5)
        return Float2(x, y)
    }
}
