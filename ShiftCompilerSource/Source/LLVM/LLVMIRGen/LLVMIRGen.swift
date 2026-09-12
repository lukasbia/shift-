import Foundation
import ShiftSIL

public final class LLVMIRGen {
    public let options: IRGenOptions

    public init(options: IRGenOptions = IRGenOptions()) {
        self.options = options
    }

    public func emit(module: SILModule) throws -> String {
        let builder = LLVMIRBuilder()
        builder.append("; ModuleID = '\(options.moduleName)'")
        builder.append("source_filename = \"\(escape(options.moduleName))\"")
        if let triple = options.targetTriple {
            builder.append("target triple = \"\(escape(triple))\"")
        }
        builder.append()

        var strings: [(name: String, bytes: [UInt8])] = []
        for function in module.functions {
            let functionBuilder = LLVMIRBuilder()
            let generator = IRGenFunction(function: function, builder: functionBuilder)
            let functionStrings = try generator.emit()
            strings.append(contentsOf: functionStrings)
            builder.append(functionBuilder.build().trimmingCharacters(in: .newlines))
        }

        if !strings.isEmpty {
            builder.append()
            for string in strings {
                let body = string.bytes.map { byte -> String in
                    switch byte {
                    case 10: return "\\0A"
                    case 13: return "\\0D"
                    case 9: return "\\09"
                    case 34: return "\\22"
                    case 92: return "\\5C"
                    default: return String(format: "\\%02X", Int(byte))
                    }
                }.joined()
                builder.append("@\(string.name) = private unnamed_addr constant [\(string.bytes.count) x i8] c\"\(body)\", align 1")
            }
        }

        return builder.build()
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
    }
}
