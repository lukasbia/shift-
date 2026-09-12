public final class Lexer {
    private let source: String
    private var characters: [Character]

    private var index: Int = 0

    private var line: Int = 1
    private var column: Int = 1

    private var tokens: [Token] = []

    private static let keywords: [String: TokenKind] = [
        // Declarations
        "let": .letKeyword,
        "var": .varKeyword,
        "func": .funcKeyword,
        "struct": .structKeyword,
        "class": .classKeyword,
        "enum": .enumKeyword,
        "protocol": .protocolKeyword,
        "extension": .extensionKeyword,

        // Modifiers
        "public": .publicKeyword,
        "private": .privateKeyword,
        "internal": .internalKeyword,
        "static": .staticKeyword,
        "mutating": .mutatingKeyword,
        "unsafe": .unsafeKeyword,

        // Statements
        "break": .breakKeyword,
        "continue": .continueKeyword,
        "return": .returnKeyword,
        "if": .ifKeyword,
        "else": .elseKeyword,
        "while": .whileKeyword,
        "for": .forKeyword,
        "switch": .switchKeyword,
        "case": .caseKeyword,
        "default": .defaultKeyword,
        "in": .inKeyword,

        // Built-in types
        "Int": .intKeyword,
        "UInt": .uintKeyword,
        "Int8": .int8Keyword,
        "Int16": .int16Keyword,
        "Int32": .int32Keyword,
        "Int64": .int64Keyword,

        "UInt8": .uint8Keyword,
        "UInt16": .uint16Keyword,
        "UInt32": .uint32Keyword,
        "UInt64": .uint64Keyword,

        "Float": .floatKeyword,
        "Double": .doubleKeyword,
        "Bool": .boolKeyword,
        "String": .stringKeyword,
        "Void": .voidKeyword,

        // Boolean literals
        "true": .booleanLiteral,
        "false": .booleanLiteral
    ]

    public init(source: String) {
        self.source = source
        self.characters = Array(source)
    }

    // MARK: - Entry Point

    public func tokenize() throws -> [Token] {
        var result: [Token] = []

        while !isAtEnd {
            skipWhitespaceAndComments()

            if isAtEnd {
                break
            }

            result.append(try lexToken())
        }

        result.append(
            Token(
                kind: .endOfFile,
                lexeme: "",
                location: currentLocation
            )
        )

        tokens = result
        return result
    }

    public func lex() throws -> [Token] {
        try tokenize()
    }

    // MARK: - Tokenization

    private func lexToken() throws -> Token {
        let location = currentLocation

        let character = currentCharacter

        if isIdentifierStart(character) {
            return lexIdentifierOrKeyword()
        }

        if isASCIIDigit(character) {
            return try lexNumber()
        }

        switch character {
        case "\"":
            return try lexString()

        case "'":
            return try lexCharacter()

        case ":":
            return makeSingleCharacterToken(
                .colon
            )

        case "=":
            return try lexEqual()

        case "(":
            return makeSingleCharacterToken(
                .leftParenthesis
            )

        case ")":
            return makeSingleCharacterToken(
                .rightParenthesis
            )

        case "[":
            return makeSingleCharacterToken(
                .leftBracket
            )

        case "]":
            return makeSingleCharacterToken(
                .rightBracket
            )

        case "{":
            return makeSingleCharacterToken(
                .leftBrace
            )

        case "}":
            return makeSingleCharacterToken(
                .rightBrace
            )

        case ",":
            return makeSingleCharacterToken(
                .comma
            )

        case ".":
            return makeSingleCharacterToken(
                .dot
            )

        case "+":
            return try lexPlus()

        case "-":
            return try lexMinus()

        case "*":
            return try lexStar()

        case "/":
            return try lexSlash()

        case "%":
            return try lexPercent()

        case "!":
            return try lexExclamation()

        case "<":
            return try lexLess()

        case ">":
            return try lexGreater()

        case "&":
            return try lexAmpersand()

        case "|":
            return try lexPipe()

        case "^":
            return makeSingleCharacterToken(
                .caret
            )

        default:
            throw LexerError.invalidCharacter(
                character: character,
                location: location
            )
        }
    }

    // MARK: - Identifiers

    private func lexIdentifierOrKeyword() -> Token {
        let location = currentLocation
        let start = index

        advance()

        while !isAtEnd && isIdentifierContinue(currentCharacter) {
            advance()
        }

        let lexeme = substring(from: start, to: index)

        let kind = Self.keywords[lexeme] ?? .identifier

        return Token(
            kind: kind,
            lexeme: lexeme,
            location: location
        )
    }

    // MARK: - Numbers

    private func lexNumber() throws -> Token {
        let location = currentLocation
        let start = index

        var hasDecimalPoint = false
        var hasExponent = false

        if currentCharacter == "0" {
            advance()

            if !isAtEnd {
                switch currentCharacter {
                case "x", "X":
                    advance()

                    guard isHexDigit(currentCharacter) else {
                        let lexeme = substring(
                            from: start,
                            to: index
                        )

                        throw LexerError.invalidNumber(
                            lexeme: lexeme,
                            location: location
                        )
                    }

                    while !isAtEnd && isHexDigit(currentCharacter) {
                        advance()
                    }

                    return Token(
                        kind: .integerLiteral,
                        lexeme: substring(
                            from: start,
                            to: index
                        ),
                        location: location
                    )

                case "b", "B":
                    advance()

                    guard currentCharacter == "0" || currentCharacter == "1" else {
                        let lexeme = substring(
                            from: start,
                            to: index
                        )

                        throw LexerError.invalidNumber(
                            lexeme: lexeme,
                            location: location
                        )
                    }

                    while !isAtEnd &&
                          (currentCharacter == "0" ||
                           currentCharacter == "1") {
                        advance()
                    }

                    return Token(
                        kind: .integerLiteral,
                        lexeme: substring(
                            from: start,
                            to: index
                        ),
                        location: location
                    )

                case "o", "O":
                    advance()

                    guard isOctalDigit(currentCharacter) else {
                        let lexeme = substring(
                            from: start,
                            to: index
                        )

                        throw LexerError.invalidNumber(
                            lexeme: lexeme,
                            location: location
                        )
                    }

                    while !isAtEnd && isOctalDigit(currentCharacter) {
                        advance()
                    }

                    return Token(
                        kind: .integerLiteral,
                        lexeme: substring(
                            from: start,
                            to: index
                        ),
                        location: location
                    )

                default:
                    break
                }
            }
        } else {
            while !isAtEnd && isASCIIDigit(currentCharacter) {
                advance()
            }
        }

        if !isAtEnd && currentCharacter == "." {
            hasDecimalPoint = true
            advance()

            while !isAtEnd && isASCIIDigit(currentCharacter) {
                advance()
            }
        }

        if !isAtEnd &&
           (currentCharacter == "e" || currentCharacter == "E") {
            hasExponent = true
            advance()

            if !isAtEnd &&
               (currentCharacter == "+" || currentCharacter == "-") {
                advance()
            }

            guard !isAtEnd && isASCIIDigit(currentCharacter) else {
                let lexeme = substring(
                    from: start,
                    to: index
                )

                throw LexerError.invalidNumber(
                    lexeme: lexeme,
                    location: location
                )
            }

            while !isAtEnd && isASCIIDigit(currentCharacter) {
                advance()
            }
        }

        // A number cannot be immediately followed by an identifier.
        if !isAtEnd && isIdentifierStart(currentCharacter) {
            while !isAtEnd && isIdentifierContinue(currentCharacter) {
                advance()
            }

            throw LexerError.invalidNumber(
                lexeme: substring(
                    from: start,
                    to: index
                ),
                location: location
            )
        }

        let lexeme = substring(
            from: start,
            to: index
        )

        return Token(
            kind: hasDecimalPoint || hasExponent
                ? .floatingLiteral
                : .integerLiteral,
            lexeme: lexeme,
            location: location
        )
    }

    // MARK: - Strings

    private func lexString() throws -> Token {
        let location = currentLocation
        let start = index

        advance() // "

        while !isAtEnd {
            let character = currentCharacter

            if character == "\"" {
                advance()

                return Token(
                    kind: .stringLiteral,
                    lexeme: substring(
                        from: start,
                        to: index
                    ),
                    location: location
                )
            }

            if character == "\\" {
                advance()

                try consumeEscape(
                    location: currentLocation
                )

                continue
            }

            if character == "\n" || character == "\r" {
                throw LexerError.unterminatedString(
                    location: location
                )
            }

            advance()
        }

        throw LexerError.unterminatedString(
            location: location
        )
    }

    // MARK: - Characters

    private func lexCharacter() throws -> Token {
        let location = currentLocation
        let start = index

        advance() // '

        guard !isAtEnd else {
            throw LexerError.unterminatedCharacter(
                location: location
            )
        }

        if currentCharacter == "\n" ||
           currentCharacter == "\r" {
            throw LexerError.unterminatedCharacter(
                location: location
            )
        }

        if currentCharacter == "\\" {
            advance()

            try consumeEscape(
                location: currentLocation
            )
        } else {
            advance()
        }

        guard !isAtEnd && currentCharacter == "'" else {
            throw LexerError.invalidCharacterLiteral(
                location: location
            )
        }

        advance()

        return Token(
            kind: .characterLiteral,
            lexeme: substring(
                from: start,
                to: index
            ),
            location: location
        )
    }

    private func consumeEscape(
        location: SourceLocation
    ) throws {
        guard !isAtEnd else {
            throw LexerError.invalidEscape(
                location: location
            )
        }

        switch currentCharacter {
        case "n", "r", "t",
             "\\", "\"", "'",
             "0":
            advance()

        case "u":
            advance()

            guard !isAtEnd && currentCharacter == "{" else {
                throw LexerError.invalidEscape(
                    location: location
                )
            }

            advance()

            var digits = 0

            while !isAtEnd && isHexDigit(currentCharacter) {
                advance()
                digits += 1
            }

            guard digits > 0 &&
                  !isAtEnd &&
                  currentCharacter == "}" else {
                throw LexerError.invalidEscape(
                    location: location
                )
            }

            advance()

        default:
            throw LexerError.invalidEscape(
                location: location
            )
        }
    }

    // MARK: - Operators

    private func lexEqual() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            return Token(
                kind: .equalEqual,
                lexeme: "==",
                location: location
            )
        }

        return Token(
            kind: .equal,
            lexeme: "=",
            location: location
        )
    }

    private func lexPlus() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            throw LexerError.forbiddenCompoundAssignment(
                lexeme: "+=",
                location: location
            )
        }

        if match("+") {
            throw LexerError.forbiddenIncrementOperator(
                lexeme: "++",
                location: location
            )
        }

        return Token(
            kind: .plus,
            lexeme: "+",
            location: location
        )
    }

    private func lexMinus() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            throw LexerError.forbiddenCompoundAssignment(
                lexeme: "-=",
                location: location
            )
        }

        if match("-") {
            throw LexerError.forbiddenIncrementOperator(
                lexeme: "--",
                location: location
            )
        }

        if match(">") {
            return Token(
                kind: .arrow,
                lexeme: "->",
                location: location
            )
        }

        return Token(
            kind: .minus,
            lexeme: "-",
            location: location
        )
    }

    private func lexStar() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            throw LexerError.forbiddenCompoundAssignment(
                lexeme: "*=",
                location: location
            )
        }

        return Token(
            kind: .star,
            lexeme: "*",
            location: location
        )
    }

    private func lexSlash() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            throw LexerError.forbiddenCompoundAssignment(
                lexeme: "/=",
                location: location
            )
        }

        return Token(
            kind: .slash,
            lexeme: "/",
            location: location
        )
    }

    private func lexPercent() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            throw LexerError.forbiddenCompoundAssignment(
                lexeme: "%=",
                location: location
            )
        }

        return Token(
            kind: .percent,
            lexeme: "%",
            location: location
        )
    }

    private func lexExclamation() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            return Token(
                kind: .notEqual,
                lexeme: "!=",
                location: location
            )
        }

        return Token(
            kind: .logicalNot,
            lexeme: "!",
            location: location
        )
    }

    private func lexLess() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            return Token(
                kind: .lessEqual,
                lexeme: "<=",
                location: location
            )
        }

        return Token(
            kind: .less,
            lexeme: "<",
            location: location
        )
    }

    private func lexGreater() throws -> Token {
        let location = currentLocation

        advance()

        if match("=") {
            return Token(
                kind: .greaterEqual,
                lexeme: ">=",
                location: location
            )
        }

        return Token(
            kind: .greater,
            lexeme: ">",
            location: location
        )
    }

    private func lexAmpersand() throws -> Token {
        let location = currentLocation

        advance()

        if match("&") {
            return Token(
                kind: .logicalAnd,
                lexeme: "&&",
                location: location
            )
        }

        return Token(
            kind: .ampersand,
            lexeme: "&",
            location: location
        )
    }

    private func lexPipe() throws -> Token {
        let location = currentLocation

        advance()

        if match("|") {
            return Token(
                kind: .logicalOr,
                lexeme: "||",
                location: location
            )
        }

        return Token(
            kind: .pipe,
            lexeme: "|",
            location: location
        )
    }

    // MARK: - Whitespace / Comments

    private func skipWhitespaceAndComments() {
        while !isAtEnd {
            if isWhitespace(currentCharacter) {
                advance()
                continue
            }

            // Shift uses ';' for line comments.
            if currentCharacter == ";" {
                while !isAtEnd &&
                      currentCharacter != "\n" &&
                      currentCharacter != "\r" {
                    advance()
                }

                continue
            }

            break
        }
    }

    // MARK: - Helpers

    private var isAtEnd: Bool {
        index >= characters.count
    }

    private var currentCharacter: Character {
        guard !isAtEnd else {
            return "\0"
        }

        return characters[index]
    }

    private var currentLocation: SourceLocation {
        SourceLocation(
            line: line,
            column: column
        )
    }

    @discardableResult
    private func advance() -> Character {
        guard !isAtEnd else {
            return "\0"
        }

        let character = characters[index]
        index += 1

        if character == "\n" {
            line += 1
            column = 1
        } else if character == "\r" {
            // Handle CRLF as one newline.
            if !isAtEnd && currentCharacter == "\n" {
                index += 1
            }

            line += 1
            column = 1
        } else {
            column += 1
        }

        return character
    }

    @discardableResult
    private func match(
        _ expected: Character
    ) -> Bool {
        guard !isAtEnd &&
              currentCharacter == expected else {
            return false
        }

        advance()
        return true
    }

    private func makeSingleCharacterToken(
        _ kind: TokenKind
    ) -> Token {
        let location = currentLocation
        let character = currentCharacter

        advance()

        return Token(
            kind: kind,
            lexeme: String(character),
            location: location
        )
    }

    private func substring(
        from start: Int,
        to end: Int
    ) -> String {
        String(
            characters[
                start..<end
            ]
        )
    }

    // MARK: - Character Classification

    private func isWhitespace(
        _ character: Character
    ) -> Bool {
        character == " " ||
        character == "\t" ||
        character == "\n" ||
        character == "\r" ||
        character == "\u{000B}" ||
        character == "\u{000C}"
    }

    private func isIdentifierStart(
        _ character: Character
    ) -> Bool {
        guard let scalar = character.unicodeScalars.first,
              character.unicodeScalars.count == 1 else {
            return false
        }

        return isASCIIUppercase(scalar.value) ||
               isASCIILowercase(scalar.value) ||
               scalar.value == 95
    }

    private func isIdentifierContinue(
        _ character: Character
    ) -> Bool {
        guard let scalar = character.unicodeScalars.first,
              character.unicodeScalars.count == 1 else {
            return false
        }

        return isIdentifierStart(character) ||
               isASCIIDigit(character)
    }

    private func isASCIIDigit(
        _ character: Character
    ) -> Bool {
        guard let value = character.unicodeScalars.first?.value,
              character.unicodeScalars.count == 1 else {
            return false
        }

        return value >= 48 && value <= 57
    }

    private func isHexDigit(
        _ character: Character
    ) -> Bool {
        guard let value = character.unicodeScalars.first?.value,
              character.unicodeScalars.count == 1 else {
            return false
        }

        return (value >= 48 && value <= 57) ||
               (value >= 65 && value <= 70) ||
               (value >= 97 && value <= 102)
    }

    private func isOctalDigit(
        _ character: Character
    ) -> Bool {
        guard let value = character.unicodeScalars.first?.value,
              character.unicodeScalars.count == 1 else {
            return false
        }

        return value >= 48 && value <= 55
    }

    private func isASCIIUppercase(
        _ value: UInt32
    ) -> Bool {
        value >= 65 && value <= 90
    }

    private func isASCIILowercase(
        _ value: UInt32
    ) -> Bool {
        value >= 97 && value <= 122
    }
}