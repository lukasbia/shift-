struct OrderedSet<Element: Hashable>: Sequence {
    private var elements: [Element] = []
    private var indices: Swift.Set<Element> = []

    var count: Int {
        elements.count
    }

    var isEmpty: Bool {
        elements.isEmpty
    }

    @discardableResult
    mutating func insert(_ element: Element) -> Bool {
        guard indices.insert(element).inserted else {
            return false
        }

        elements.append(element)
        return true
    }

    @discardableResult
    mutating func remove(_ element: Element) -> Bool {
        guard indices.remove(element) != nil else {
            return false
        }

        if let index = elements.firstIndex(of: element) {
            elements.remove(at: index)
        }

        return true
    }

    func contains(_ element: Element) -> Bool {
        indices.contains(element)
    }

    func makeIterator() -> IndexingIterator<[Element]> {
        elements.makeIterator()
    }
}
