struct SILLivenessAnalysis {
    let name = "LivenessAnalysis"

    func analyze(_ function: SILFunction) -> SILLiveness {
        let cfg = SILCFG(function: function)

        var use: [SILBasicBlock.ID: Swift.Set<Int>] = [:]
        var def: [SILBasicBlock.ID: Swift.Set<Int>] = [:]

        for block in function.blocks {
            var blockUse: Swift.Set<Int> = []
            var blockDef: Swift.Set<Int> = []

            for instruction in block.instructions {
                for value in instruction.usedValues
                    where !blockDef.contains(value.id) {
                    blockUse.insert(value.id)
                }

                for value in instruction.definedValues {
                    blockDef.insert(value.id)
                }
            }

            use[block.id] = blockUse
            def[block.id] = blockDef
        }

        var liveIn = Dictionary(
            uniqueKeysWithValues: function.blocks.map { ($0.id, Swift.Set<Int>()) }
        )
        var liveOut = liveIn

        var changed = true

        while changed {
            changed = false

            for block in function.blocks.reversed() {
                var newOut: Swift.Set<Int> = []

                for successor in cfg.successors(of: block) {
                    newOut.formUnion(liveIn[successor] ?? [])
                }

                var newIn = newOut
                newIn.subtract(def[block.id] ?? [])
                newIn.formUnion(use[block.id] ?? [])

                if newOut != liveOut[block.id] || newIn != liveIn[block.id] {
                    liveOut[block.id] = newOut
                    liveIn[block.id] = newIn
                    changed = true
                }
            }
        }

        return SILLiveness(liveIn: liveIn, liveOut: liveOut)
    }
}
