import Foundation

extension Parser {

    func parseType() throws -> TypeSyntax {

        let location = current.location

        var type = try parsePrimaryType()

        while true {

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

            if match(.logicalNot) {

                type = .optional(
                    type,
                    location
                )

                continue
            }

            break
        }

        return type
    }

    private func parsePrimaryType()
        throws -> TypeSyntax {

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