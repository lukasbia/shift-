protocol SILAnalysis {
    associatedtype Result

    var name: String { get }

    func analyze(_ function: SILFunction) -> Result

    func invalidate(
        _ result: Result,
        dueTo invalidation: SILAnalysisInvalidation
    ) -> Bool
}

extension SILAnalysis {
    func invalidate(
        _ result: Result,
        dueTo invalidation: SILAnalysisInvalidation
    ) -> Bool {
        invalidation != .none
    }
}

enum SILAnalysisKind: Hashable {
    case cfg
    case dominance
    case postDominance
    case reachability
    case deadEndBlocks
    case loops
    case callee
    case functionOrder
    case defUse
    case liveness
    case alias
    case sideEffects
    case capture
    case controlDependence
    case branchProbability
    case blockFrequency
}
