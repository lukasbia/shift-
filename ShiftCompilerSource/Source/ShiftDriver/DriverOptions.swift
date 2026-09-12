import Foundation

struct DriverOptions {
    enum Action {
        case compile
        case dumpTokens
        case parseOnly
    }

    let inputPath: String
    let action: Action
    let verbose: Bool

    static let compilerName = "shiftc"
    static let version = "0.1.0"

    static func parse(arguments: [String]) throws -> DriverOptions {
        var inputPath: String?
        var action: Action = .compile
        var verbose = false

        for argument in arguments {
            switch argument {
            case "-h", "--help":
                print(Self.helpText)
                exit(0)

            case "--version":
                print("\(compilerName) \(version)")
                exit(0)

            case "--dump-tokens":
                action = .dumpTokens

            case "--parse-only":
                action = .parseOnly

            case "-v", "--verbose":
                verbose = true

            case let option where option.hasPrefix("-"):
                throw DriverError.unknownOption(option)

            default:
                guard inputPath == nil else {
                    throw DriverError.multipleInputFilesNotSupported
                }
                inputPath = argument
            }
        }

        guard let inputPath else {
            throw DriverError.noInput
        }

        guard inputPath.hasSuffix(".shift") else {
            throw DriverError.invalidInputExtension(inputPath)
        }

        return DriverOptions(
            inputPath: inputPath,
            action: action,
            verbose: verbose
        )
    }

    static let helpText = """
    USAGE:
      shiftc [options] <input.shift>

    OPTIONS:
      --parse-only       Lex and parse the source, then stop.
      --dump-tokens      Lex the source and print its token stream.
      -v, --verbose      Print driver phase information.
      -h, --help         Show this help.
      --version          Print the compiler version.

    CURRENT PIPELINE:
      source
        -> lexer
        -> parser

    COMMENTS:
      Shift uses ';' as the line-comment marker.
    """
}
