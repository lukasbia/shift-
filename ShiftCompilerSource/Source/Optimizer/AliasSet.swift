enum SILAliasKind: Hashable {
    case noAlias
    case mayAlias
    case mustAlias
}

struct SILAliasSet: Hashable {
    private(set) var values: Swift.Set<SILValue> = []

    mutating func insert(_ value: SILValue) {
        values.insert(value)
    }

    func contains(_ value: SILValue) -> Bool {
        values.contains(value)
    }

    var count: Int {
        values.count
    }
}
