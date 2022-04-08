
class Keyboard {
    private static let KEY_COUNT = 256
    private static var keys: [Bool] = [Bool].init(repeating: false, count: KEY_COUNT)
    
    static func setKeyPressed(_ keyCode: UInt16, _ isPressed: Bool) {
        keys[Int(keyCode)] = isPressed
    }
    
    static func isKeyPressed(_ keyCode: KeyCode) -> Bool {
        return keys[Int(keyCode.rawValue)]
    }
}

// Copied from https://github.com/twohyjr/Metal-Game-Engine-Tutorial/blob/master/Helpful%20Files/InputCodeFiles/Keycodes.swift

enum KeyCode: UInt16 {
    // Special Chars
    case SPACE    = 0x31
    case RETURN   = 0x24
    case ENTER    = 0x4C
    case ESCAPE   = 0x35
    case SHIFT    = 0x38
    case COMMAND  = 0x37

    // Arrow Keys
    case LEFT     = 0x7B
    case RIGHT    = 0x7C
    case DOWN     = 0x7D
    case UP       = 0x7E

    // Alphabet
    case A        = 0x00
    case B        = 0x0B
    case C        = 0x08
    case D        = 0x02
    case E        = 0x0E
    case F        = 0x03
    case G        = 0x05
    case H        = 0x04
    case I        = 0x22
    case J        = 0x26
    case K        = 0x28
    case L        = 0x25
    case M        = 0x2E
    case N        = 0x2D
    case O        = 0x1F
    case P        = 0x23
    case Q        = 0x0C
    case R        = 0x0F
    case S        = 0x01
    case T        = 0x11
    case U        = 0x20
    case V        = 0x09
    case W        = 0x0D
    case X        = 0x07
    case Y        = 0x10
    case Z        = 0x06

    // Top Numbers
    case ZERO     = 0x1D
    case ONE      = 0x12
    case TWO      = 0x13
    case THREE    = 0x14
    case FOUR     = 0x15
    case FIVE     = 0x17
    case SIX      = 0x16
    case SEVEN    = 0x1A
    case EIGHT    = 0x1C
    case NINE     = 0x19

    // Keypad Numbers
    case KEYPAD_0 = 0x52
    case KEYPAD_1 = 0x53
    case KEYPAD_2 = 0x54
    case KEYPAD_3 = 0x55
    case KEYPAD_4 = 0x56
    case KEYPAD_5 = 0x57
    case KEYPAD_6 = 0x58
    case KEYPAD_7 = 0x59
    case KEYPAD_8 = 0x5B
    case KEYPAD_9 = 0x5C
}
