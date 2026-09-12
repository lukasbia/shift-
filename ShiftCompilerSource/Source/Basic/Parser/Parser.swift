import Foundation

final class Parser {

    private let tokens: [Token]
    private var index: Int = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    // MARK: Entry Point

    func parse() throws -> SourceFile {
        let location = current.location
        var declarations: [Declaration] = []

        while !isAtEnd {
            declarations.append(
                try parseDeclaration()
            )
        }

        return SourceFile(
            declarations: declarations,
            location: location
        )
    }

    // MARK: Declaration Parsing

    fileprivate func parseDeclaration() throws -> Declaration {
        let modifiers = try parseModifiers()

        switch current.kind {

        case .letKeyword,
             .varKeyword:
            guard modifiers.isEmpty else {
                throw error(
                    expected: "declaration",
                    message: "variable declarations cannot have these modifiers"
                )
            }

            return .variable(
                try parseVariableDeclaration()
            )

        case .funcKeyword:
            return .function(
                try parseFunctionDeclaration(
                    modifiers: modifiers
                )
            )

        case .structKeyword:
            return .structDecl(
                try parseStructDeclaration(
                    modifiers: modifiers
                )
            )

        case .classKeyword:
            return .classDecl(
                try parseClassDeclaration(
                    modifiers: modifiers
                )
            )

        case .enumKeyword:
            return .enumDecl(
                try parseEnumDeclaration(
                    modifiers: modifiers
                )
            )

        case .protocolKeyword:
            return .protocolDecl(
                try parseProtocolDeclaration(
                    modifiers: modifiers
                )
            )

        case .extensionKeyword:
            return .extensionDecl(
                try parseExtensionDeclaration()
            )

        default:
            throw error(
                expected: "declaration",
                message: "unexpected token"
            )
        }
    }

    // MARK: Helpers

    fileprivate var current: Token {
        tokens[min(index, tokens.count - 1)]
    }

    fileprivate var previous: Token {
        tokens[max(index - 1, 0)]
    }

    fileprivate var isAtEnd: Bool {
        current.kind == .endOfFile
    }

    @discardableResult
    fileprivate func advance() -> Token {
        let token = current

        if !isAtEnd {
            index += 1
        }

        return token
    }

    fileprivate func check(
        _ kind: TokenKind
    ) -> Bool {
        current.kind == kind
    }

    @discardableResult
    fileprivate func consume(
        _ kind: TokenKind,
        expected: String
    ) throws -> Token {

        guard check(kind) else {
            if isAtEnd {
                throw ParserError.unexpectedEndOfFile(
                    expected: expected,
                    location: current.location
                )
            }

            throw error(
                expected: expected
            )
        }

        return advance()
    }

    fileprivate func match(
        _ kind: TokenKind
    ) -> Bool {

        guard check(kind) else {
            return false
        }

        advance()
        return true
    }

    fileprivate func error(
        expected: String,
        message: String? = nil
    ) -> ParserError {

        .unexpectedToken(
            expected: expected,
            actual: current,
            message: message
        )
    }

    fileprivate func parseModifiers()
        throws -> [DeclarationModifier] {

        var modifiers: [DeclarationModifier] = []

        while true {
            switch current.kind {

            case .publicKeyword:
                advance()
                modifiers.append(.public)

            case .privateKeyword:
                advance()
                modifiers.append(.private)

            case .internalKeyword:
                advance()
                modifiers.append(.internal)

            case .staticKeyword:
                advance()
                modifiers.append(.static)

            case .mutatingKeyword:
                advance()
                modifiers.append(.mutating)

            case .unsafeKeyword:
                advance()
                modifiers.append(.unsafe)

            default:
                return modifiers
            }
        }
    }

    fileprivate func parseIdentifier() throws -> Identifier {
        guard check(.identifier) else {
            throw error(
                expected: "identifier"
            )
        }

        let token = advance()

        return Identifier(
            name: token.lexeme,
            location: token.location
        )
    }
}