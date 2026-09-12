struct Stack<Element> {
    private var storage: [Element] = []

    var count: Int {
        storage.count
    }

    var isEmpty: Bool {
        storage.isEmpty
    }

    var top: Element? {
        storage.last
    }

    mutating func push(_ element: Element) {
        storage.append(element)
    }

    @discardableResult
    mutating func pop() -> Element? {
        storage.popLast()
    }

    mutating func removeAll() {
        storage.removeAll(keepingCapacity: true)
    }
}
