import ShiftSIL

public indirect enum LLVMType: Equatable, Hashable, CustomStringConvertible {
    case void
    case integer(Int)
    case floating(Int)
    case pointer
    case array(Int, LLVMType)
    case structure([LLVMType])

    public var description: String {
        switch self {
        case .void: return "void"
        case .integer(let bits): return "i\(bits)"
        case .floating(let bits):
            switch bits { case 32: return "float"; case 64: return "double"; default: return "fp128" }
        case .pointer: return "ptr"
        case .array(let count, let element): return "[\(count) x \(element)]"
        case .structure(let elements): return "{ " + elements.map(\.description).joined(separator: ", ") + " }"
        }
    }
}

public enum LLVMTypeLowering {
    public static func lower(_ type: SILType) -> LLVMType {
        switch type {
        case .void: return .void
        case .bool: return .integer(1)
        case .integer(let width, _): return .integer(max(width, 1))
        case .floating(let width): return .floating(width)
        case .string: return .pointer
        case .character: return .integer(8)
        case .pointer, .address: return .pointer
        case .array: return .pointer
        case .optional: return .pointer
        case .tuple(let elements): return .structure(elements.map(lower))
        case .function: return .pointer
        case .named: return .pointer
        }
    }

    public static func pointee(_ type: SILType) -> LLVMType {
        switch type {
        case .address(let element), .pointer(let element): return lower(element)
        default: return lower(type)
        }
    }
}
