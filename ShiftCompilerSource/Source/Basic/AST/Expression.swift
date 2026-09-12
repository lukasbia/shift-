//
// Expressions.swift
// Shift
//

public indirect enum Expression: ASTNode {

    case identifier(
        name: String,
        location: SourceLocation
    )

    case integerLiteral(
        value: Int64,
        location: SourceLocation
    )

    case floatingLiteral(
        value: Double,
        location: SourceLocation
    )

    case stringLiteral(
        value: String,
        location: SourceLocation
    )

    case characterLiteral(
        value: Character,
        location: SourceLocation
    )

    case booleanLiteral(
        value: Bool,
        location: SourceLocation
    )

    case unary(
        operator: UnaryOperator,
        operand: Expression,
        location: SourceLocation
    )

    case binary(
        left: Expression,
        operator: BinaryOperator,
        right: Expression,
        location: SourceLocation
    )

    case assignment(
        target: Expression,
        value: Expression,
        location: SourceLocation
    )

    case call(
        callee: Expression,
        arguments: [CallArgument],
        location: SourceLocation
    )

    case member(
        base: Expression,
        name: String,
        location: SourceLocation
    )

    case subscriptExpression(
        base: Expression,
        index: Expression,
        location: SourceLocation
    )

    case arrayLiteral(
        elements: [Expression],
        location: SourceLocation
    )

    case tuple(
        elements: [Expression],
        location: SourceLocation
    )

    case parenthesized(
        expression: Expression,
        location: SourceLocation
    )

    public var location: SourceLocation {
        switch self {
        case .identifier(_, let location),
             .integerLiteral(_, let location),
             .floatingLiteral(_, let location),
             .stringLiteral(_, let location),
             .characterLiteral(_, let location),
             .booleanLiteral(_, let location),
             .unary(_, _, let location),
             .binary(_, _, _, let location),
             .assignment(_, _, let location),
             .call(_, _, let location),
             .member(_, _, let location),
             .subscriptExpression(_, _, let location),
             .arrayLiteral(_, let location),
             .tuple(_, let location),
             .parenthesized(_, let location):
            return location
        }
    }
}

public struct CallArgument: ASTNode {

    public let label: String?
    public let value: Expression
    public let location: SourceLocation

    public init(
        label: String?,
        value: Expression,
        location: SourceLocation
    ) {
        self.label = label
        self.value = value
        self.location = location
    }
}

public enum UnaryOperator: Equatable, Hashable {
    case plus
    case minus
    case logicalNot
    case bitwiseNot
    case addressOf
    case dereference
}

public enum BinaryOperator: Equatable, Hashable {
    case logicalOr
    case logicalAnd

    case bitwiseOr
    case bitwiseXor
    case bitwiseAnd

    case equal
    case notEqual

    case less
    case lessOrEqual
    case greater
    case greaterOrEqual

    case addition
    case subtraction
    case multiplication
    case division
    case remainder
}