//
// LexerError.swift
// Shift
//

enum LexerError: Error, CustomStringConvertible {

    case unexpectedCharacter(
        character: Character,
        location: SourceLocation
    )

    case unterminatedString(
        location: SourceLocation
    )

    case unterminatedCharacter(
        location: SourceLocation
    )

    case invalidCharacterLiteral(
        location: SourceLocation
    )

    case invalidEscapeSequence(
        sequence: String,
        location: SourceLocation
    )

    case invalidIntegerLiteral(
        lexeme: String,
        location: SourceLocation
    )

    case invalidFloatingLiteral(
        lexeme: String,
        location: SourceLocation
    )

    case invalidOperator(
        lexeme: String,
        location: SourceLocation
    )

    var description: String {

        switch self {

        case let .unexpectedCharacter(
            character,
            location
        ):
            return """
            Lex error at \
            \(location.line):\(location.column): \
            unexpected character '\(character)'.
            """

        case let .unterminatedString(
            location
        ):
            return """
            Lex error at \
            \(location.line):\(location.column): \
            unterminated string literal.
            """

        case let .unterminatedCharacter(
            location
        ):
            return """
            Lex error at \
            \(location.line):\(location.column): \
            unterminated character literal.
            """

        case let .invalidCharacterLiteral(
            location
        ):
            return """
            Lex error at \
            \(location.line):\(location.column): \
            invalid character literal.
            """

        case let .invalidEscapeSequence(
            sequence,
            location
        ):
            return """
            Lex error at \
            \(location.line):\(location.column): \
            invalid escape sequence '\(sequence)'.
            """

        case let .invalidIntegerLiteral(
            lexeme,
            location
        ):
            return """
            Lex error at \
            \(location.line):\(location.column): \
            invalid integer literal '\(lexeme)'.
            """

        case let .invalidFloatingLiteral(
            lexeme,
            location
        ):
            return """
            Lex error at \
            \(location.line):\(location.column): \
            invalid floating-point literal '\(lexeme)'.
            """

        case let .invalidOperator(
            lexeme,
            location
        ):
            return """
            Lex error at \
            \(location.line):\(location.column): \
            operator '\(lexeme)' is not valid in Shift.
            """
        }
    }
}