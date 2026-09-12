public struct IRGenValue: Equatable {
    public let type: LLVMType
    public let operand: String

    public init(type: LLVMType, operand: String) {
        self.type = type
        self.operand = operand
    }
}
