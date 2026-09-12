enum SILBorrowUtils {
    static func canBorrow(_ type: SILType) -> Bool {
        switch type {
        case .void:
            return false
        case .pointer:
            return true
        default:
            return true
        }
    }

    static func borrowedType(_ type: SILType) -> SILType {
        type
    }

    static func isGuaranteedBorrow(_ instruction: SILInstruction) -> Bool {
        if case .debugValue = instruction {
            return false
        }

        return false
    }
}
