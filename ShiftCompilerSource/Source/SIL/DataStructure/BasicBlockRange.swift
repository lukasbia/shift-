struct BasicBlockRange: Sequence {
    private let blocks: [SILBasicBlock]

    init(_ blocks: [SILBasicBlock]) {
        self.blocks = blocks
    }

    var count: Int {
        blocks.count
    }

    var isEmpty: Bool {
        blocks.isEmpty
    }

    subscript(index: Int) -> SILBasicBlock {
        blocks[index]
    }

    func makeIterator() -> IndexingIterator<[SILBasicBlock]> {
        blocks.makeIterator()
    }
}
