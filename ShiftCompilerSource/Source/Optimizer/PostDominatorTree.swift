struct SILPostDominatorTree {
    private(set) var postDominators: [
        SILBasicBlock.ID: Swift.Set<SILBasicBlock.ID>
    ]

    init(function: SILFunction) {
        let cfg = SILCFG(function: function)
        let blocks = function.blocks
        let exits = blocks.filter { cfg.isExit($0) }
        let all = Swift.Set(blocks.map(\.id))

        var result: [SILBasicBlock.ID: Swift.Set<SILBasicBlock.ID>] = [:]

        for block in blocks {
            result[block.id] = exits.contains(where: { $0.id == block.id })
                ? [block.id]
                : all
        }

        var changed = true

        while changed {
            changed = false

            for block in blocks where !exits.contains(where: { $0.id == block.id }) {
                let successors = cfg.successors(of: block)

                guard let first = successors.first else {
                    continue
                }

                var next = result[first] ?? all

                for successor in successors.dropFirst() {
                    next.formIntersection(result[successor] ?? all)
                }

                next.insert(block.id)

                if result[block.id] != next {
                    result[block.id] = next
                    changed = true
                }
            }
        }

        postDominators = result
    }

    func postDominates(
        _ dominator: SILBasicBlock.ID,
        _ block: SILBasicBlock.ID
    ) -> Bool {
        postDominators[block]?.contains(dominator) ?? false
    }
}
