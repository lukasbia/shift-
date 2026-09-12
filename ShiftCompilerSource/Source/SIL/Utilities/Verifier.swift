struct SILVerificationError: Error, CustomStringConvertible {
    let message: String

    var description: String {
        message
    }
}

struct SILVerifier {
    func verify(_ module: SILModule) throws {
        for function in module.functions {
            try verify(function)
        }
    }

    func verify(_ function: SILFunction) throws {
        guard !function.blocks.isEmpty else {
            throw SILVerificationError(
                message: "function '\\(function.name)' has no basic blocks"
            )
        }

        for block in function.blocks {
            guard !block.instructions.isEmpty else {
                throw SILVerificationError(
                    message: "basic block '\\(block.id.name)' is empty"
                )
            }

            guard block.terminator != nil else {
                throw SILVerificationError(
                    message: "basic block '\\(block.id.name)' has no terminator"
                )
            }

            try verifyTerminators(in: block)
        }
    }

    private func verifyTerminators(in block: SILBasicBlock) throws {
        guard let terminator = block.terminator else {
            return
        }

        switch terminator {
        case .branch(let target):
            guard target != block.id else {
                throw SILVerificationError(
                    message: "basic block branches to itself without a loop condition"
                )
            }

        case .conditionalBranch(let condition, _, _):
            guard condition.type == .bool else {
                throw SILVerificationError(
                    message: "conditional branch requires Bool condition"
                )
            }

        case .returnValue(let value):
            guard value.type == expectedReturnType(of: block) else {
                throw SILVerificationError(
                    message: "return value has incorrect type"
                )
            }

        case .returnVoid:
            break

        default:
            break
        }
    }

    private func expectedReturnType(of block: SILBasicBlock) -> SILType {
        // The function-level verifier will be extended once SILBasicBlock carries
        // an owning SILFunction reference. Keeping this helper isolates that change.
        if case .returnValue(let value) = block.instructions.last {
            return value.type
        }

        return .void
    }
}
