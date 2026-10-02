public struct ParserError: Error, CustomStringConvertible, Sendable {
    public enum Kind: Sendable {
        case unexpectedToken
        case expectedToken
        case expectedIdentifier
        case duplicateFunctionCallingName
        case nestedStruct
        case invalidStructMember
    }
    public let kind: Kind
    public let message: String
    public let location: SourceLocation
    public var description: String {
        "parser error at \(location): \(message)"
    }
}