struct SILLoop: Hashable {
    let header: SILBasicBlock.ID
    let latch: SILBasicBlock.ID
    let blocks: Swift.Set<SILBasicBlock.ID>

    var count: Int {
        blocks.count
    }

    func contains(_ block: SILBasicBlock.ID) -> Bool {
        blocks.contains(block)
    }
}
