struct SmallVector<Element>: RandomAccessCollection {
    private var storage: [Element] = []
    private let inlineCapacity: Int

    init(inlineCapacity: Int = 4) {
        self.inlineCapacity = max(0, inlineCapacity)
        storage.reserveCapacity(self.inlineCapacity)
    }

    var startIndex: Int {
        storage.startIndex
    }

    var endIndex: Int {
        storage.endIndex
    }

    subscript(index: Int) -> Element {
        get { storage[index] }
        set { storage[index] = newValue }
    }

    mutating func append(_ element: Element) {
        storage.append(element)
    }

    mutating func append<S: Sequence>(contentsOf elements: S) where S.Element == Element {
        storage.append(contentsOf: elements)
    }

    mutating func removeLast() -> Element {
        storage.removeLast()
    }
}
