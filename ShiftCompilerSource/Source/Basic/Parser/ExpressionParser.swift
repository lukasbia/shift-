import Foundation

extension Parser {

    // MARK: - Entry Point

    func parseExpression() throws -> Expression {
        try parseAssignment()
    }

    // MARK: - Assignment

    private func parseAssignment() throws -> Expression {
        let left = try parseLogicalOr()

        guard match(.equal) else {
            return left
        }

        let value = try parseAssignment()

        return .assignment(
            left,
            value,
            left.location
        )
    }

    // MARK: - Logical OR

    private func parseLogicalOr() throws -> Expression {
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

    // MARK: - Logical AND

    private func parseLogicalAnd() throws -> Expression {
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

    // MARK: - Bitwise OR

    private func parseBitwiseOr() throws -> Expression {
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

    // MARK: - Bitwise XOR

    private func parseBitwiseXor() throws -> Expression {
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

    // MARK: - Bitwise AND

    private func parseBitwiseAnd() throws -> Expression {
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

    // MARK: - Equality

    private func parseEquality() throws -> Expression {
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

                continue
            }

            if match(.notEqual) {
                let right = try parseComparison()

                expression = .binary(
                    expression,
                    .notEqual,
                    right,
                    expression.location
                )

                continue
            }

            break
        }

        return expression
    }

    // MARK: - Comparison

    private func parseComparison() throws -> Expression {
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

    // MARK: - Addition

    private func parseAddition() throws -> Expression {
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

                continue
            }

            if match(.minus) {
                let right = try parseMultiplication()

                expression = .binary(
                    expression,
                    .subtract,
                    right,
                    expression.location
                )

                continue
            }

            break
        }

        return expression
    }

    // MARK: - Multiplication

    private func parseMultiplication() throws -> Expression {
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

                continue
            }

            if match(.slash) {
                let right = try parseUnary()

                expression = .binary(
                    expression,
                    .divide,
                    right,
                    expression.location
                )

                continue
            }

            if match(.percent) {
                let right = try parseUnary()

                expression = .binary(
                    expression,
                    .remainder,
                    right,
                    expression.location
                )

                continue
            }

            break
        }

        return expression
    }

    // MARK: - Unary

    private func parseUnary() throws -> Expression {
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

    // MARK: - Postfix

    private func parsePostfix() throws -> Expression {
        var expression = try parsePrimary()

        while true {

            // Function call
            if match(.leftParenthesis) {
                expression = try finishCall(
                    callee: expression
                )
                continue
            }

            // Member access
            if match(.dot) {
                let member = try parseIdentifier()

                expression = .member(
                    expression,
                    member,
                    expression.location
                )

                continue
            }

            // Subscript
            if match(.leftBracket) {
                expression = try finishSubscript(
                    base: expression
                )
                continue
            }

            break
        }

        return expression
    }

    private func finishCall(
        callee: Expression
    ) throws -> Expression {

        var arguments: [CallArgument] = []

        if !check(.rightParenthesis) {

            repeat {
                arguments.append(
                    try parseCallArgument()
                )
            } while match(.comma)
        }

        try consume(
            .rightParenthesis,
            expected: ")"
        )

        return .call(
            callee,
            arguments,
            callee.location
        )
    }

    private func parseCallArgument() throws -> CallArgument {
        let location = current.location

        var label: String?

        /*
         label: expression
         */

        if check(.identifier) &&
           peekKind() == .colon {

            label = advance().lexeme

            try consume(
                .colon,
                expected: ":"
            )
        }

        let expression = try parseExpression()

        return CallArgument(
            label: label,
            expression: expression,
            location: location
        )
    }

    private func finishSubscript(
        base: Expression
    ) throws -> Expression {

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

        return .subscriptExpression(
            base,
            indices,
            base.location
        )
    }

    // MARK: - Primary

    private func parsePrimary() throws -> Expression {
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
            return try parseParenthesizedOrTupleExpression()

        case .leftBracket:
            return try parseArrayLiteral()

        default:
            throw ParserError.invalidExpression(
                token
            )
        }
    }

    // MARK: - Parenthesized / Tuple

    private func parseParenthesizedOrTupleExpression()
        throws -> Expression {

        let location = try consume(
            .leftParenthesis,
            expected: "("
        ).location

        if check(.rightParenthesis) {
            try consume(
                .rightParenthesis,
                expected: ")"
            )

            return .tuple(
                [],
                location
            )
        }

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

    // MARK: - Arrays

    private func parseArrayLiteral() throws -> Expression {
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
}