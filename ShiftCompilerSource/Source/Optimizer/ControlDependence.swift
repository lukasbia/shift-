struct SILControlDependence {
    private(set) var dependencies: [
        SILBasicBlock.ID: Swift.Set<SILBasicBlock.ID>
    ] = [:]

    init(function: SILFunction) {
        let cfg = SILCFG(function: function)
        let postDominance = SILPostDominatorTree(function: function)

        for block in function.blocks {
            let successors = cfg.successors(of: block)

            guard successors.count > 1 else {
                continue
            }

            for successor in successors {
                if !postDominance.postDominates(successor, block.id) {
                    dependencies[successor, default: []].insert(block.id)
                }
            }
        }
    }

    func controllingBlocks(
        of block: SILBasicBlock.ID
    ) -> Swift.Set<SILBasicBlock.ID> {
        dependencies[block] ?? []
    }
}

struct SILControlDependenceAnalysis {
    let name = "ControlDependenceAnalysis"

    func analyze(_ function: SILFunction) -> SILControlDependence {
        SILControlDependence(function: function)
    }
}
