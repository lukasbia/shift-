struct SILReachabilityAnalysis {
    let name = "ReachabilityAnalysis"

    func analyze(_ function: SILFunction) -> Swift.Set<SILBasicBlock.ID> {
        guard let entry = function.entryBlock else {
            return []
        }

        let cfg = SILCFG(function: function)
        var visited: Swift.Set<SILBasicBlock.ID> = []
        var worklist = [entry.id]

        while let id = worklist.popLast() {
            guard visited.insert(id).inserted else {
                continue
            }

            guard let block = cfg.block(with: id) else {
                continue
            }

            worklist.append(contentsOf: cfg.successors(of: block))
        }

        return visited
    }

    func isReachable(
        _ target: SILBasicBlock,
        in function: SILFunction
    ) -> Bool {
        analyze(function).contains(target.id)
    }
}
