struct SmallProjectionPath: Hashable {
    enum Component: Hashable {
        case tupleElement(Int)
        case arrayElement(Int)
        case member(String)
    }

    private(set) var components: [Component] = []

    init() {}

    mutating func append(_ component: Component) {
        components.append(component)
    }

    func appending(_ component: Component) -> SmallProjectionPath {
        var result = self
        result.append(component)
        return result
    }

    var isEmpty: Bool {
        components.isEmpty
    }

    var count: Int {
        components.count
    }
}
