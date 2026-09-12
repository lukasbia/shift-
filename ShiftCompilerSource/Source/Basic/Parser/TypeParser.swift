import Foundation

extension Parser {

    // MARK: - Entry Point

    func parseType() throws -> TypeSyntax {
        try parseTypePostfix()
    }

    // MARK: - Postfix Type

    private func parseTypePostfix() throws -> TypeSyntax {
        let location = current.location

        var type = try parsePrimaryType()

        while true {

            // Array type: T[]
            if match(.leftBracket) {

                try consume(
                    .rightBracket,
                    expected: "]"
                )

                type = .array(
                    type,
                    location
                )

                continue
            }

            /*
             Pointer type: T*

             This is parsed after the primary type so that:

                 Int*
                 Int[]*
                 (Int, Int)*

             remain structurally well-formed.
             */

            if match(.star) {
                type = .pointer(
                    type,
                    location
                )

                continue
            }

            /*
             The existing lexer/parser contract does not expose a
             dedicated '?' token. Therefore optional types are not
             guessed from an unrelated operator token here.
             */

            break
        }

        return type
    }

    // MARK: - Primary Type

    private func parsePrimaryType() throws -> TypeSyntax {
        let token = current

        switch token.kind {

        case .identifier:
            advance()

            return .named(
                Identifier(
                    name: token.lexeme,
                    location: token.location
                )
            )

        case .intKeyword,
             .uintKeyword,
             .int8Keyword,
             .int16Keyword,
             .int32Keyword,
             .int64Keyword,
             .uint8Keyword,
             .uint16Keyword,
             .uint32Keyword,
             .uint64Keyword,
             .floatKeyword,
             .doubleKeyword,
             .boolKeyword,
             .stringKeyword,
             .voidKeyword:

            advance()

            return .named(
                Identifier(
                    name: token.lexeme,
                    location: token.location
                )
            )

        case .leftParenthesis:
            return try parseTupleOrFunctionType()

        default:
            throw error(
                expected: "type"
            )
        }
    }

    // MARK: - Tuple / Function Types

    private func parseTupleOrFunctionType()
        throws -> TypeSyntax {

        let location = try consume(
            .leftParenthesis,
            expected: "("
        ).location

        var types: [TypeSyntax] = []

        if !check(.rightParenthesis) {

            repeat {
                types.append(
                    try parseType()
                )
            } while match(.comma)
        }

        try consume(
            .rightParenthesis,
            expected: ")"
        )

        if match(.arrow) {
            let returnType = try parseType()

            return .function(
                parameters: types,
                returnType: returnType,
                location
            )
        }

        return .tuple(
            types,
            location
        )
    }
}