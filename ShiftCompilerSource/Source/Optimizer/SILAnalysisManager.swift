final class SILAnalysisManager {
    private let cache = SILAnalysisCache()

    private let cfgAnalysis = SILCFGAnalysis()
    private let dominanceAnalysis = SILDominanceAnalysis()
    private let postDominanceAnalysis = SILPostDominanceAnalysis()
    private let reachabilityAnalysis = SILReachabilityAnalysis()
    private let deadEndAnalysis = SILDeadEndBlocksAnalysis()
    private let loopAnalysis = SILLoopAnalysis()
    private let calleeAnalysis = SILBasicCalleeAnalysis()
    private let defUseAnalysis = SILDefUseAnalysis()
    private let livenessAnalysis = SILLivenessAnalysis()
    private let aliasAnalysis = SILAliasAnalysis()
    private let sideEffectAnalysis = SILSideEffectAnalysis()
    private let captureAnalysis = SILCaptureAnalysis()
    private let controlDependenceAnalysis = SILControlDependenceAnalysis()
    private let frequencyAnalysis = SILBlockFrequencyAnalysis()

    func cfg(_ function: SILFunction) -> SILCFG {
        if let result: SILCFG = cache.get(.cfg, for: function) {
            return result
        }

        let result = cfgAnalysis.analyze(function)
        cache.set(result, for: .cfg, function: function)
        return result
    }

    func dominance(_ function: SILFunction) -> SILDominatorTree {
        if let result: SILDominatorTree = cache.get(.dominance, for: function) {
            return result
        }

        let result = dominanceAnalysis.analyze(function)
        cache.set(result, for: .dominance, function: function)
        return result
    }

    func postDominance(_ function: SILFunction) -> SILPostDominatorTree {
        if let result: SILPostDominatorTree = cache.get(.postDominance, for: function) {
            return result
        }

        let result = postDominanceAnalysis.analyze(function)
        cache.set(result, for: .postDominance, function: function)
        return result
    }

    func reachability(_ function: SILFunction) -> Swift.Set<SILBasicBlock.ID> {
        if let result: Swift.Set<SILBasicBlock.ID> = cache.get(.reachability, for: function) {
            return result
        }

        let result = reachabilityAnalysis.analyze(function)
        cache.set(result, for: .reachability, function: function)
        return result
    }

    func deadEnds(_ function: SILFunction) -> Swift.Set<SILBasicBlock.ID> {
        if let result: Swift.Set<SILBasicBlock.ID> = cache.get(.deadEndBlocks, for: function) {
            return result
        }

        let result = deadEndAnalysis.analyze(function)
        cache.set(result, for: .deadEndBlocks, function: function)
        return result
    }

    func loops(_ function: SILFunction) -> SILLoopInfo {
        if let result: SILLoopInfo = cache.get(.loops, for: function) {
            return result
        }

        let result = loopAnalysis.analyze(function)
        cache.set(result, for: .loops, function: function)
        return result
    }

    func callees(_ function: SILFunction) -> SILCalleeSummary {
        if let result: SILCalleeSummary = cache.get(.callee, for: function) {
            return result
        }

        let result = calleeAnalysis.analyze(function)
        cache.set(result, for: .callee, function: function)
        return result
    }

    func defUse(_ function: SILFunction) -> SILDefUseInfo {
        if let result: SILDefUseInfo = cache.get(.defUse, for: function) {
            return result
        }

        let result = defUseAnalysis.analyze(function)
        cache.set(result, for: .defUse, function: function)
        return result
    }

    func liveness(_ function: SILFunction) -> SILLiveness {
        if let result: SILLiveness = cache.get(.liveness, for: function) {
            return result
        }

        let result = livenessAnalysis.analyze(function)
        cache.set(result, for: .liveness, function: function)
        return result
    }

    func aliases(_ function: SILFunction) -> [SILValue: SILAliasSet] {
        if let result: [SILValue: SILAliasSet] = cache.get(.alias, for: function) {
            return result
        }

        let result = aliasAnalysis.analyze(function)
        cache.set(result, for: .alias, function: function)
        return result
    }

    func sideEffects(_ function: SILFunction) -> SILModRefInfo {
        if let result: SILModRefInfo = cache.get(.sideEffects, for: function) {
            return result
        }

        let result = sideEffectAnalysis.analyze(function)
        cache.set(result, for: .sideEffects, function: function)
        return result
    }

    func captures(_ function: SILFunction) -> SILCaptureInfo {
        if let result: SILCaptureInfo = cache.get(.capture, for: function) {
            return result
        }

        let result = captureAnalysis.analyze(function)
        cache.set(result, for: .capture, function: function)
        return result
    }

    func controlDependence(_ function: SILFunction) -> SILControlDependence {
        if let result: SILControlDependence = cache.get(.controlDependence, for: function) {
            return result
        }

        let result = controlDependenceAnalysis.analyze(function)
        cache.set(result, for: .controlDependence, function: function)
        return result
    }

    func blockFrequency(_ function: SILFunction) -> SILBlockFrequency {
        if let result: SILBlockFrequency = cache.get(.blockFrequency, for: function) {
            return result
        }

        let result = frequencyAnalysis.analyze(function)
        cache.set(result, for: .blockFrequency, function: function)
        return result
    }

    func invalidate(
        _ function: SILFunction,
        dueTo invalidation: SILAnalysisInvalidation
    ) {
        cache.invalidate(function, invalidation)
        dominanceAnalysis.invalidate(function)
    }

    func clear() {
        cache.clear()
        dominanceAnalysis.clear()
    }
}
