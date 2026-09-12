import Foundation

public enum BackendOutputKind: String, Sendable {
    case assembly = "asm"
    case object = "object"
    case executable = "executable"
}

public struct BackendOptions: Equatable, Sendable {
    public var outputKind: BackendOutputKind
    public var targetTriple: String?
    public var cpu: String?
    public var features: String?
    public var optimizationLevel: Int
    public var debugInfo: Bool
    public var relocationModel: String?
    public var codeModel: String?
    public var linker: String?
    public var extraLLVMArguments: [String]
    public var extraLinkerArguments: [String]

    public init(
        outputKind: BackendOutputKind = .object,
        targetTriple: String? = nil,
        cpu: String? = nil,
        features: String? = nil,
        optimizationLevel: Int = 0,
        debugInfo: Bool = false,
        relocationModel: String? = nil,
        codeModel: String? = nil,
        linker: String? = nil,
        extraLLVMArguments: [String] = [],
        extraLinkerArguments: [String] = []
    ) {
        self.outputKind = outputKind
        self.targetTriple = targetTriple
        self.cpu = cpu
        self.features = features
        self.optimizationLevel = min(max(optimizationLevel, 0), 3)
        self.debugInfo = debugInfo
        self.relocationModel = relocationModel
        self.codeModel = codeModel
        self.linker = linker
        self.extraLLVMArguments = extraLLVMArguments
        self.extraLinkerArguments = extraLinkerArguments
    }
}
