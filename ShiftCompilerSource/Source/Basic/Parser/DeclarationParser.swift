import Foundation

extension Parser {

    func parseVariableDeclaration()
        throws -> VariableDeclaration {

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
                message: "a variable must have a type or initializer"
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

    private func parseFunctionParameter()
        throws -> FunctionParameter {

        let start = current.location

        var externalLabel: String?

        if check(.identifier) {
            let first = try parseIdentifier()

            if check(.identifier) {
                externalLabel = first.name
            } else {
                return FunctionParameter(
                    externalLabel: nil,
                    name: first,
                    type: try parseParameterType(),
                    location: start
                )
            }
        }

        let name = try parseIdentifier()

        return FunctionParameter(
            externalLabel: externalLabel,
            name: name,
            type: try parseParameterType(),
            location: start
        )
    }

    private func parseParameterType()
        throws -> TypeSyntax {

        try consume(
            .colon,
            expected: ":"
        )

        return try parseType()
    }

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

        var members: [Declaration] = []

        while !check(.rightBrace) && !isAtEnd {
            members.append(
                try parseDeclaration()
            )
        }

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

        var members: [Declaration] = []

        while !check(.rightBrace) && !isAtEnd {
            members.append(
                try parseDeclaration()
            )
        }

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

            let caseName = try parseIdentifier()

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

            cases.append(
                EnumCase(
                    name: caseName,
                    associatedValues: associatedValues,
                    location: caseName.location
                )
            )
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

        var members: [Declaration] = []

        while !check(.rightBrace) && !isAtEnd {
            members.append(
                try parseDeclaration()
            )
        }

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

    func parseExtensionDeclaration()
        throws -> ExtensionDeclaration {

        let keyword = try consume(
            .extensionKeyword,
            expected: "extension"
        )

        let type = try parseType()

        try consume(
            .leftBrace,
            expected: "{"
        )

        var members: [Declaration] = []

        while !check(.rightBrace) && !isAtEnd {
            members.append(
                try parseDeclaration()
            )
        }

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
}