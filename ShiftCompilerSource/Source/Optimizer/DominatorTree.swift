struct SILDominatorTree {
    private(set) var dominators: [SILBasicBlock.ID: Swift.Set<SILBasicBlock.ID>]
    private(set) var immediateDominator: [SILBasicBlock.ID: SILBasicBlock.ID?]

    init(function: SILFunction) {
        let cfg = SILCFG(function: function)
        let blocks = function.blocks

        guard let entry = function.entryBlock else {
            dominators = [:]
            immediateDominator = [:]
            return
        }

        let all = Swift.Set(blocks.map(\.id))
        var dom: [SILBasicBlock.ID: Swift.Set<SILBasicBlock.ID>] = [:]

        for block in blocks {
            dom[block.id] = block.id == entry.id ? [entry.id] : all
        }

        var changed = true
        while changed {
            changed = false

            for block in blocks where block.id != entry.id {
                let predecessors = cfg.predecessors(of: block)

                guard let first = predecessors.first else {
                    continue
                }

                var next = dom[first] ?? all

                for predecessor in predecessors.dropFirst() {
                    next.formIntersection(dom[predecessor] ?? all)
                }

                next.insert(block.id)

                if dom[block.id] != next {
                    dom[block.id] = next
                    changed = true
                }
            }
        }

        var idom: [SILBasicBlock.ID: SILBasicBlock.ID?] = [
            entry.id: nil
        ]

        for block in blocks where block.id != entry.id {
            let strict = (dom[block.id] ?? []).subtracting([block.id])

            let candidate = strict.first { candidate in
                strict.allSatisfy { other in
                    other == candidate ||
                    !(dom[other] ?? []).contains(candidate)
                }
            }

            idom[block.id] = candidate
        }

        dominators = dom
        immediateDominator = idom
    }

    func dominates(
        _ dominator: SILBasicBlock.ID,
        _ block: SILBasicBlock.ID
    ) -> Bool {
        dominators[block]?.contains(dominator) ?? false
    }

    func children(of block: SILBasicBlock.ID) -> [SILBasicBlock.ID] {
        immediateDominator.compactMap { child, parent in
            parent == block ? child : nil
        }
    }
}
