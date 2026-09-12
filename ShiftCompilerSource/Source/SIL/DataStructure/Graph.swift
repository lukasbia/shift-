struct Graph<Node: Hashable> {
    private var edges: [Node: [Node]] = [:]

    mutating func addNode(_ node: Node) {
        edges[node, default: []]
    }

    mutating func addEdge(from: Node, to: Node) {
        edges[from, default: []].append(to)
        edges[to, default: []]
    }

    func successors(of node: Node) -> [Node] {
        edges[node] ?? []
    }

    var nodes: [Node] {
        Array(edges.keys)
    }
}
