public enum LexerError: Error, Equatable, CustomStringConvertible {
    case invalidCharacter(
        character: Character,
        location: SourceLocation
    )

    case unterminatedString(
        location: SourceLocation
    )

    case unterminatedCharacter(
        location: SourceLocation
    )

    case invalidEscape(
        location: SourceLocation
    )

    case invalidCharacterLiteral(
        location: SourceLocation
    )

    case invalidNumber(
        lexeme: String,
        location: SourceLocation
    )

    case forbiddenCompoundAssignment(
        lexeme: String,
        location: SourceLocation
    )

    case forbiddenIncrementOperator(
        lexeme: String,
        location: SourceLocation
    )

    public var description: String {
        switch self {
        case let .invalidCharacter(character, location):
            return "\(location): invalid character '\(character)'"

        case let .unterminatedString(location):
            return "\(location): unterminated string literal"

        case let .unterminatedCharacter(location):
            return "\(location): unterminated character literal"

        case let .invalidEscape(location):
            return "\(location): invalid escape sequence"

        case let .invalidCharacterLiteral(location):
            return "\(location): character literal must contain exactly one character"

        case let .invalidNumber(lexeme, location):
            return "\(location): invalid numeric literal '\(lexeme)'"

        case let .forbiddenCompoundAssignment(lexeme, location):
            return "\(location): compound assignment '\(lexeme)' is not supported; Shift requires a separate assignment operation"

        case let .forbiddenIncrementOperator(lexeme, location):
            return "\(location): operator '\(lexeme)' is not supported"
        }
    }
}