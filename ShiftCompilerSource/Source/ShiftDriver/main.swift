import Foundation

@main
struct ShiftCompilerMain {
    static func main() {
        do {
            let options = try DriverOptions.parse(
                arguments: Array(CommandLine.arguments.dropFirst())
            )

            try Driver(options: options).run()
        } catch let error as LexerError {
            fputs("shiftc: \(error)\n", stderr)
            exit(EXIT_FAILURE)
        } catch let error as ParserError {
            fputs("shiftc: \(error)\n", stderr)
            exit(EXIT_FAILURE)
        } catch let error as DriverError {
            fputs("\(error)\n", stderr)
            exit(EXIT_FAILURE)
        } catch {
            fputs("shiftc: \(error)\n", stderr)
            exit(EXIT_FAILURE)
        }
    }
}
