struct SILLoopAnalysis {
    let name = "LoopAnalysis"

    func analyze(_ function: SILFunction) -> SILLoopInfo {
        let cfg = SILCFG(function: function)
        let dominance = SILDominatorTree(function: function)
        var loops: [SILLoop] = []

        for source in function.blocks {
            for target in cfg.successors(of: source) {
                guard dominance.dominates(target, source.id) else {
                    continue
                }

                var blocks: Swift.Set<SILBasicBlock.ID> = [
                    target,
                    source.id
                ]

                var worklist = [source.id]

                while let current = worklist.popLast() {
                    guard let currentBlock = cfg.block(with: current) else {
                        continue
                    }

                    for predecessor in cfg.predecessors(of: currentBlock) {
                        if blocks.insert(predecessor).inserted {
                            worklist.append(predecessor)
                        }
                    }
                }

                loops.append(
                    SILLoop(
                        header: target,
                        latch: source.id,
                        blocks: blocks
                    )
                )
            }
        }

        return SILLoopInfo(loops: loops)
    }
}
