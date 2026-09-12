public enum IRGenError: Error, CustomStringConvertible {
    case unsupportedInstruction(String)
    case unsupportedType(String)
    case invalidFunction(String)
    case missingValue(Int)
    case malformedControlFlow(String)

    public var description: String {
        switch self {
        case .unsupportedInstruction(let value): return "IRGen: unsupported SIL instruction: \(value)"
        case .unsupportedType(let value): return "IRGen: unsupported SIL type: \(value)"
        case .invalidFunction(let value): return "IRGen: invalid SIL function: \(value)"
        case .missingValue(let id): return "IRGen: SIL value %\(id) has no LLVM value"
        case .malformedControlFlow(let value): return "IRGen: malformed control flow: \(value)"
        }
    }
}
