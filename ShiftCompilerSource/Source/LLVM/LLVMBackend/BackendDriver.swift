import Foundation

public final class BackendDriver {
    public let backend: Backend

    public init(toolchain: LLVMToolchain? = nil) throws {
        self.backend = Backend(toolchain: try toolchain ?? LLVMToolchain.discover())
    }

    public func compile(
        llvmIRPath: String,
        outputPath: String,
        options: BackendOptions = BackendOptions(),
        target: TargetInfo? = nil
    ) throws {
        let input = URL(fileURLWithPath: llvmIRPath).standardizedFileURL
        let output = URL(fileURLWithPath: outputPath).standardizedFileURL
        let targetInfo = try target ?? TargetInfo(
            triple: options.targetTriple ?? TargetInfo.host().triple,
            cpu: options.cpu,
            features: options.features
        )
        try backend.compile(llvmIR: input, output: output, options: options, target: targetInfo)
    }
}
