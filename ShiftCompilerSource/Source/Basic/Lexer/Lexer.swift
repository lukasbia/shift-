//
// Lexer.swift
// Shift
//

final class Lexer {

    private let source: String
    private let characters: [Character]

    private var index: Int = 0

    private var line: Int = 1
    private var column: Int = 1

    init(
        source: String
    ) {
        self.source = source
        self.characters = Array(source)
    }

    // MARK: - Entry Point

    func tokenize() throws -> [Token] {

        var tokens: [Token] = []

        while !isAtEnd {

            skipWhitespaceAndComments()

            if isAtEnd {
                break
            }

            tokens.append(
                try lexToken()
            )
        }

        tokens.append(
            Token(
                kind: .endOfFile,
                lexeme: "",
                location: currentLocation
            )
        )

        return tokens
    }

    // MARK: - Token

    private func lexToken() throws -> Token {

        let location = currentLocation
        let character = current

        // Identifier / keyword.
        if isIdentifierStart(character) {
            return lexIdentifierOrKeyword(
                location: location
            )
        }

        // Numeric literal.
        if character.isNumber {
            return try lexNumber(
                location: location
            )
        }

        switch character {

        // MARK: Punctuation

        case "(":
            advance()

            return makeToken(
                .leftParenthesis,
                "(",
                location
            )

        case ")":
            advance()

            return makeToken(
                .rightParenthesis,
                ")",
                location
            )

        case "{":
            advance()

            return makeToken(
                .leftBrace,
                "{",
                location
            )

        case "}":
            advance()

            return makeToken(
                .rightBrace,
                "}",
                location
            )

        case "[":
            advance()

            return makeToken(
                .leftBracket,
                "[",
                location
            )

        case "]":
            advance()

            return makeToken(
                .rightBracket,
                "]",
                location
            )

        case ":":
            advance()

            return makeToken(
                .colon,
                ":",
                location
            )

        case ",":
            advance()

            return makeToken(
                .comma,
                ",",
                location
            )

        case ".":
            advance()

            return makeToken(
                .dot,
                ".",
                location
            )

        // MARK: Literals

        case "\"":
            return try lexStringLiteral(
                location: location
            )

        case "'":
            return try lexCharacterLiteral(
                location: location
            )

        // MARK: Operators

        case "=":
            return lexEqualOperator(
                location: location
            )

        case "!":
            return lexBangOperator(
                location: location
            )

        case "<":
            return lexLessOperator(
                location: location
            )

        case ">":
            return lexGreaterOperator(
                location: location
            )

        case "+":
            return try lexPlusOperator(
                location: location
            )

        case "-":
            return try lexMinusOperator(
                location: location
            )

        case "*":
            return try lexSingleCharacterOperator(
                kind: .star,
                location: location
            )

        case "/":
            return try lexSingleCharacterOperator(
                kind: .slash,
                location: location
            )

        case "%":
            return try lexSingleCharacterOperator(
                kind: .percent,
                location: location
            )

        case "&":
            return lexAmpersandOperator(
                location: location
            )

        case "|":
            return lexPipeOperator(
                location: location
            )

        case "^":
            advance()

            return makeToken(
                .caret,
                "^",
                location
            )

        default:
            throw LexerError.unexpectedCharacter(
                character: character,
                location: location
            )
        }
    }

    // MARK: - Identifiers

    private func lexIdentifierOrKeyword(
        location: SourceLocation
    ) -> Token {

        var lexeme = ""

        while !isAtEnd {

            let character = current

            guard isIdentifierContinue(character) else {
                break
            }

            lexeme.append(
                advance()
            )
        }

        if let keyword = keywordKind(
            for: lexeme
        ) {
            return makeToken(
                keyword,
                lexeme,
                location
            )
        }

        return makeToken(
            .identifier,
            lexeme,
            location
        )
    }

