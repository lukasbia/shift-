import Foundation

public final class Backend {
    public let llvm: LLVMBackend
    public let linker: Linker

    public init(toolchain: LLVMToolchain) {
        self.llvm = LLVMBackend(toolchain: toolchain)
        self.linker = Linker(clang: toolchain.clang)
    }

    public func compile(
        llvmIR: URL,
        output: URL,
        options: BackendOptions = BackendOptions(),
        target: TargetInfo = .host()
    ) throws {
        switch options.outputKind {
        case .assembly:
            try llvm.emitAssembly(from: llvmIR, to: output, options: options, target: target)
        case .object:
            try llvm.emitObject(from: llvmIR, to: output, options: options, target: target)
        case .executable:
            let object = output.deletingPathExtension().appendingPathExtension("o")
            try llvm.emitObject(from: llvmIR, to: object, options: options, target: target)
            try linker.link(objects: [object], to: output, target: target, options: options)
            try? FileManager.default.removeItem(at: object)
        }
    }
}
