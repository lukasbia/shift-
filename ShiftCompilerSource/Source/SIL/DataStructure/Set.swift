struct ShiftSet<Element: Hashable>: Sequence {
    private var storage: Swift.Set<Element>

    init() {
        storage = []
    }

    init<S: Sequence>(_ elements: S) where S.Element == Element {
        storage = Swift.Set(elements)
    }

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
        storage.removeAll(keepingCapacity: false)
    }

    func makeIterator() -> Swift.Set<Element>.Iterator {
        storage.makeIterator()
    }
}
