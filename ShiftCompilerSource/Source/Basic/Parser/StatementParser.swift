import Foundation

extension Parser {

    // MARK: - Blocks

    func parseCodeBlock() throws -> CodeBlock {
        let brace = try consume(
            .leftBrace,
            expected: "{"
        )

        var statements: [Statement] = []

        while !check(.rightBrace) && !isAtEnd {
            statements.append(
                try parseStatement()
            )
        }

        try consume(
            .rightBrace,
            expected: "}"
        )

        return CodeBlock(
            statements: statements,
            location: brace.location
        )
    }

    // MARK: - Statements

    func parseStatement() throws -> Statement {
        switch current.kind {

        case .letKeyword,
             .varKeyword:

            return .variable(
                try parseVariableDeclaration()
            )

        case .returnKeyword:

            return .returnStatement(
                try parseReturnStatement()
            )

        case .ifKeyword:

            return .ifStatement(
                try parseIfStatement()
            )

        case .whileKeyword:

            return .whileStatement(
                try parseWhileStatement()
            )

        case .forKeyword:

            return .forStatement(
                try parseForStatement()
            )

        case .breakKeyword:
            let token = advance()

            return .breakStatement(
                token.location
            )

        case .continueKeyword:
            let token = advance()

            return .continueStatement(
                token.location
            )

        case .switchKeyword:

            return .switchStatement(
                try parseSwitchStatement()
            )

        default:
            return .expression(
                try parseExpression()
            )
        }
    }

    // MARK: - Return

    private func parseReturnStatement() throws -> ReturnStatement {
        let keyword = try consume(
            .returnKeyword,
            expected: "return"
        )

        /*
         A return without an expression is legal when the next
         token closes the current block or the source ends.
         */

        if check(.rightBrace) || isAtEnd {
            return ReturnStatement(
                value: nil,
                location: keyword.location
            )
        }

        return ReturnStatement(
            value: try parseExpression(),
            location: keyword.location
        )
    }

    // MARK: - If

    private func parseIfStatement() throws -> IfStatement {
        let keyword = try consume(
            .ifKeyword,
            expected: "if"
        )

        let condition = try parseExpression()

        let body = try parseCodeBlock()

        var elseBody: ElseBody?

        if match(.elseKeyword) {

            if check(.ifKeyword) {
                elseBody = .ifStatement(
                    try parseIfStatement()
                )
            } else {
                elseBody = .block(
                    try parseCodeBlock()
                )
            }
        }

        return IfStatement(
            condition: condition,
            body: body,
            elseBody: elseBody,
            location: keyword.location
        )
    }

    // MARK: - While

    private func parseWhileStatement() throws -> WhileStatement {
        let keyword = try consume(
            .whileKeyword,
            expected: "while"
        )

        let condition = try parseExpression()

        let body = try parseCodeBlock()

        return WhileStatement(
            condition: condition,
            body: body,
            location: keyword.location
        )
    }

    // MARK: - For

    private func parseForStatement() throws -> ForStatement {
        let keyword = try consume(
            .forKeyword,
            expected: "for"
        )

        let pattern = try parseIdentifier()

        try consume(
            .inKeyword,
            expected: "in"
        )

        let sequence = try parseExpression()

        let body = try parseCodeBlock()

        return ForStatement(
            pattern: pattern,
            sequence: sequence,
            body: body,
            location: keyword.location
        )
    }

    // MARK: - Switch

    private func parseSwitchStatement() throws -> SwitchStatement {
        let keyword = try consume(
            .switchKeyword,
            expected: "switch"
        )

        let expression = try parseExpression()

        try consume(
            .leftBrace,
            expected: "{"
        )

        var cases: [SwitchCase] = []

        while !check(.rightBrace) && !isAtEnd {

            if check(.defaultKeyword) {
                cases.append(
                    try parseDefaultSwitchCase()
                )
            } else {
                cases.append(
                    try parseSwitchCase()
                )
            }
        }

        try consume(
            .rightBrace,
            expected: "}"
        )

        guard !cases.isEmpty else {
            throw error(
                expected: "case or default",
                message: "switch statements must contain at least one case"
            )
        }

        return SwitchStatement(
            expression: expression,
            cases: cases,
            location: keyword.location
        )
    }

    private func parseSwitchCase() throws -> SwitchCase {
        let caseToken = try consume(
            .caseKeyword,
            expected: "case"
        )

        var expressions: [Expression] = []

        expressions.append(
            try parseExpression()
        )

        while match(.comma) {
            expressions.append(
                try parseExpression()
            )
        }

        try consume(
            .colon,
            expected: ":"
        )

        let statements = try parseSwitchCaseStatements()

        return SwitchCase(
            expressions: expressions,
            statements: statements,
            isDefault: false,
            location: caseToken.location
        )
    }

    private func parseDefaultSwitchCase() throws -> SwitchCase {
        let defaultToken = try consume(
            .defaultKeyword,
            expected: "default"
        )

        try consume(
            .colon,
            expected: ":"
        )

        let statements = try parseSwitchCaseStatements()

        return SwitchCase(
            expressions: [],
            statements: statements,
            isDefault: true,
            location: defaultToken.location
        )
    }

    private func parseSwitchCaseStatements() throws -> [Statement] {
        var statements: [Statement] = []

        while !check(.caseKeyword) &&
              !check(.defaultKeyword) &&
              !check(.rightBrace) &&
              !isAtEnd {

            statements.append(
                try parseStatement()
            )
        }

        return statements
    }
}