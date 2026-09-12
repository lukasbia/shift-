import Foundation

extension Parser {

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
            return .breakStatement(token.location)

        case .continueKeyword:
            let token = advance()
            return .continueStatement(token.location)

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

    private func parseReturnStatement()
        throws -> ReturnStatement {

        let keyword = advance()

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

    private func parseIfStatement()
        throws -> IfStatement {

        let keyword = advance()

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

    private func parseWhileStatement()
        throws -> WhileStatement {

        let keyword = advance()

        let condition = try parseExpression()
        let body = try parseCodeBlock()

        return WhileStatement(
            condition: condition,
            body: body,
            location: keyword.location
        )
    }

    private func parseForStatement()
        throws -> ForStatement {

        let keyword = advance()

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

    private func parseSwitchStatement()
        throws -> SwitchStatement {

        let keyword = advance()

        let expression = try parseExpression()

        try consume(
            .leftBrace,
            expected: "{"
        )

        var cases: [SwitchCase] = []

        while !check(.rightBrace) && !isAtEnd {

            if match(.defaultKeyword) {

                try consume(
                    .colon,
                    expected: ":"
                )

                var statements: [Statement] = []

                while !check(.caseKeyword) &&
                      !check(.rightBrace) &&
                      !isAtEnd {

                    statements.append(
                        try parseStatement()
                    )
                }

                cases.append(
                    SwitchCase(
                        expressions: [],
                        statements: statements,
                        isDefault: true,
                        location: previous.location
                    )
                )

                continue
            }

            let caseToken = try consume(
                .caseKeyword,
                expected: "case"
            )

            var expressions: [Expression] = [
                try parseExpression()
            ]

            while match(.comma) {
                expressions.append(
                    try parseExpression()
                )
            }

            try consume(
                .colon,
                expected: ":"
            )

            var statements: [Statement] = []

            while !check(.caseKeyword) &&
                  !check(.defaultKeyword) &&
                  !check(.rightBrace) &&
                  !isAtEnd {

                statements.append(
                    try parseStatement()
                )
            }

            cases.append(
                SwitchCase(
                    expressions: expressions,
                    statements: statements,
                    isDefault: false,
                    location: caseToken.location
                )
            )
        }

        try consume(
            .rightBrace,
            expected: "}"
        )

        return SwitchStatement(
            expression: expression,
            cases: cases,
            location: keyword.location
        )
    }
}