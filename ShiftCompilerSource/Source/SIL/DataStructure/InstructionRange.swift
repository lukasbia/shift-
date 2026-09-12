struct InstructionRange: Sequence {
    private let instructions: [SILInstruction]

    init(_ instructions: [SILInstruction]) {
        self.instructions = instructions
    }

    var count: Int {
        instructions.count
    }

    var isEmpty: Bool {
        instructions.isEmpty
    }

    subscript(index: Int) -> SILInstruction {
        instructions[index]
    }

    func makeIterator() -> IndexingIterator<[SILInstruction]> {
        instructions.makeIterator()
    }
}
