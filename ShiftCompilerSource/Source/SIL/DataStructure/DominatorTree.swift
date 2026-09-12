struct DominatorTree<Node: Hashable> {
    private var dominators: [Node: Swift.Set<Node>] = [:]

    func dominates(_ dominator: Node, _ node: Node) -> Bool {
        dominators[node]?.contains(dominator) ?? false
    }

    mutating func setDominators(
        of node: Node,
        to dominators: Swift.Set<Node>
    ) {
        self.dominators[node] = dominators
    }

    func dominators(of node: Node) -> Swift.Set<Node> {
        dominators[node] ?? []
    }
}