    private func keywordKind(
        for lexeme: String
    ) -> TokenKind? {

        switch lexeme {

        // Declarations

        case "let":
            return .letKeyword

        case "var":
            return .varKeyword

        case "func":
            return .funcKeyword

        case "struct":
            return .structKeyword

        case "class":
            return .classKeyword

        case "enum":
            return .enumKeyword

        case "protocol":
            return .protocolKeyword

        case "extension":
            return .extensionKeyword

        // Modifiers

        case "public":
            return .publicKeyword

        case "private":
            return .privateKeyword

        case "internal":
            return .internalKeyword

        case "static":
            return .staticKeyword

        case "mutating":
            return .mutatingKeyword

        case "unsafe":
            return .unsafeKeyword

        // Statements

        case "return":
            return .returnKeyword

        case "if":
            return .ifKeyword

        case "else":
            return .elseKeyword

        case "while":
            return .whileKeyword

        case "for":
            return .forKeyword

        case "in":
            return .inKeyword

        case "break":
            return .breakKeyword

        case "continue":
            return .continueKeyword

        case "switch":
            return .switchKeyword

        case "case":
            return .caseKeyword

        case "default":
            return .defaultKeyword

        // Boolean literals

        case "true":
            return .booleanLiteral

        case "false":
            return .booleanLiteral

        // Built-in types

        case "Int":
            return .intKeyword

        case "UInt":
            return .uintKeyword

        case "Int8":
            return .int8Keyword

        case "Int16":
            return .int16Keyword

        case "Int32":
            return .int32Keyword

        case "Int64":
            return .int64Keyword

        case "UInt8":
            return .uint8Keyword

        case "UInt16":
            return .uint16Keyword

        case "UInt32":
            return .uint32Keyword

        case "UInt64":
            return .uint64Keyword

        case "Float":
            return .floatKeyword

        case "Double":
            return .doubleKeyword

        case "Bool":
            return .boolKeyword

        case "String":
            return .stringKeyword

        case "Void":
            return .voidKeyword

        default:
            return nil
        }
    }

    // MARK: - Numbers

    private func lexNumber(
        location: SourceLocation
    ) throws -> Token {

        var lexeme = ""

        // Integer portion.

        while !isAtEnd,
              current.isNumber {

            lexeme.append(
                advance()
            )
        }

        var isFloatingPoint = false

        // Decimal point.

        if !isAtEnd,
           current == ".",
           peekIsNumber() {

            isFloatingPoint = true

            lexeme.append(
                advance()
            )

            while !isAtEnd,
                  current.isNumber {

                lexeme.append(
                    advance()
                )
            }
        }

        // Exponent.

        if !isAtEnd,
           current == "e" || current == "E" {

            isFloatingPoint = true

            lexeme.append(
                advance()
            )

            if !isAtEnd,
               current == "+" || current == "-" {

                lexeme.append(
                    advance()
                )
            }

            guard !isAtEnd,
                  current.isNumber else {

                throw LexerError.invalidFloatingLiteral(
                    lexeme: lexeme,
                    location: location
                )
            }

            while !isAtEnd,
                  current.isNumber {

                lexeme.append(
                    advance()
                )
            }
        }

        // A number immediately followed by an identifier
        // is not a valid numeric literal.

        if !isAtEnd,
           isIdentifierStart(current) {

            while !isAtEnd,
                  isIdentifierContinue(current) {

                lexeme.append(
                    advance()
                )
            }

            if isFloatingPoint {
                throw LexerError.invalidFloatingLiteral(
                    lexeme: lexeme,
                    location: location
                )
            }

            throw LexerError.invalidIntegerLiteral(
                lexeme: lexeme,
                location: location
            )
        }

        if isFloatingPoint {

            return makeToken(
                .floatingLiteral,
                lexeme,
                location
            )
        }

        return makeToken(
            .integerLiteral,
            lexeme,
            location
        )
    }

    // MARK: - Strings

