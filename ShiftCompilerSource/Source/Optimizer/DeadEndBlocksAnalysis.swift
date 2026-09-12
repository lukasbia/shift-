struct SILDeadEndBlocksAnalysis {
    let name = "DeadEndBlocksAnalysis"

    func analyze(_ function: SILFunction) -> Swift.Set<SILBasicBlock.ID> {
        let cfg = SILCFG(function: function)

        return Swift.Set(
            function.blocks
                .filter { cfg.isExit($0) }
                .map(\.id)
        )
    }

    func isDeadEnd(
        _ block: SILBasicBlock,
        in function: SILFunction
    ) -> Bool {
        analyze(function).contains(block.id)
    }
}
