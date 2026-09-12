import Foundation

enum DriverError: Error, CustomStringConvertible {
    case noInput
    case multipleInputFilesNotSupported
    case unknownOption(String)
    case inputFileNotFound(String)
    case inputFileUnreadable(String)
    case invalidInputExtension(String)

    var description: String {
        switch self {
        case .noInput:
            return "shiftc: no input files"
        case .multipleInputFilesNotSupported:
            return "shiftc: multiple input files are not supported by this compiler stage"
        case let .unknownOption(option):
            return "shiftc: unknown option '\(option)'"
        case let .inputFileNotFound(path):
            return "shiftc: input file '\(path)' does not exist"
        case let .inputFileUnreadable(path):
            return "shiftc: unable to read input file '\(path)'"
        case let .invalidInputExtension(path):
            return "shiftc: input file '\(path)' does not have the '.shift' extension"
        }
    }
}