    private func lexStringLiteral(
        location: SourceLocation
    ) throws -> Token {

        var lexeme = ""

        // Opening quote.

        lexeme.append(
            advance()
        )

        while !isAtEnd {

            let character = current

            if character == "\"" {

                lexeme.append(
                    advance()
                )

                return makeToken(
                    .stringLiteral,
                    lexeme,
                    location
                )
            }

            if character == "\n" ||
               character == "\r" {

                throw LexerError.unterminatedString(
                    location: location
                )
            }

            if character == "\\" {

                try appendEscape(
                    to: &lexeme,
                    location: location
                )

                continue
            }

            lexeme.append(
                advance()
            )
        }

        throw LexerError.unterminatedString(
            location: location
        )
    }

    // MARK: - Characters

    private func lexCharacterLiteral(
        location: SourceLocation
    ) throws -> Token {

        var lexeme = ""

        // Opening quote.

        lexeme.append(
            advance()
        )

        guard !isAtEnd else {
            throw LexerError.unterminatedCharacter(
                location: location
            )
        }

        // Character contents.

        if current == "\\" {

            try appendEscape(
                to: &lexeme,
                location: location
            )

        } else {

            if current == "\n" ||
               current == "\r" ||
               current == "'" {

                throw LexerError.invalidCharacterLiteral(
                    location: location
                )
            }

            lexeme.append(
                advance()
            )
        }

        // Closing quote.

        guard !isAtEnd,
              current == "'" else {

            throw LexerError.invalidCharacterLiteral(
                location: location
            )
        }

        lexeme.append(
            advance()
        )

        return makeToken(
            .characterLiteral,
            lexeme,
            location
        )
    }

    private func appendEscape(
        to lexeme: inout String,
        location: SourceLocation
    ) throws {

        // Backslash.

        lexeme.append(
            advance()
        )

        guard !isAtEnd else {
            throw LexerError.invalidEscapeSequence(
                sequence: "\\",
                location: location
            )
        }

        let escaped = current

        switch escaped {

        case "n":
            lexeme.append(
                advance()
            )

        case "r":
            lexeme.append(
                advance()
            )

        case "t":
            lexeme.append(
                advance()
            )

        case "0":
            lexeme.append(
                advance()
            )

        case "\\":
            lexeme.append(
                advance()
            )

        case "\"":
            lexeme.append(
                advance()
            )

        case "'":
            lexeme.append(
                advance()
            )

        default:

            let sequence = "\\\(escaped)"

            throw LexerError.invalidEscapeSequence(
                sequence: sequence,
                location: location
            )
        }
    }

    // MARK: - Operators

    private func lexEqualOperator(
        location: SourceLocation
    ) -> Token {

        advance()

        if !isAtEnd,
           current == "=" {

            advance()

            return makeToken(
                .equalEqual,
                "==",
                location
            )
        }

        return makeToken(
            .equal,
            "=",
            location
        )
    }

    private func lexBangOperator(
        location: SourceLocation
    ) -> Token {

        advance()

        if !isAtEnd,
           current == "=" {

            advance()

            return makeToken(
                .notEqual,
                "!=",
                location
            )
        }

        return makeToken(
            .logicalNot,
            "!",
            location
        )
    }

    private func lexLessOperator(
        location: SourceLocation
    ) -> Token {

        advance()

        if !isAtEnd,
           current == "=" {

            advance()

            return makeToken(
                .lessEqual,
                "<=",
                location
            )
        }

        return makeToken(
            .less,
            "<",
            location
        )
    }

    private func lexGreaterOperator(
        location: SourceLocation
    ) -> Token {

        advance()

        if !isAtEnd,
           current == "=" {

            advance()

            return makeToken(
                .greaterEqual,
                ">=",
                location
            )
        }

        return makeToken(
            .greater,
            ">",
            location
        )
    }

