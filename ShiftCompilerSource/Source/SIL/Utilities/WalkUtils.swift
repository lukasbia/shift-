enum SILWalkResult {
    case `continue`
    case skipChildren
    case stop
}

enum SILWalkUtils {
    static func walk(
        _ function: SILFunction,
        _ visitor: (SILBasicBlock) -> SILWalkResult
    ) {
        for block in function.blocks {
            switch visitor(block) {
            case .continue, .skipChildren:
                continue
            case .stop:
                return
            }
        }
    }

    static func walkInstructions(
        _ function: SILFunction,
        _ visitor: (SILInstruction) -> SILWalkResult
    ) {
        for block in function.blocks {
            for instruction in block.instructions {
                switch visitor(instruction) {
                case .continue, .skipChildren:
                    continue
                case .stop:
                    return
                }
            }
        }
    }

    static func instructions(
        in function: SILFunction
    ) -> [SILInstruction] {
        function.blocks.flatMap(\.instructions)
    }
}
