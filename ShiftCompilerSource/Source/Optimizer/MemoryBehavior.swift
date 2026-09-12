enum SILMemoryBehavior: Hashable {
    case none
    case read
    case write
    case readWrite
    case sideEffect
}

extension SILInstruction {
    var memoryBehavior: SILMemoryBehavior {
        switch self {
        case .load:
            return .read

        case .store:
            return .write

        case .allocStack,
             .deallocStack,
             .integerLiteral,
             .unsignedIntegerLiteral,
             .floatingLiteral,
             .stringLiteral,
             .characterLiteral,
             .booleanLiteral,
             .add,
             .subtract,
             .multiply,
             .divide,
             .remainder,
             .bitwiseAnd,
             .bitwiseOr,
             .bitwiseXor,
             .equal,
             .notEqual,
             .lessThan,
             .lessOrEqual,
             .greaterThan,
             .greaterEqual,
             .logicalAnd,
             .logicalOr,
             .logicalNot,
             .negate,
             .bitwiseNot,
             .convert,
             .functionRef,
             .makeTuple,
             .tupleExtract,
             .makeArray,
             .arrayElementAddress,
             .addressOf,
             .pointerToAddress,
             .addressToPointer,
             .branch,
             .conditionalBranch,
             .returnValue,
             .returnVoid,
             .debugValue:
            return .none

        case .apply:
            return .sideEffect
        }
    }
}
