import Foundation

enum Statement: ASTNode {
    case expression(Expression)
    case variable(VariableDeclaration)
    case returnStatement(ReturnStatement)
    case ifStatement(IfStatement)
    case whileStatement(WhileStatement)
    case forStatement(ForStatement)
    case breakStatement(SourceLocation)
    case continueStatement(SourceLocation)
    case switchStatement(SwitchStatement)

    var location: SourceLocation {
        switch self {
        case .expression(let expression):
            return expression.location

        case .variable(let declaration):
            return declaration.location

        case .returnStatement(let statement):
            return statement.location

        case .ifStatement(let statement):
            return statement.location

        case .whileStatement(let statement):
            return statement.location

        case .forStatement(let statement):
            return statement.location

        case .breakStatement(let location):
            return location

        case .continueStatement(let location):
            return location

        case .switchStatement(let statement):
            return statement.location
        }
    }
}

struct CodeBlock: ASTNode {
    let statements: [Statement]
    let location: SourceLocation
}

struct ReturnStatement: ASTNode {
    let value: Expression?
    let location: SourceLocation
}

struct IfStatement: ASTNode {
    let condition: Expression
    let body: CodeBlock
    let elseBody: ElseBody?
    let location: SourceLocation
}

enum ElseBody {
    case block(CodeBlock)
    case ifStatement(IfStatement)
}

struct WhileStatement: ASTNode {
    let condition: Expression
    let body: CodeBlock
    let location: SourceLocation
}

struct ForStatement: ASTNode {
    let pattern: Identifier
    let sequence: Expression
    let body: CodeBlock
    let location: SourceLocation
}

struct SwitchStatement: ASTNode {
    let expression: Expression
    let cases: [SwitchCase]
    let location: SourceLocation
}

struct SwitchCase: ASTNode {
    let expressions: [Expression]
    let statements: [Statement]
    let isDefault: Bool
    let location: SourceLocation
}