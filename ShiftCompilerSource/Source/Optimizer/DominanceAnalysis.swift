final class SILDominanceAnalysis {
    let name = "DominanceAnalysis"

    private var cache: [ObjectIdentifier: SILDominatorTree] = [:]

    func analyze(_ function: SILFunction) -> SILDominatorTree {
        let key = ObjectIdentifier(function)

        if let result = cache[key] {
            return result
        }

        let result = SILDominatorTree(function: function)
        cache[key] = result
        return result
    }

    func invalidate(_ function: SILFunction) {
        cache.removeValue(forKey: ObjectIdentifier(function))
    }

    func clear() {
        cache.removeAll(keepingCapacity: true)
    }
}
