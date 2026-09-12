final class SILSSAUpdater {
    private var availableValues: [SILBasicBlock.ID: SILValue] = [:]

    func setValue(_ value: SILValue, in block: SILBasicBlock) {
        availableValues[block.id] = value
    }

    func value(in block: SILBasicBlock) -> SILValue? {
        availableValues[block.id]
    }

    func clear() {
        availableValues.removeAll(keepingCapacity: true)
    }

    func values() -> [SILBasicBlock.ID: SILValue] {
        availableValues
    }
}
