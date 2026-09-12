struct SILAnalysisInvalidation: OptionSet, Hashable {
    let rawValue: UInt

    static let none = Self(rawValue: 0)
    static let instructions = Self(rawValue: 1 << 0)
    static let controlFlow = Self(rawValue: 1 << 1)
    static let memory = Self(rawValue: 1 << 2)
    static let calls = Self(rawValue: 1 << 3)
    static let function = Self(rawValue: 1 << 4)

    static let everything: Self = [
        .instructions,
        .controlFlow,
        .memory,
        .calls,
        .function
    ]
}
