struct SILSideEffectAnalysis {
    let name = "SideEffectAnalysis"

    func analyze(_ function: SILFunction) -> SILModRefInfo {
        var mayRead = false
        var mayWrite = false

        for block in function.blocks {
            for instruction in block.instructions {
                switch instruction.memoryBehavior {
                case .none:
                    continue
                case .read:
                    mayRead = true
                case .write:
                    mayWrite = true
                case .readWrite, .sideEffect:
                    mayRead = true
                    mayWrite = true
                }
            }
        }

        return SILModRefInfo(
            mayRead: mayRead,
            mayWrite: mayWrite
        )
    }

    func instructionMayHaveSideEffects(
        _ instruction: SILInstruction
    ) -> Bool {
        switch instruction.memoryBehavior {
        case .none:
            return false
        default:
            return true
        }
    }
}
