import Foundation

public struct LLVMToolchain: Equatable, Sendable {
    public let llc: String
    public let clang: String
    public let llvmConfig: String?

    public init(llc: String, clang: String, llvmConfig: String? = nil) {
        self.llc = llc
        self.clang = clang
        self.llvmConfig = llvmConfig
    }

    public static func discover(environment: [String: String] = ProcessInfo.processInfo.environment) throws -> LLVMToolchain {
        let llc = try findTool(named: environment["SHIFT_LLC"] ?? "llc", environment: environment)
        let clang = try findTool(named: environment["SHIFT_CLANG"] ?? "clang", environment: environment)
        let llvmConfig = try? findTool(named: environment["SHIFT_LLVM_CONFIG"] ?? "llvm-config", environment: environment)
        return LLVMToolchain(llc: llc, clang: clang, llvmConfig: llvmConfig)
    }

    private static func findTool(named name: String, environment: [String: String]) throws -> String {
        if name.contains("/") {
            guard FileManager.default.isExecutableFile(atPath: name) else {
                throw BackendError.toolNotFound(name)
            }
            return name
        }

        let path = environment["PATH"] ?? ""
        for directory in path.split(separator: ":", omittingEmptySubsequences: true) {
            let candidate = URL(fileURLWithPath: String(directory)).appendingPathComponent(name).path
            if FileManager.default.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }
        throw BackendError.toolNotFound(name)
    }
}
