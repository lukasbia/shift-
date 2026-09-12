struct SILAnalysisPipeline {
    let manager: SILAnalysisManager

    init(manager: SILAnalysisManager = SILAnalysisManager()) {
        self.manager = manager
    }

    func prepare(_ function: SILFunction) {
        _ = manager.cfg(function)
        _ = manager.dominance(function)
        _ = manager.postDominance(function)
        _ = manager.reachability(function)
        _ = manager.deadEnds(function)
        _ = manager.loops(function)
        _ = manager.callees(function)
        _ = manager.defUse(function)
        _ = manager.liveness(function)
        _ = manager.aliases(function)
        _ = manager.sideEffects(function)
        _ = manager.captures(function)
        _ = manager.controlDependence(function)
        _ = manager.blockFrequency(function)
    }
}
