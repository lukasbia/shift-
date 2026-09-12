struct SILIndex: Comparable, Hashable, Strideable {
    let rawValue: Int

    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }

    static func < (lhs: SILIndex, rhs: SILIndex) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    func distance(to other: SILIndex) -> Int {
        other.rawValue - rawValue
    }

    func advanced(by n: Int) -> SILIndex {
        SILIndex(rawValue + n)
    }
}
