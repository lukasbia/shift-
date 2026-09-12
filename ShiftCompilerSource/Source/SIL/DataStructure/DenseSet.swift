struct DenseSet<Element: Hashable> {
    private var storage: Swift.Set<Element> = []

    var count: Int {
        storage.count
    }

    var isEmpty: Bool {
        storage.isEmpty
    }

    mutating func insert(_ element: Element) {
        storage.insert(element)
    }

    mutating func remove(_ element: Element) {
        storage.remove(element)
    }

    func contains(_ element: Element) -> Bool {
        storage.contains(element)
    }

    mutating func removeAll() {
        storage.removeAll(keepingCapacity: true)
    }
}
