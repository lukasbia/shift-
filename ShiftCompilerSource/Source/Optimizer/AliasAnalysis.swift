struct SILAliasAnalysis {
    let name = "AliasAnalysis"

    func alias(
        _ lhs: SILValue,
        _ rhs: SILValue
    ) -> SILAliasKind {
        if lhs == rhs {
            return .mustAlias
        }

        switch (lhs.type, rhs.type) {
        case (.pointer, .pointer):
            return .mayAlias
        default:
            return .noAlias
        }
    }

    func analyze(_ function: SILFunction) -> [SILValue: SILAliasSet] {
        var result: [SILValue: SILAliasSet] = [:]

        for block in function.blocks {
            for instruction in block.instructions {
                for value in instruction.definedValues {
                    if case .pointer = value.type {
                        var set = result[value] ?? SILAliasSet()
                        set.insert(value)
                        result[value] = set
                    }
                }
            }
        }

        return result
    }
}
