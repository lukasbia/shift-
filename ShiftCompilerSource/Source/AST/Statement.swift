//
// Statements.swift
// Shift
//

public indirect enum Statement: ASTNode {

    case expression(Expression)

    case variable(VariableDeclaration)

    case returnStatement(Expression?)

    case ifStatement(
        condition: Expression,
        body: [Statement],
        elseBody: [Statement]?
    )

    case whileStatement(
        condition: Expression,
        body: [Statement]
    )

    case forInStatement(
        variable: String,
        sequence: Expression,
        body: [Statement]
    )

    case breakStatement(SourceLocation)

    case continueStatement(SourceLocation)

    case switchStatement(
        expression: Expression,
        cases: [SwitchCase]
    )

    public var location: SourceLocation {
        switch self {
        case .expression(let expression):
            return expression.location

        case .variable(let declaration):
            return declaration.location

        case .returnStatement(let expression):
            return expression?.location
                ?? SourceLocation(line: 0, column: 0)

        case .ifStatement(let condition, _, _):
            return condition.location

        case .whileStatement(let condition, _):
            return condition.location

        case .forInStatement(_, let sequence, _):
            return sequence.location

        case .breakStatement(let location):
            return location

        case .continueStatement(let location):
            return location

        case .switchStatement(let expression, _):
            return expression.location
        }
    }
}

public struct SwitchCase: ASTNode {

    public let patterns: [Expression]
    public let statements: [Statement]
    public let isDefault: Bool
    public let location: SourceLocation

    public init(
        patterns: [Expression],
        statements: [Statement],
        isDefault: Bool,
        location: SourceLocation
    ) {
        self.patterns = patterns
        self.statements = statements
        self.isDefault = isDefault
        self.location = location
    }
}
