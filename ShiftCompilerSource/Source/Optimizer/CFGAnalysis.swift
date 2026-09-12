struct SILCFGAnalysis {
    let name = "CFGAnalysis"

    func analyze(_ function: SILFunction) -> SILCFG {
        SILCFG(function: function)
    }

    func predecessors(
        of block: SILBasicBlock,
        in function: SILFunction
    ) -> [SILBasicBlock.ID] {
        SILCFG(function: function).predecessors(of: block)
    }

    func successors(
        of block: SILBasicBlock,
        in function: SILFunction
    ) -> [SILBasicBlock.ID] {
        SILCFG(function: function).successors(of: block)
    }

    func isCriticalEdge(
        from predecessor: SILBasicBlock,
        to successor: SILBasicBlock,
        in function: SILFunction
    ) -> Bool {
        let cfg = SILCFG(function: function)

        return cfg.successors(of: predecessor).count > 1 &&
               cfg.predecessors(of: successor).count > 1
    }
}
