struct SILBranchProbability: Comparable, Hashable {
    let value: Double

    init(_ value: Double) {
        self.value = min(1.0, max(0.0, value))
    }

    static let never = Self(0)
    static let unlikely = Self(0.01)
    static let even = Self(0.5)
    static let likely = Self(0.99)
    static let always = Self(1)

    static func < (
        lhs: SILBranchProbability,
        rhs: SILBranchProbability
    ) -> Bool {
        lhs.value < rhs.value
    }
}

struct SILBranchProbabilities {
    private(set) var edges: [
        (from: SILBasicBlock.ID, to: SILBasicBlock.ID)
    : SILBranchProbability] = [:]

    mutating func set(
        from: SILBasicBlock.ID,
        to: SILBasicBlock.ID,
        probability: SILBranchProbability
    ) {
        edges[(from, to)] = probability
    }

    func probability(
        from: SILBasicBlock.ID,
        to: SILBasicBlock.ID
    ) -> SILBranchProbability {
        edges[(from, to)] ?? .even
    }
}
