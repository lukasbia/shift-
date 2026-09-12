import Foundation

extension Parser {

    func parseExpression() throws -> Expression {
        try parseAssignment()
    }

    private func parseAssignment()
        throws -> Expression {

        let left = try parseLogicalOr()

        if match(.equal) {
            let value = try parseAssignment()

            return .assignment(
                left,
                value,
                left.location
            )
        }

        return left
    }

    private func parseLogicalOr()
        throws -> Expression {

        var expression = try parseLogicalAnd()

        while match(.logicalOr) {
            let right = try parseLogicalAnd()

            expression = .binary(
                expression,
                .logicalOr,
                right,
                expression.location
            )
        }

        return expression
    }

    private func parseLogicalAnd()
        throws -> Expression {

        var expression = try parseBitwiseOr()

        while match(.logicalAnd) {
            let right = try parseBitwiseOr()

            expression = .binary(
                expression,
                .logicalAnd,
                right,
                expression.location
            )
        }

        return expression
    }

    private func parseBitwiseOr()
        throws -> Expression {

        var expression = try parseBitwiseXor()

        while match(.pipe) {
            let right = try parseBitwiseXor()

            expression = .binary(
                expression,
                .bitwiseOr,
                right,
                expression.location
            )
        }

        return expression
    }

    private func parseBitwiseXor()
        throws -> Expression {

        var expression = try parseBitwiseAnd()

        while match(.caret) {
            let right = try parseBitwiseAnd()

            expression = .binary(
                expression,
                .bitwiseXor,
                right,
                expression.location
            )
        }

        return expression
    }

    private func parseBitwiseAnd()
        throws -> Expression {

        var expression = try parseEquality()

        while match(.ampersand) {
            let right = try parseEquality()

            expression = .binary(
                expression,
                .bitwiseAnd,
                right,
                expression.location
            )
        }

        return expression
    }

    private func parseEquality()
        throws -> Expression {

        var expression = try parseComparison()

        while true {

            if match(.equalEqual) {
                let right = try parseComparison()

                expression = .binary(
                    expression,
                    .equal,
                    right,
                    expression.location
                )

            } else if match(.notEqual) {
                let right = try parseComparison()

                expression = .binary(
                    expression,
                    .notEqual,
                    right,
                    expression.location
                )

            } else {
                break
            }
        }

        return expression
    }

    private func parseComparison()
        throws -> Expression {

        var expression = try parseAddition()

        while true {

            let operation: BinaryOperator?

            switch current.kind {

            case .less:
                operation = .less

            case .lessEqual:
                operation = .lessEqual

            case .greater:
                operation = .greater

            case .greaterEqual:
                operation = .greaterEqual

            default:
                operation = nil
            }

            guard let operation else {
                break
            }

            advance()

            let right = try parseAddition()

            expression = .binary(
                expression,
                operation,
                right,
                expression.location
            )
        }

        return expression
    }

    private func parseAddition()
        throws -> Expression {

        var expression = try parseMultiplication()

        while true {

            if match(.plus) {

                let right = try parseMultiplication()

                expression = .binary(
                    expression,
                    .add,
                    right,
                    expression.location
                )

            } else if match(.minus) {

                let right = try parseMultiplication()

                expression = .binary(
                    expression,
                    .subtract,
                    right,
                    expression.location
                )

            } else {
                break
            }
        }

        return expression
    }

    private func parseMultiplication()
        throws -> Expression {

        var expression = try parseUnary()

        while true {

            if match(.star) {

                let right = try parseUnary()

                expression = .binary(
                    expression,
                    .multiply,
                    right,
                    expression.location
                )

            } else if match(.slash) {

                let right = try parseUnary()

                expression = .binary(
                    expression,
                    .divide,
                    right,
                    expression.location
                )

            } else if match(.percent) {

                let right = try parseUnary()

                expression = .binary(
                    expression,
                    .remainder,
                    right,
                    expression.location
                )

            } else {
                break
            }
        }

        return expression
    }

