import Foundation

final class Parser {

    private let tokens: [Token]
    private var index: Int = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    // MARK: - Entry Point

    func parse() throws -> SourceFile {
        let location = current.location
        var declarations: [Declaration] = []

        while !isAtEnd {
            declarations.append(try parseDeclaration())
        }

        return SourceFile(
            declarations: declarations,
            location: location
        )
    }

    // MARK: - Declarations

    fileprivate func parseDeclaration() throws -> Declaration {
        let modifiers = try parseModifiers()

        switch current.kind {

        case .letKeyword, .varKeyword:
            guard modifiers.isEmpty else {
                throw error(
                    expected: "declaration",
                    message: "variable declarations cannot have declaration modifiers"
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
            guard modifiers.isEmpty else {
                throw error(
                    expected: "extension",
                    message: "extension declarations cannot have declaration modifiers"
                )
            }

            return .extensionDecl(
                try parseExtensionDeclaration()
            )

        default:
            throw error(
                expected: "declaration",
                message: "unexpected token '\(current.lexeme)'"
            )
        }
    }

    // MARK: - Modifiers

    fileprivate func parseModifiers() throws -> [DeclarationModifier] {
        var modifiers: [DeclarationModifier] = []

        while true {
            let modifier: DeclarationModifier?

            switch current.kind {
            case .publicKeyword:
                advance()
                modifier = .public

            case .privateKeyword:
                advance()
                modifier = .private

            case .internalKeyword:
                advance()
                modifier = .internal

            case .staticKeyword:
                advance()
                modifier = .static

            case .mutatingKeyword:
                advance()
                modifier = .mutating

            case .unsafeKeyword:
                advance()
                modifier = .unsafe

            default:
                modifier = nil
            }

            guard let modifier else {
                break
            }

            if modifiers.contains(where: {
                String(describing: $0) == String(describing: modifier)
            }) {
                throw error(
                    expected: "unique declaration modifier",
                    message: "duplicate declaration modifier"
                )
            }

            modifiers.append(modifier)
        }

        return modifiers
    }

    // MARK: - Token Navigation

    fileprivate var current: Token {
        guard !tokens.isEmpty else {
            fatalError("Parser requires an EOF token")
        }

        return tokens[min(index, tokens.count - 1)]
    }

    fileprivate var previous: Token {
        guard !tokens.isEmpty else {
            fatalError("Parser requires an EOF token")
        }

        return tokens[max(index - 1, 0)]
    }

    fileprivate var isAtEnd: Bool {
        current.kind == .endOfFile
    }

    fileprivate func peek(_ distance: Int = 1) -> Token {
        let position = index + distance

        guard position < tokens.count else {
            return tokens[tokens.count - 1]
        }

        return tokens[position]
    }

    fileprivate func peekKind(_ distance: Int = 1) -> TokenKind {
        peek(distance).kind
    }

    @discardableResult
    fileprivate func advance() -> Token {
        let token = current

        if !isAtEnd {
            index += 1
        }

        return token
    }

    fileprivate func check(_ kind: TokenKind) -> Bool {
        current.kind == kind
    }

    fileprivate func checkAny(_ kinds: TokenKind...) -> Bool {
        kinds.contains(current.kind)
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

            throw error(expected: expected)
        }

        return advance()
    }

    @discardableResult
    fileprivate func match(_ kind: TokenKind) -> Bool {
        guard check(kind) else {
            return false
        }

        advance()
        return true
    }

    @discardableResult
    fileprivate func matchAny(_ kinds: TokenKind...) -> Bool {
        guard kinds.contains(current.kind) else {
            return false
        }

        advance()
        return true
    }

    // MARK: - Identifiers

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

    // MARK: - Errors

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

    // MARK: - Recovery

    /*
     Shift currently uses throwing parsing rather than collecting
     multiple diagnostics. These helpers still provide safe recovery
     points for future diagnostic aggregation.
     */

    fileprivate func skipUntil(
        _ kinds: TokenKind...
    ) {
        while !isAtEnd && !kinds.contains(current.kind) {
            advance()
        }
    }

    fileprivate func skipBalancedBlock() {
        guard check(.leftBrace) else {
            return
        }

        var depth = 0

        while !isAtEnd {
            if match(.leftBrace) {
                depth += 1
                continue
            }

            if match(.rightBrace) {
                depth -= 1

                if depth == 0 {
                    return
                }

                continue
            }

            advance()
        }
    }
}