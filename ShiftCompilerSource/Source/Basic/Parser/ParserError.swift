import Foundation

enum ParserError: Error, CustomStringConvertible {
    case unexpectedToken(
        expected: String,
        actual: Token,
        message: String?
    )

    case unexpectedEndOfFile(
        expected: String,
        location: SourceLocation
    )

    case invalidExpression(
        Token
    )

    var description: String {
        switch self {
        case let .unexpectedToken(
            expected,
            actual,
            message
        ):
            if let message {
                return """
                Parse error at \
                \(actual.location.line):\(actual.location.column): \
                \(message). Expected \(expected), \
                got '\(actual.lexeme)'.
                """
            }

            return """
            Parse error at \
            \(actual.location.line):\(actual.location.column): \
            expected \(expected), \
            got '\(actual.lexeme)'.
            """

        case let .unexpectedEndOfFile(
            expected,
            location
        ):
            return """
            Parse error at \
            \(location.line):\(location.column): \
            unexpected end of file; expected \(expected).
            """

        case let .invalidExpression(token):
            return """
            Parse error at \
            \(token.location.line):\(token.location.column): \
            invalid expression beginning with '\(token.lexeme)'.
            """
        }
    }
}