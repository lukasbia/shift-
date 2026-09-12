struct ReversePostOrder<Node: Hashable> {
    let nodes: [Node]

    init(graph: Graph<Node>, start: Node) {
        nodes = PostOrder(graph: graph, start: start).nodes.reversed()
    }
}
