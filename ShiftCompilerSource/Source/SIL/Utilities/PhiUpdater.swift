struct SILPhiUpdater {
    private(set) var incoming: [SILBasicBlock.ID: SILValue] = [:]

    mutating func addIncoming(
        value: SILValue,
        from block: SILBasicBlock
    ) {
        incoming[block.id] = value
    }

    mutating func removeIncoming(from block: SILBasicBlock) {
        incoming.removeValue(forKey: block.id)
    }

    func value(from block: SILBasicBlock) -> SILValue? {
        incoming[block.id]
    }

    var predecessorCount: Int {
        incoming.count
    }
}
