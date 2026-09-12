struct IndexedList<Element> {
    private var elements: [Element] = []

    var count: Int {
        elements.count
    }

    @discardableResult
    mutating func append(_ element: Element) -> Int {
        let index = elements.count
        elements.append(element)
        return index
    }

    subscript(index: Int) -> Element {
        get { elements[index] }
        set { elements[index] = newValue }
    }

    func containsIndex(_ index: Int) -> Bool {
        elements.indices.contains(index)
    }
}
