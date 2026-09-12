struct SILDefUseInfo {
    private(set) var definitions: [Int: SILInstruction] = [:]
    private(set) var uses: [Int: [SILBasicBlock.ID]] = [:]

    mutating func define(_ value: SILValue, by instruction: SILInstruction) {
        definitions[value.id] = instruction
    }

    mutating func use(
        _ value: SILValue,
        in block: SILBasicBlock.ID
    ) {
        uses[value.id, default: []].append(block)
    }

    func definition(of value: SILValue) -> SILInstruction? {
        definitions[value.id]
    }

    func useCount(of value: SILValue) -> Int {
        uses[value.id]?.count ?? 0
    }
}

struct SILDefUseAnalysis {
    let name = "DefUseAnalysis"

    func analyze(_ function: SILFunction) -> SILDefUseInfo {
        var result = SILDefUseInfo()

        for block in function.blocks {
            for instruction in block.instructions {
                for value in instruction.definedValues {
                    result.define(value, by: instruction)
                }

                for value in instruction.usedValues {
                    result.use(value, in: block.id)
                }
            }
        }

        return result
    }
}

extension SILInstruction {
    var definedValues: [SILValue] {
        switch self {
        case .allocStack(let value),
             .load(let value, _),
             .integerLiteral(let value, _),
             .unsignedIntegerLiteral(let value, _),
             .floatingLiteral(let value, _),
             .stringLiteral(let value, _),
             .characterLiteral(let value, _),
             .booleanLiteral(let value, _),
             .add(let value, _, _),
             .subtract(let value, _, _),
             .multiply(let value, _, _),
             .divide(let value, _, _),
             .remainder(let value, _, _),
             .bitwiseAnd(let value, _, _),
             .bitwiseOr(let value, _, _),
             .bitwiseXor(let value, _, _),
             .equal(let value, _, _),
             .notEqual(let value, _, _),
             .lessThan(let value, _, _),
             .lessOrEqual(let value, _, _),
             .greaterThan(let value, _, _),
             .greaterEqual(let value, _, _),
             .logicalAnd(let value, _, _),
             .logicalOr(let value, _, _),
             .logicalNot(let value, _),
             .negate(let value, _),
             .bitwiseNot(let value, _),
             .convert(let value, _, _),
             .functionRef(let value, _, _),
             .makeTuple(let value, _),
             .tupleExtract(let value, _, _),
             .makeArray(let value, _),
             .arrayElementAddress(let value, _, _),
             .addressOf(let value, _),
             .pointerToAddress(let value, _),
             .addressToPointer(let value, _),
             .debugValue(let value, _):
            return [value]

        case .apply(let value, _, _):
            return value.map { [$0] } ?? []

        case .deallocStack, .store, .branch, .conditionalBranch,
             .returnValue, .returnVoid:
            return []
        }
    }

    var usedValues: [SILValue] {
        switch self {
        case .allocStack,
             .integerLiteral,
             .unsignedIntegerLiteral,
             .floatingLiteral,
             .stringLiteral,
             .characterLiteral,
             .booleanLiteral,
             .functionRef:
            return []

        case .deallocStack(let value),
             .logicalNot(_, let value),
             .negate(_, let value),
             .bitwiseNot(_, let value),
             .addressOf(_, let value),
             .pointerToAddress(_, let value),
             .addressToPointer(_, let value),
             .returnValue(let value),
             .debugValue(let value, _):
            return [value]

        case .load(_, let address):
            return [address]

        case .store(let value, let address):
            return [value, address]

        case .add(_, let lhs, let rhs),
             .subtract(_, let lhs, let rhs),
             .multiply(_, let lhs, let rhs),
             .divide(_, let lhs, let rhs),
             .remainder(_, let lhs, let rhs),
             .bitwiseAnd(_, let lhs, let rhs),
             .bitwiseOr(_, let lhs, let rhs),
             .bitwiseXor(_, let lhs, let rhs),
             .equal(_, let lhs, let rhs),
             .notEqual(_, let lhs, let rhs),
             .lessThan(_, let lhs, let rhs),
             .lessOrEqual(_, let lhs, let rhs),
             .greaterThan(_, let lhs, let rhs),
             .greaterEqual(_, let lhs, let rhs),
             .logicalAnd(_, let lhs, let rhs),
             .logicalOr(_, let lhs, let rhs):
            return [lhs, rhs]

        case .convert(_, let value, _):
            return [value]

        case .apply(_, let function, let arguments):
            return [function] + arguments

        case .makeTuple(_, let values),
             .makeArray(_, let values):
            return values

        case .tupleExtract(_, let tuple, _):
            return [tuple]

        case .arrayElementAddress(_, let array, let index):
            return [array, index]

        case .branch, .conditionalBranch, .returnVoid:
            return []
        }
    }
}
