//
// SemanticType.swift
// Shift
//

indirect enum SemanticType: Equatable, Hashable {

    case void

    case bool

    case int
    case uint

    case int8
    case int16
    case int32
    case int64

    case uint8
    case uint16
    case uint32
    case uint64

    case float
    case double

    case string

    case character

    case named(String)

    case array(SemanticType)

    case pointer(SemanticType)

    case optional(SemanticType)

    case tuple([SemanticType])

    case function(
        parameters: [SemanticType],
        returnType: SemanticType
    )

    var isInteger: Bool {
        switch self {
        case .int,
             .uint,
             .int8,
             .int16,
             .int32,
             .int64,
             .uint8,
             .uint16,
             .uint32,
             .uint64:
            return true

        default:
            return false
        }
    }

    var isFloatingPoint: Bool {
        switch self {
        case .float,
             .double:
            return true

        default:
            return false
        }
    }

    var isNumeric: Bool {
        isInteger || isFloatingPoint
    }

    var isBoolean: Bool {
        self == .bool
    }

    var isVoid: Bool {
        self == .void
    }

    var description: String {

        switch self {

        case .void:
            return "Void"

        case .bool:
            return "Bool"

        case .int:
            return "Int"

        case .uint:
            return "UInt"

        case .int8:
            return "Int8"

        case .int16:
            return "Int16"

        case .int32:
            return "Int32"

        case .int64:
            return "Int64"

        case .uint8:
            return "UInt8"

        case .uint16:
            return "UInt16"

        case .uint32:
            return "UInt32"

        case .uint64:
            return "UInt64"

        case .float:
            return "Float"

        case .double:
            return "Double"

        case .string:
            return "String"

        case .character:
            return "Character"

        case .named(let name):
            return name

        case .array(let element):
            return "[\(element.description)]"

        case .pointer(let pointee):
            return "*\(pointee.description)"

        case .optional(let wrapped):
            return "\(wrapped.description)?"

        case .tuple(let elements):
            let types = elements
                .map(\.description)
                .joined(separator: ", ")

            return "(\(types))"

        case let .function(parameters, returnType):
            let parameters = parameters
                .map(\.description)
                .joined(separator: ", ")

            return "(\(parameters)) -> \(returnType.description)"
        }
    }
}