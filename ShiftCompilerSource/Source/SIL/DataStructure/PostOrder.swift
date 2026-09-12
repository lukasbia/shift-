struct PostOrder<Node: Hashable> {
    let nodes: [Node]

    init(graph: Graph<Node>, start: Node) {
        var visited: Swift.Set<Node> = []
        var result: [Node] = []

        func visit(_ node: Node) {
            guard visited.insert(node).inserted else {
                return
            }

            for successor in graph.successors(of: node) {
                visit(successor)
            }

            result.append(node)
        }

        visit(start)
        nodes = result
    }
}
