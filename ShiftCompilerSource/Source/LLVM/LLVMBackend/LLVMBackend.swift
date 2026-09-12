import Foundation

public final class LLVMBackend {
    public let toolchain: LLVMToolchain
    public let runner: ProcessRunner

    public init(toolchain: LLVMToolchain, runner: ProcessRunner = ProcessRunner()) {
        self.toolchain = toolchain
        self.runner = runner
    }

    public func emitAssembly(from llvmIR: URL, to output: URL, options: BackendOptions, target: TargetInfo) throws {
        try validateInput(llvmIR)
        try prepareOutput(output)
        var arguments = baseArguments(input: llvmIR, output: output, options: options, target: target)
        arguments.insert("-filetype=asm", at: 0)
        try runChecked(toolchain.llc, arguments)
    }

    public func emitObject(from llvmIR: URL, to output: URL, options: BackendOptions, target: TargetInfo) throws {
        try validateInput(llvmIR)
        try prepareOutput(output)
        var arguments = baseArguments(input: llvmIR, output: output, options: options, target: target)
        arguments.insert("-filetype=obj", at: 0)
        try runChecked(toolchain.llc, arguments)
    }

    private func baseArguments(input: URL, output: URL, options: BackendOptions, target: TargetInfo) -> [String] {
        var arguments = ["-mtriple=\(target.triple)", "-O\(options.optimizationLevel)"]
        if let cpu = target.cpu { arguments.append("-mcpu=\(cpu)") }
        if let features = target.features { arguments.append("-mattr=\(features)") }
        if options.debugInfo { arguments.append("-g") }
        if let relocationModel = options.relocationModel { arguments.append("-relocation-model=\(relocationModel)") }
        if let codeModel = options.codeModel { arguments.append("-code-model=\(codeModel)") }
        arguments.append(contentsOf: options.extraLLVMArguments)
        arguments.append(contentsOf: ["-o", output.path, input.path])
        return arguments
    }

    private func validateInput(_ url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw BackendError.inputFileNotFound(url.path)
        }
    }

    private func prepareOutput(_ url: URL) throws {
        let directory = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            throw BackendError.outputDirectoryCreationFailed(directory.path)
        }
    }

    private func runChecked(_ executable: String, _ arguments: [String]) throws {
        let result = try runner.run(executable, arguments: arguments)
        guard result.status == 0 else {
            throw BackendError.processFailed(tool: executable, arguments: arguments, status: result.status, output: result.output)
        }
    }
}
