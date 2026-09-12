import Foundation

public final class Linker {
    public let clang: String
    public let runner: ProcessRunner

    public init(clang: String, runner: ProcessRunner = ProcessRunner()) {
        self.clang = clang
        self.runner = runner
    }

    public func link(
        objects: [URL],
        to output: URL,
        target: TargetInfo,
        options: BackendOptions
    ) throws {
        guard !objects.isEmpty else {
            throw BackendError.ioFailure("no object files were supplied to the linker")
        }
        for object in objects where !FileManager.default.fileExists(atPath: object.path) {
            throw BackendError.inputFileNotFound(object.path)
        }

        let directory = output.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            throw BackendError.outputDirectoryCreationFailed(directory.path)
        }

        var arguments = ["-target", target.triple, "-o", output.path]
        if let linker = options.linker {
            arguments += ["-fuse-ld=\(linker)"]
        }
        arguments.append(contentsOf: objects.map(\.path))
        arguments.append(contentsOf: options.extraLinkerArguments)

        let result = try runner.run(clang, arguments: arguments)
        guard result.status == 0 else {
            throw BackendError.processFailed(tool: clang, arguments: arguments, status: result.status, output: result.output)
        }
    }
}
