struct SILUse: Hashable {
    let userID: Int
    let operandIndex: Int
}

struct UseList {
    private var uses: [Int: Swift.Set<SILUse>] = [:]

    mutating func addUse(of value: SILValue, by use: SILUse) {
        uses[value.id, default: []].insert(use)
    }

    mutating func removeUse(of value: SILValue, by use: SILUse) {
        uses[value.id]?.remove(use)
    }

    func uses(of value: SILValue) -> Swift.Set<SILUse> {
        uses[value.id] ?? []
    }
}
