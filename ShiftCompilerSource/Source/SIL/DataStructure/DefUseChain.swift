struct DefUseChain {
    private(set) var definition: SILValue
    private(set) var uses: [SILUse] = []

    init(definition: SILValue) {
        self.definition = definition
    }

    mutating func addUse(_ use: SILUse) {
        uses.append(use)
    }

    mutating func removeUse(_ use: SILUse) {
        uses.removeAll { $0 == use }
    }

    var hasUses: Bool {
        !uses.isEmpty
    }
}
