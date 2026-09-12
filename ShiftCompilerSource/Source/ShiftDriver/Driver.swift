import Foundation

final class Driver {
    private let options: DriverOptions

    init(options: DriverOptions) {
        self.options = options
    }

    func run() throws {
        let source = try readSource()

        if options.verbose {
            print("shiftc: input: \(options.inputPath)")
            print("shiftc: phase: lex")
        }

        let lexer = Lexer(source: source)
        let tokens = try lexer.tokenize()

        if options.action == .dumpTokens {
            dumpTokens(tokens)
            return
        }

        if options.verbose {
            print("shiftc: phase: parse")
        }

        let parser = Parser(tokens: tokens)
        _ = try parser.parse()

        if options.action == .parseOnly {
            print("parsed successfully: \(options.inputPath)")
            return
        }

        if options.verbose {
            print("shiftc: compilation completed")
        }
    }

    private func readSource() throws -> String {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: options.inputPath) else {
            throw DriverError.inputFileNotFound(options.inputPath)
        }

        do {
            return try String(
                contentsOfFile: options.inputPath,
                encoding: .utf8
            )
        } catch {
            throw DriverError.inputFileUnreadable(options.inputPath)
        }
    }

    private func dumpTokens(_ tokens: [Token]) {
        for token in tokens {
            print(
                "\(token.location.line):\(token.location.column) " +
                "\(String(describing: token.kind)) " +
                "\(quoted(token.lexeme))"
            )
        }
    }

    private func quoted(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}
