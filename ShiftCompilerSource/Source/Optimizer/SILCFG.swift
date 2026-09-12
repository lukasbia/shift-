struct SILCFG {
    let function: SILFunction

    init(function: SILFunction) {
        self.function = function
    }

    func successors(of block: SILBasicBlock) -> [SILBasicBlock.ID] {
        guard let instruction = block.instructions.last else {
            return []
        }

        switch instruction {
        case .branch(let target):
            return [target]

        case .conditionalBranch(_, let trueBlock, let falseBlock):
            return [trueBlock, falseBlock]

        default:
            return []
        }
    }

    func predecessors(of block: SILBasicBlock) -> [SILBasicBlock.ID] {
        function.blocks.compactMap { candidate in
            successors(of: candidate).contains(block.id) ? candidate.id : nil
        }
    }

    func block(with id: SILBasicBlock.ID) -> SILBasicBlock? {
        function.blocks.first { $0.id == id }
    }

    func hasEdge(from: SILBasicBlock.ID, to: SILBasicBlock.ID) -> Bool {
        guard let block = block(with: from) else {
            return false
        }
        return successors(of: block).contains(to)
    }

    func isExit(_ block: SILBasicBlock) -> Bool {
        successors(of: block).isEmpty
    }
}
