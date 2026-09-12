final class SILAnalysisCache {
    private var storage: [
        ObjectIdentifier: [SILAnalysisKind: Any]
    ] = [:]

    func get<Result>(
        _ kind: SILAnalysisKind,
        for function: SILFunction
    ) -> Result? {
        storage[ObjectIdentifier(function)]?[kind] as? Result
    }

    func set<Result>(
        _ result: Result,
        for kind: SILAnalysisKind,
        function: SILFunction
    ) {
        storage[ObjectIdentifier(function), default: [:]][kind] = result
    }

    func invalidate(
        _ function: SILFunction,
        _ invalidation: SILAnalysisInvalidation
    ) {
        if invalidation.contains(.controlFlow) {
            invalidate(
                function,
                kinds: [
                    .cfg,
                    .dominance,
                    .postDominance,
                    .reachability,
                    .deadEndBlocks,
                    .loops,
                    .liveness,
                    .controlDependence,
                    .branchProbability,
                    .blockFrequency
                ]
            )
        }

        if invalidation.contains(.instructions) {
            invalidate(
                function,
                kinds: [
                    .defUse,
                    .liveness,
                    .alias,
                    .sideEffects,
                    .capture
                ]
            )
        }

        if invalidation.contains(.memory) {
            invalidate(
                function,
                kinds: [
                    .alias,
                    .sideEffects,
                    .capture
                ]
            )
        }

        if invalidation.contains(.calls) {
            invalidate(
                function,
                kinds: [
                    .callee,
                    .functionOrder,
                    .sideEffects
                ]
            )
        }

        if invalidation.contains(.function) {
            storage.removeValue(forKey: ObjectIdentifier(function))
        }
    }

    func clear() {
        storage.removeAll(keepingCapacity: true)
    }

    private func invalidate(
        _ function: SILFunction,
        kinds: [SILAnalysisKind]
    ) {
        let key = ObjectIdentifier(function)

        for kind in kinds {
            storage[key]?[kind] = nil
        }
    }
}
