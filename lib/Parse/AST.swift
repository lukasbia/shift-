public struct SourceRange: Equatable, Sendable {
    public let start: SourceLocation
    public let end: SourceLocation
    public init(start: SourceLocation, end: SourceLocation) {
        self.start = start
        self.end = end
    }
}
public protocol ASTNode: Sendable { var range: SourceRange { get } }
public struct Identifier: ASTNode, Hashable, Sendable {
    public let name: String
    public let range: SourceRange
}
public struct Program: ASTNode, Sendable {
    public let declarations: [Declaration]
    public let range: SourceRange
}
public enum Declaration: ASTNode, Sendable {
    case function(FunctionDeclaration)
    case structure(StructDeclaration)
    case variable(VariableDeclaration)
    case constant(ConstantDeclaration)
    case expression(Expression)
    public var range: SourceRange {
        switch self {
        case .function(let v): return v.range
        case .structure(let v): return v.range
        case .variable(let v): return v.range
        case .constant(let v): return v.range
        case .expression(let v): return v.range
        }
    }
}
public struct FunctionDeclaration: ASTNode, Sendable {
    public let name: Identifier
    public let callingName: Identifier
    public let body: [Statement]
    public let range: SourceRange
}
public struct StructDeclaration: ASTNode, Sendable {
    public let name: Identifier
    public let variables: [VariableDeclaration]
    public let constants: [ConstantDeclaration]
    public let range: SourceRange
}
public struct VariableDeclaration: ASTNode, Sendable {
    public let name: Identifier
    public let typeName: Identifier?
    public let initializer: Expression?
    public let range: SourceRange
}
public struct ConstantDeclaration: ASTNode, Sendable {
    public let name: Identifier
    public let typeName: Identifier?
    public let initializer: Expression?
    public let range: SourceRange
}
public enum Statement: ASTNode, Sendable {
    case variable(VariableDeclaration)
    case constant(ConstantDeclaration)
    case expression(Expression)
    case returnStatement(Expression?)
    case ifStatement(IfStatement)
    case whileStatement(WhileStatement)
    case breakStatement(SourceRange)
    case continueStatement(SourceRange)
    public var range: SourceRange {
        switch self {
        case .variable(let v): return v.range
        case .constant(let v): return v.range
        case .expression(let v): return v.range
        case .returnStatement(let v):
            return v?.range ?? SourceRange(start: SourceLocation(line: 0, column: 0), end: SourceLocation(line: 0, column: 0))
        case .ifStatement(let v): return v.range
        case .whileStatement(let v): return v.range
        case .breakStatement(let v): return v
        case .continueStatement(let v): return v
        }
    }
}
public struct IfStatement: ASTNode, Sendable {
    public let condition: Expression
    public let body: [Statement]
    public let elseBody: [Statement]?
    public let range: SourceRange
}
public struct WhileStatement: ASTNode, Sendable {
    public let condition: Expression
    public let body: [Statement]
    public let range: SourceRange
}
public indirect enum Expression: ASTNode, Sendable {
    case identifier(Identifier)
    case integer(String, SourceRange)
    case floating(String, SourceRange)
    case string(String, SourceRange)
    case character(String, SourceRange)
    case boolean(Bool, SourceRange)
    case member(Expression, Identifier, SourceRange)
    case call(Expression, [Expression], SourceRange)
    case assignment(Expression, Expression, SourceRange)
    case binary(Expression, Token.Kind, Expression, SourceRange)
    case unary(Token.Kind, Expression, SourceRange)
    public var range: SourceRange {
        switch self {
        case .identifier(let v): return v.range
        case .integer(_, let v): return v
        case .floating(_, let v): return v
        case .string(_, let v): return v
        case .character(_, let v): return v
        case .boolean(_, let v): return v
        case .member(_, _, let v): return v
        case .call(_, _, let v): return v
        case .assignment(_, _, let v): return v
        case .binary(_, _, _, let v): return v
        case .unary(_, _, let v): return v
        }
    }
}