public struct Token: Equatable, Hashable, Sendable {
    public enum Kind: Equatable, Hashable, Sendable {
        // MARK: - Special

        case endOfFile
        case identifier

        // MARK: - Keywords

        case letKeyword
        case varKeyword
        case funcKeyword
        case structKeyword
        case classKeyword
        case enumKeyword
        case protocolKeyword
        case extensionKeyword

        case publicKeyword
        case privateKeyword
        case internalKeyword
        case staticKeyword
        case mutatingKeyword
        case unsafeKeyword

        case breakKeyword
        case continueKeyword
        case returnKeyword
        case ifKeyword
        case elseKeyword
        case whileKeyword
        case forKeyword
        case switchKeyword
        case caseKeyword
        case defaultKeyword
        case inKeyword

        // MARK: - Built-in Types

        case intKeyword
        case uintKeyword
        case int8Keyword
        case int16Keyword
        case int32Keyword
        case int64Keyword

        case uint8Keyword
        case uint16Keyword
        case uint32Keyword
        case uint64Keyword

        case floatKeyword
        case doubleKeyword
        case boolKeyword
        case stringKeyword
        case voidKeyword

        // MARK: - Literals

        case integerLiteral
        case floatingLiteral
        case stringLiteral
        case characterLiteral
        case booleanLiteral

        // MARK: - Punctuation

        case colon
        case equal

        case leftParenthesis
        case rightParenthesis

        case leftBracket
        case rightBracket

        case leftBrace
        case rightBrace

        case comma
        case dot
        case arrow

        // MARK: - Operators

        case logicalOr
        case logicalAnd

        case pipe
        case caret
        case ampersand

        case equalEqual
        case notEqual

        case less
        case lessEqual
        case greater
        case greaterEqual

        case plus
        case minus
        case star
        case slash
        case percent

        case logicalNot
    }

    public let kind: Kind
    public let lexeme: String
    public let location: SourceLocation

    public init(
        kind: Kind,
        lexeme: String,
        location: SourceLocation
    ) {
        self.kind = kind
        self.lexeme = lexeme
        self.location = location
    }
}

public typealias TokenKind = Token.Kind