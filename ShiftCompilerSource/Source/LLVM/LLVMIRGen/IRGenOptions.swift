public struct IRGenOptions: Equatable, Sendable {
    public var moduleName: String
    public var targetTriple: String?
    public var emitComments: Bool
    public var verify: Bool

    public init(moduleName: String = "ShiftModule", targetTriple: String? = nil, emitComments: Bool = true, verify: Bool = true) {
        self.moduleName = moduleName
        self.targetTriple = targetTriple
        self.emitComments = emitComments
        self.verify = verify
    }
}
