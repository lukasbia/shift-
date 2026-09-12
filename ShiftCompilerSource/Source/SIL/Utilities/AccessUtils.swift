enum SILAccessKind: Hashable {
    case read
    case modify
    case consume
    case borrow
}

struct SILAccess {
    let value: SILValue
    let kind: SILAccessKind
}

enum SILAccessUtils {
    static func isRead(_ kind: SILAccessKind) -> Bool {
        kind == .read || kind == .borrow
    }

    static func isWrite(_ kind: SILAccessKind) -> Bool {
        kind == .modify || kind == .consume
    }

    static func conflicts(_ lhs: SILAccessKind, _ rhs: SILAccessKind) -> Bool {
        if lhs == .read && rhs == .read {
            return false
        }

        if lhs == .borrow && rhs == .borrow {
            return false
        }

        return true
    }

    static func conflicts(_ lhs: SILAccess, _ rhs: SILAccess) -> Bool {
        lhs.value == rhs.value && conflicts(lhs.kind, rhs.kind)
    }
}
