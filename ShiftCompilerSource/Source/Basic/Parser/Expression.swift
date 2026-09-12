import Foundation

indirect enum Expression: ASTNode {
    case identifier(Identifier)
    case integerLiteral(String, SourceLocation)
    case floatingLiteral(String, SourceLocation)
    case stringLiteral(String, SourceLocation)
    case characterLiteral(String, SourceLocation)
    case booleanLiteral(Bool, SourceLocation)

    case unary(
        UnaryOperator,
        Expression,
        SourceLocation
    )

    case binary(
        Expression,
        BinaryOperator,
        Expression,
        SourceLocation
    )

    case assignment(
        Expression,
        Expression,
        SourceLocation
    )

    case call(
        Expression,
        [CallArgument],
        SourceLocation
    )

    case member(
        Expression,
        Identifier,
        SourceLocation
    )

    case subscriptExpression(
        Expression,
        [Expression],
        SourceLocation
    )

    case arrayLiteral(
        [Expression],
        SourceLocation
    )

    case tuple(
        [Expression],
        SourceLocation
    )

    case parenthesized(
        Expression,
        SourceLocation
    )

    var location: SourceLocation {
        switch self {
        case .identifier(let value):
            return value.location

        case .integerLiteral(_, let location):
            return location

        case .floatingLiteral(_, let location):
            return location

        case .stringLiteral(_, let location):
            return location

        case .characterLiteral(_, let location):
            return location

        case .booleanLiteral(_, let location):
            return location

        case .unary(_, _, let location):
            return location

        case .binary(_, _, _, let location):
            return location

        case .assignment(_, _, let location):
            return location

        case .call(_, _, let location):
            return location

        case .member(_, _, let location):
            return location

        case .subscriptExpression(_, _, let location):
            return location

        case .arrayLiteral(_, let location):
            return location

        case .tuple(_, let location):
            return location

        case .parenthesized(_, let location):
            return location
        }
    }
}

enum UnaryOperator {
    case plus
    case minus
    case logicalNot
    case addressOf
    case dereference
}

enum BinaryOperator {
    case add
    case subtract
    case multiply
    case divide
    case remainder

    case equal
    case notEqual
    case less
    case lessEqual
    case greater
    case greaterEqual

    case logicalAnd
    case logicalOr

    case bitwiseAnd
    case bitwiseOr
    case bitwiseXor
}

struct CallArgument {
    let label: String?
    let expression: Expression
    let location: SourceLocation
}