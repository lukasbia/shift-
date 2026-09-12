struct SILLiveness {
    let liveIn: [SILBasicBlock.ID: Swift.Set<Int>]
    let liveOut: [SILBasicBlock.ID: Swift.Set<Int>]

    func isLiveIn(_ value: SILValue, at block: SILBasicBlock) -> Bool {
        liveIn[block.id]?.contains(value.id) ?? false
    }

    func isLiveOut(_ value: SILValue, at block: SILBasicBlock) -> Bool {
        liveOut[block.id]?.contains(value.id) ?? false
    }
}