    private func lexPlusOperator(
        location: SourceLocation
    ) throws -> Token {

        advance()

        // Shift deliberately does not support ++.

        if !isAtEnd,
           current == "+" {

            advance()

            throw LexerError.invalidOperator(
                lexeme: "++",
                location: location
            )
        }

        // Shift deliberately does not support +=.

        if !isAtEnd,
           current == "=" {

            advance()

            throw LexerError.invalidOperator(
                lexeme: "+=",
                location: location
            )
        }

        return makeToken(
            .plus,
            "+",
            location
        )
    }

    private func lexMinusOperator(
        location: SourceLocation
    ) throws -> Token {

        advance()

        // Function/type arrow.

        if !isAtEnd,
           current == ">" {

            advance()

            return makeToken(
                .arrow,
                "->",
                location
            )
        }

        // Shift deliberately does not support --.

        if !isAtEnd,
           current == "-" {

            advance()

            throw LexerError.invalidOperator(
                lexeme: "--",
                location: location
            )
        }

        // Shift deliberately does not support -=.

        if !isAtEnd,
           current == "=" {

            advance()

            throw LexerError.invalidOperator(
                lexeme: "-=",
                location: location
            )
        }

        return makeToken(
            .minus,
            "-",
            location
        )
    }

    private func lexSingleCharacterOperator(
        kind: TokenKind,
        location: SourceLocation
    ) throws -> Token {

        let character = current

        advance()

        // Shift does not use compound assignment.

        if !isAtEnd,
           current == "=" {

            advance()

            let lexeme = "\(character)="

            throw LexerError.invalidOperator(
                lexeme: lexeme,
                location: location
            )
        }

        return makeToken(
            kind,
            String(character),
            location
        )
    }

    private func lexAmpersandOperator(
        location: SourceLocation
    ) -> Token {

        advance()

        if !isAtEnd,
           current == "&" {

            advance()

            return makeToken(
                .logicalAnd,
                "&&",
                location
            )
        }

        return makeToken(
            .ampersand,
            "&",
            location
        )
    }

    private func lexPipeOperator(
        location: SourceLocation
    ) -> Token {

        advance()

        if !isAtEnd,
           current == "|" {

            advance()

            return makeToken(
                .logicalOr,
                "||",
                location
            )
        }

        return makeToken(
            .pipe,
            "|",
            location
        )
    }

    // MARK: - Whitespace / Comments

    private func skipWhitespaceAndComments() {

        while !isAtEnd {

            if current.isWhitespace {

                advance()
                continue
            }

            // Shift line comments begin with ';'.

            if current == ";" {

                while !isAtEnd {

                    if current == "\n" ||
                       current == "\r" {

                        break
                    }

                    advance()
                }

                continue
            }

            break
        }
    }

    // MARK: - Character Helpers

    private var isAtEnd: Bool {
        index >= characters.count
    }

    private var current: Character {
        characters[index]
    }

    private var currentLocation: SourceLocation {
        SourceLocation(
            line: line,
            column: column
        )
    }

    @discardableResult
    private func advance() -> Character {

        let character = characters[index]

        index += 1

        if character == "\n" {

            line += 1
            column = 1

        } else {

            column += 1
        }

        return character
    }

    private func peek(
        offset: Int = 1
    ) -> Character? {

        let position = index + offset

        guard position < characters.count else {
            return nil
        }

        return characters[position]
    }

    private func peekIsNumber() -> Bool {

        guard let next = peek() else {
            return false
        }

        return next.isNumber
    }

    private func isIdentifierStart(
        _ character: Character
    ) -> Bool {

        character == "_" ||
        character.isLetter
    }

    private func isIdentifierContinue(
        _ character: Character
    ) -> Bool {

        character == "_" ||
        character.isLetter ||
        character.isNumber
    }

    // MARK: - Token Creation

    private func makeToken(
        _ kind: TokenKind,
        _ lexeme: String,
        _ location: SourceLocation
    ) -> Token {

        Token(
            kind: kind,
            lexeme: lexeme,
            location: location
        )
    }
}