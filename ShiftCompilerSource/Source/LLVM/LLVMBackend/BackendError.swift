import Foundation

public enum BackendError: Error, CustomStringConvertible, Equatable {
    case toolNotFound(String)
    case processFailed(tool: String, arguments: [String], status: Int32, output: String)
    case inputFileNotFound(String)
    case outputDirectoryCreationFailed(String)
    case invalidTargetTriple(String)
    case unsupportedOutput(String)
    case ioFailure(String)

    public var description: String {
        switch self {
        case .toolNotFound(let tool):
            return "backend tool not found: \(tool)"
        case let .processFailed(tool, arguments, status, output):
            let command = ([tool] + arguments).joined(separator: " ")
            return "backend command failed (exit \(status)): \(command)\n\(output)"
        case .inputFileNotFound(let path):
            return "backend input file not found: \(path)"
        case .outputDirectoryCreationFailed(let path):
            return "unable to create output directory: \(path)"
        case .invalidTargetTriple(let triple):
            return "invalid target triple: \(triple)"
        case .unsupportedOutput(let output):
            return "unsupported backend output: \(output)"
        case .ioFailure(let message):
            return "backend I/O failure: \(message)"
        }
    }
}
