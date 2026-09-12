struct SILCalleeSummary: Hashable {
    let functionName: String
    let directCallees: Swift.Set<String>
}

struct SILBasicCalleeAnalysis {
    let name = "BasicCalleeAnalysis"

    func analyze(_ function: SILFunction) -> SILCalleeSummary {
        var callees: Swift.Set<String> = []

        for block in function.blocks {
            for instruction in block.instructions {
                if case .functionRef(_, let name, _) = instruction {
                    callees.insert(name)
                }
            }
        }

        return SILCalleeSummary(
            functionName: function.name,
            directCallees: callees
        )
    }

    func analyze(_ module: SILModule) -> [String: SILCalleeSummary] {
        Dictionary(
            uniqueKeysWithValues: module.functions.map {
                ($0.name, analyze($0))
            }
        )
    }
}
