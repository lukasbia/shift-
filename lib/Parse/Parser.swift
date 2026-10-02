public final class Parser {
    private let tokens: [Token]
    private var index = 0
    private var functionCallingNames: Set<String> = []
    private var insideStruct = false
    public private(set) var errors: [ParserError] = []

    public init(tokens: [Token]) { self.tokens = tokens }

    public func parse() -> Program? {
        guard !tokens.isEmpty else { return nil }
        var declarations: [Declaration] = []
        while !isAtEnd {
            do { declarations.append(try parseDeclaration()) }
            catch let error as ParserError { errors.append(error); recoverDeclaration() }
            catch { recoverDeclaration() }
        }
        return Program(
            declarations: declarations,
            range: SourceRange(start: tokens[0].location, end: previous.location)
        )
    }

    private func parseDeclaration() throws -> Declaration {
        switch current.kind {
        case .funcKeyword: return .function(try parseFunction())
        case .structKeyword: return .structure(try parseStruct())
        case .varKeyword: return .variable(try parseVariable())
        case .letKeyword: return .constant(try parseConstant())
        default: return .expression(try parseExpression())
        }
    }

    private func parseFunction() throws -> FunctionDeclaration {
        let start = current.location
        try expect(.funcKeyword, "expected 'func'")
        let name = try parseIdentifier("expected function name")
        try expect(.leftParenthesis, "expected '(' after function name")
        let callingName = try parseIdentifier("expected function calling name inside parentheses")
        try expect(.rightParenthesis, "expected ')' after function calling name")
        if functionCallingNames.contains(callingName.name) {
            throw ParserError(
                kind: .duplicateFunctionCallingName,
                message: "function calling name '\(callingName.name)' is already used in this file",
                location: callingName.range.start
            )
        }
        functionCallingNames.insert(callingName.name)
        let body = try parseStatementBlock()
        return FunctionDeclaration(name: name, callingName: callingName, body: body,
            range: SourceRange(start: start, end: previous.location))
    }

    private func parseStruct() throws -> StructDeclaration {
        let start = current.location
        try expect(.structKeyword, "expected 'struct'")
        let name = try parseIdentifier("expected struct name")
        try expect(.leftBrace, "expected '{' after struct name")
        if insideStruct {
            throw ParserError(kind: .nestedStruct,
                message: "struct declarations cannot be nested inside another struct",
                location: name.range.start)
        }
        insideStruct = true
        defer { insideStruct = false }
        var variables: [VariableDeclaration] = []
        var constants: [ConstantDeclaration] = []
        while !check(.rightBrace) && !isAtEnd {
            switch current.kind {
            case .varKeyword: variables.append(try parseVariable())
            case .letKeyword: constants.append(try parseConstant())
            case .structKeyword:
                throw ParserError(kind: .nestedStruct,
                    message: "struct declarations cannot be nested inside another struct",
                    location: current.location)
            default:
                throw ParserError(kind: .invalidStructMember,
                    message: "only var and let declarations are allowed directly inside a struct",
                    location: current.location)
            }
        }
        try expect(.rightBrace, "expected '}' at end of struct")
        return StructDeclaration(name: name, variables: variables, constants: constants,
            range: SourceRange(start: start, end: previous.location))
    }

    private func parseVariable() throws -> VariableDeclaration {
        let start = current.location
        try expect(.varKeyword, "expected 'var'")
        let name = try parseIdentifier("expected variable name")
        let typeName = try parseOptionalType()
        let initializer = try parseOptionalInitializer()
        return VariableDeclaration(name: name, typeName: typeName, initializer: initializer,
            range: SourceRange(start: start, end: previous.location))
    }

    private func parseConstant() throws -> ConstantDeclaration {
        let start = current.location
        try expect(.letKeyword, "expected 'let'")
        let name = try parseIdentifier("expected constant name")
        let typeName = try parseOptionalType()
        let initializer = try parseOptionalInitializer()
        return ConstantDeclaration(name: name, typeName: typeName, initializer: initializer,
            range: SourceRange(start: start, end: previous.location))
    }

    private func parseOptionalType() throws -> Identifier? {
        guard match(.colon) else { return nil }
        return try parseIdentifier("expected type name after ':'")
    }

    private func parseOptionalInitializer() throws -> Expression? {
        guard match(.equal) else { return nil }
        return try parseExpression()
    }

    private func parseStatementBlock() throws -> [Statement] {
        try expect(.leftBrace, "expected '{'")
        var statements: [Statement] = []
        while !check(.rightBrace) && !isAtEnd {
            statements.append(try parseStatement())
        }
        try expect(.rightBrace, "expected '}'")
        return statements
    }

    private func parseStatement() throws -> Statement {
        switch current.kind {
        case .varKeyword: return .variable(try parseVariable())
        case .letKeyword: return .constant(try parseConstant())
        case .returnKeyword:
            advance()
            if check(.rightBrace) { return .returnStatement(nil) }
            return .returnStatement(try parseExpression())
        case .ifKeyword: return .ifStatement(try parseIf())
        case .whileKeyword: return .whileStatement(try parseWhile())
        case .breakKeyword:
            let location = current.location
            advance()
            return .breakStatement(SourceRange(start: location, end: previous.location))
        case .continueKeyword:
            let location = current.location
            advance()
            return .continueStatement(SourceRange(start: location, end: previous.location))
        default: return .expression(try parseExpression())
        }
    }

    private func parseIf() throws -> IfStatement {
        let start = current.location
        try expect(.ifKeyword, "expected 'if'")
        let condition = try parseExpression()
        let body = try parseStatementBlock()
        var elseBody: [Statement]?
        if match(.elseKeyword) { elseBody = try parseStatementBlock() }
        return IfStatement(condition: condition, body: body, elseBody: elseBody,
            range: SourceRange(start: start, end: previous.location))
    }

    private func parseWhile() throws -> WhileStatement {
        let start = current.location
        try expect(.whileKeyword, "expected 'while'")
        let condition = try parseExpression()
        let body = try parseStatementBlock()
        return WhileStatement(condition: condition, body: body,
            range: SourceRange(start: start, end: previous.location))
    }

    private func parseExpression() throws -> Expression { try parseAssignment() }

    private func parseAssignment() throws -> Expression {
        let left = try parseBinaryExpression(minimumPrecedence: 0)
        guard match(.equal) else { return left }
        let right = try parseAssignment()
        return .assignment(left, right, SourceRange(start: left.range.start, end: right.range.end))
    }

    private func parseBinaryExpression(minimumPrecedence: Int) throws -> Expression {
        var expression = try parsePostfix()
        while let precedence = binaryPrecedence(current.kind), precedence >= minimumPrecedence {
            let operatorKind = current.kind
            advance()
            let right = try parseBinaryExpression(minimumPrecedence: precedence + 1)
            expression = .binary(expression, operatorKind, right,
                SourceRange(start: expression.range.start, end: right.range.end))
        }
        return expression
    }

    private func parsePostfix() throws -> Expression {
        var expression = try parsePrimary()
        while true {
            if match(.dot) {
                let member = try parseIdentifier("expected member name after '.'")
                expression = .member(expression, member,
                    SourceRange(start: expression.range.start, end: member.range.end))
                continue
            }
            if match(.leftParenthesis) {
                var arguments: [Expression] = []
                if !check(.rightParenthesis) {
                    repeat { arguments.append(try parseExpression()) } while match(.comma)
                }
                try expect(.rightParenthesis, "expected ')' after arguments")
                expression = .call(expression, arguments,
                    SourceRange(start: expression.range.start, end: previous.location))
                continue
            }
            break
        }
        return expression
    }

    private func parsePrimary() throws -> Expression {
        let token = current
        switch token.kind {
        case .identifier:
            advance()
            return .identifier(Identifier(name: token.lexeme,
                range: SourceRange(start: token.location, end: token.location)))
        case .integerLiteral:
            advance()
            return .integer(token.lexeme, SourceRange(start: token.location, end: token.location))
        case .floatingLiteral:
            advance()
            return .floating(token.lexeme, SourceRange(start: token.location, end: token.location))
        case .stringLiteral:
            advance()
            return .string(token.lexeme, SourceRange(start: token.location, end: token.location))
        case .characterLiteral:
            advance()
            return .character(token.lexeme, SourceRange(start: token.location, end: token.location))
        case .booleanLiteral:
            advance()
            return .boolean(token.lexeme == "true",
                SourceRange(start: token.location, end: token.location))
        case .leftParenthesis:
            advance()
            let value = try parseExpression()
            try expect(.rightParenthesis, "expected ')' after expression")
            return value
        case .minus, .plus, .logicalNot:
            advance()
            let value = try parsePrimary()
            return .unary(token.kind, value,
                SourceRange(start: token.location, end: value.range.end))
        default:
            throw ParserError(kind: .unexpectedToken,
                message: "unexpected token '\(token.lexeme)'",
                location: token.location)
        }
    }

    private func parseIdentifier(_ message: String) throws -> Identifier {
        guard current.kind == .identifier else {
            throw ParserError(kind: .expectedIdentifier, message: message, location: current.location)
        }
        let token = current
        advance()
        return Identifier(name: token.lexeme,
            range: SourceRange(start: token.location, end: token.location))
    }

    private func binaryPrecedence(_ kind: Token.Kind) -> Int? {
        switch kind {
        case .logicalOr: return 1
        case .logicalAnd: return 2
        case .equalEqual, .notEqual: return 3
        case .less, .lessEqual, .greater, .greaterEqual: return 4
        case .plus, .minus: return 5
        case .star, .slash, .percent: return 6
        default: return nil
        }
    }

    private func expect(_ kind: Token.Kind, _ message: String) throws {
        guard check(kind) else {
            throw ParserError(kind: .expectedToken, message: message, location: current.location)
        }
        advance()
    }

    @discardableResult
    private func match(_ kind: Token.Kind) -> Bool {
        guard check(kind) else { return false }
        advance()
        return true
    }

    private func check(_ kind: Token.Kind) -> Bool { current.kind == kind }

    private func advance() {
        if !isAtEnd { index += 1 }
    }

    private func recoverDeclaration() {
        while !isAtEnd {
            if current.kind == .funcKeyword || current.kind == .structKeyword ||
               current.kind == .varKeyword || current.kind == .letKeyword { return }
            advance()
        }
    }

    private var current: Token { tokens[min(index, tokens.count - 1)] }
    private var previous: Token { tokens[max(0, index - 1)] }
    private var isAtEnd: Bool { current.kind == .endOfFile }
}