struct SILBlockFrequency {
    private(set) var values: [SILBasicBlock.ID: Double] = [:]

    subscript(block: SILBasicBlock.ID) -> Double {
        values[block, default: 0]
    }

    mutating func set(
        _ frequency: Double,
        for block: SILBasicBlock.ID
    ) {
        values[block] = max(0, frequency)
    }

    mutating func increment(
        _ amount: Double,
        for block: SILBasicBlock.ID
    ) {
        values[block, default: 0] += amount
    }
}

struct SILBlockFrequencyAnalysis {
    let name = "BlockFrequencyAnalysis"

    func analyze(_ function: SILFunction) -> SILBlockFrequency {
        guard let entry = function.entryBlock else {
            return SILBlockFrequency()
        }

        let cfg = SILCFG(function: function)
        var result = SILBlockFrequency()
        result.set(1, for: entry.id)

        var worklist = [entry.id]
        var iterations = 0

        while let id = worklist.popLast(), iterations < 10_000 {
            iterations += 1

            guard let block = cfg.block(with: id) else {
                continue
            }

            let successors = cfg.successors(of: block)

            guard !successors.isEmpty else {
                continue
            }

            let share = result[id] / Double(successors.count)

            for successor in successors {
                let old = result[successor]
                result.increment(share, for: successor)

                if result[successor] > old {
                    worklist.append(successor)
                }
            }
        }

        return result
    }
}
