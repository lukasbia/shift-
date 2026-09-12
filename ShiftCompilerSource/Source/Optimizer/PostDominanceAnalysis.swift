struct SILPostDominanceAnalysis {
    let name = "PostDominanceAnalysis"

    func analyze(_ function: SILFunction) -> SILPostDominatorTree {
        SILPostDominatorTree(function: function)
    }
}
