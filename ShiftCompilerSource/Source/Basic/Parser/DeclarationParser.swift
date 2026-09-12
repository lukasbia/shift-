import Foundation

extension Parser {

    // MARK: - Variables

    func parseVariableDeclaration() throws -> VariableDeclaration {
        let keyword = advance()

        let mutable: Bool

        switch keyword.kind {
        case .letKeyword:
            mutable = false

        case .varKeyword:
            mutable = true

        default:
            throw error(
                expected: "let or var"
            )
        }

        let name = try parseIdentifier()

        var type: TypeSyntax?

        if match(.colon) {
            type = try parseType()
        }

        var initializer: Expression?

        if match(.equal) {
            initializer = try parseExpression()
        }

        guard type != nil || initializer != nil else {
            throw error(
                expected: "type annotation or initializer",
                message: "a variable declaration requires a type, an initializer, or both"
            )
        }

        return VariableDeclaration(
            isMutable: mutable,
            name: name,
            type: type,
            initializer: initializer,
            location: keyword.location
        )
    }

    // MARK: - Functions

    func parseFunctionDeclaration(
        modifiers: [DeclarationModifier]
    ) throws -> FunctionDeclaration {

        let keyword = try consume(
            .funcKeyword,
            expected: "func"
        )

        let name = try parseIdentifier()

        try consume(
            .leftParenthesis,
            expected: "("
        )

        var parameters: [FunctionParameter] = []

        if !check(.rightParenthesis) {
            repeat {
                parameters.append(
                    try parseFunctionParameter()
                )
            } while match(.comma)
        }

        try consume(
            .rightParenthesis,
            expected: ")"
        )

        var returnType: TypeSyntax?

        if match(.arrow) {
            returnType = try parseType()
        }

        let body = try parseCodeBlock()

        return FunctionDeclaration(
            name: name,
            parameters: parameters,
            returnType: returnType,
            body: body,
            modifiers: modifiers,
            location: keyword.location
        )
    }

    private func parseFunctionParameter() throws -> FunctionParameter {
        let start = current.location

        var externalLabel: String?
        let name: Identifier

        /*
         Supported forms:

             value: Int
             label value: Int

         The parser intentionally does not invent a wildcard `_`
         parameter because the current lexer/AST do not expose a
         wildcard identifier node.
         */

        let first = try parseIdentifier()

        if check(.identifier) {
            externalLabel = first.name
            name = try parseIdentifier()
        } else {
            name = first
        }

        try consume(
            .colon,
            expected: ":"
        )

        let type = try parseType()

        return FunctionParameter(
            externalLabel: externalLabel,
            name: name,
            type: type,
            location: start
        )
    }

    // MARK: - Structs

    func parseStructDeclaration(
        modifiers: [DeclarationModifier]
    ) throws -> StructDeclaration {

        let keyword = try consume(
            .structKeyword,
            expected: "struct"
        )

        let name = try parseIdentifier()

        try consume(
            .leftBrace,
            expected: "{"
        )

        let members = try parseDeclarationMembers()

        try consume(
            .rightBrace,
            expected: "}"
        )

        return StructDeclaration(
            name: name,
            members: members,
            location: keyword.location
        )
    }

    // MARK: - Classes

    func parseClassDeclaration(
        modifiers: [DeclarationModifier]
    ) throws -> ClassDeclaration {

        let keyword = try consume(
            .classKeyword,
            expected: "class"
        )

        let name = try parseIdentifier()

        try consume(
            .leftBrace,
            expected: "{"
        )

        let members = try parseDeclarationMembers()

        try consume(
            .rightBrace,
            expected: "}"
        )

        return ClassDeclaration(
            name: name,
            members: members,
            location: keyword.location
        )
    }

    // MARK: - Enums

    func parseEnumDeclaration(
        modifiers: [DeclarationModifier]
    ) throws -> EnumDeclaration {

        let keyword = try consume(
            .enumKeyword,
            expected: "enum"
        )

        let name = try parseIdentifier()

        try consume(
            .leftBrace,
            expected: "{"
        )

        var cases: [EnumCase] = []

        while !check(.rightBrace) && !isAtEnd {

            try consume(
                .caseKeyword,
                expected: "case"
            )

            repeat {
                cases.append(
                    try parseEnumCase()
                )
            } while match(.comma)
        }

        try consume(
            .rightBrace,
            expected: "}"
        )

        return EnumDeclaration(
            name: name,
            cases: cases,
            location: keyword.location
        )
    }

    private func parseEnumCase() throws -> EnumCase {
        let name = try parseIdentifier()

        var associatedValues: [TypeSyntax] = []

        if match(.leftParenthesis) {

            if !check(.rightParenthesis) {
                repeat {
                    associatedValues.append(
                        try parseType()
                    )
                } while match(.comma)
            }

            try consume(
                .rightParenthesis,
                expected: ")"
            )
        }

        return EnumCase(
            name: name,
            associatedValues: associatedValues,
            location: name.location
        )
    }

    // MARK: - Protocols

    func parseProtocolDeclaration(
        modifiers: [DeclarationModifier]
    ) throws -> ProtocolDeclaration {

        let keyword = try consume(
            .protocolKeyword,
            expected: "protocol"
        )

        let name = try parseIdentifier()

        try consume(
            .leftBrace,
            expected: "{"
        )

        let members = try parseDeclarationMembers()

        try consume(
            .rightBrace,
            expected: "}"
        )

        return ProtocolDeclaration(
            name: name,
            members: members,
            location: keyword.location
        )
    }

    // MARK: - Extensions

    func parseExtensionDeclaration() throws -> ExtensionDeclaration {
        let keyword = try consume(
            .extensionKeyword,
            expected: "extension"
        )

        let type = try parseType()

        try consume(
            .leftBrace,
            expected: "{"
        )

        let members = try parseDeclarationMembers()

        try consume(
            .rightBrace,
            expected: "}"
        )

        return ExtensionDeclaration(
            extendedType: type,
            members: members,
            location: keyword.location
        )
    }

    // MARK: - Declaration Members

    private func parseDeclarationMembers() throws -> [Declaration] {
        var members: [Declaration] = []

        while !check(.rightBrace) && !isAtEnd {
            members.append(
                try parseDeclaration()
            )
        }

        if isAtEnd {
            throw ParserError.unexpectedEndOfFile(
                expected: "}",
                location: current.location
            )
        }

        return members
    }
}