    private func parseUnary()
        throws -> Expression {

        let location = current.location

        if match(.plus) {
            return .unary(
                .plus,
                try parseUnary(),
                location
            )
        }

        if match(.minus) {
            return .unary(
                .minus,
                try parseUnary(),
                location
            )
        }

        if match(.logicalNot) {
            return .unary(
                .logicalNot,
                try parseUnary(),
                location
            )
        }

        if match(.ampersand) {
            return .unary(
                .addressOf,
                try parseUnary(),
                location
            )
        }

        if match(.star) {
            return .unary(
                .dereference,
                try parseUnary(),
                location
            )
        }

        return try parsePostfix()
    }

    private func parsePostfix()
        throws -> Expression {

        var expression = try parsePrimary()

        while true {

            if match(.leftParenthesis) {

                var arguments: [CallArgument] = []

                if !check(.rightParenthesis) {

                    repeat {

                        let argumentLocation =
                            current.location

                        var label: String?

                        if check(.identifier) &&
                           peekNextKind() == .colon {

                            label = advance().lexeme

                            _ = try consume(
                                .colon,
                                expected: ":"
                            )
                        }

                        let argument =
                            try parseExpression()

                        arguments.append(
                            CallArgument(
                                label: label,
                                expression: argument,
                                location: argumentLocation
                            )
                        )

                    } while match(.comma)
                }

                try consume(
                    .rightParenthesis,
                    expected: ")"
                )

                expression = .call(
                    expression,
                    arguments,
                    expression.location
                )

                continue
            }

            if match(.dot) {

                let member = try parseIdentifier()

                expression = .member(
                    expression,
                    member,
                    expression.location
                )

                continue
            }

            if match(.leftBracket) {

                var indices: [Expression] = []

                if !check(.rightBracket) {
                    repeat {
                        indices.append(
                            try parseExpression()
                        )
                    } while match(.comma)
                }

                try consume(
                    .rightBracket,
                    expected: "]"
                )

                expression = .subscriptExpression(
                    expression,
                    indices,
                    expression.location
                )

                continue
            }

            break
        }

        return expression
    }

    private func parsePrimary()
        throws -> Expression {

        let token = current

        switch token.kind {

        case .identifier:
            advance()

            return .identifier(
                Identifier(
                    name: token.lexeme,
                    location: token.location
                )
            )

        case .integerLiteral:
            advance()

            return .integerLiteral(
                token.lexeme,
                token.location
            )

        case .floatingLiteral:
            advance()

            return .floatingLiteral(
                token.lexeme,
                token.location
            )

        case .stringLiteral:
            advance()

            return .stringLiteral(
                token.lexeme,
                token.location
            )

        case .characterLiteral:
            advance()

            return .characterLiteral(
                token.lexeme,
                token.location
            )

        case .booleanLiteral:
            advance()

            return .booleanLiteral(
                token.lexeme == "true",
                token.location
            )

        case .leftParenthesis:
            return try parseParenthesizedExpression()

        case .leftBracket:
            return try parseArrayLiteral()

        default:
            throw ParserError.invalidExpression(token)
        }
    }

    private func parseParenthesizedExpression()
        throws -> Expression {

        let location = try consume(
            .leftParenthesis,
            expected: "("
        ).location

        var expressions: [Expression] = []

        if !check(.rightParenthesis) {

            repeat {
                expressions.append(
                    try parseExpression()
                )
            } while match(.comma)
        }

        try consume(
            .rightParenthesis,
            expected: ")"
        )

        if expressions.count == 1 {
            return .parenthesized(
                expressions[0],
                location
            )
        }

        return .tuple(
            expressions,
            location
        )
    }

    private func parseArrayLiteral()
        throws -> Expression {

        let location = try consume(
            .leftBracket,
            expected: "["
        ).location

        var elements: [Expression] = []

        if !check(.rightBracket) {

            repeat {
                elements.append(
                    try parseExpression()
                )
            } while match(.comma)
        }

        try consume(
            .rightBracket,
            expected: "]"
        )

        return .arrayLiteral(
            elements,
            location
        )
    }

    private func peekNextKind() -> TokenKind {

        let next = index + 1

        guard next < tokens.count else {
            return .endOfFile
        }

        return tokens[next].kind
    }
}