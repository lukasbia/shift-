protocol GraphNode: Hashable {
    associatedtype NodeID: Hashable

    var graphNodeID: NodeID { get }
}
