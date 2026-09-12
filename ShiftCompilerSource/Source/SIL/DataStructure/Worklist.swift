struct Worklist<Element: Hashable> {
    private var queue: [Element] = []
    private var queued: Swift.Set<Element> = []
    private var head: Int = 0

    var isEmpty: Bool {
        head >= queue.count
    }

    var count: Int {
        queue.count - head
    }

    mutating func push(_ element: Element) {
        guard queued.insert(element).inserted else {
            return
        }
        queue.append(element)
    }

    mutating func push<S: Sequence>(contentsOf elements: S) where S.Element == Element {
        for element in elements {
            push(element)
        }
    }

    mutating func pop() -> Element? {
        guard head < queue.count else {
            queue.removeAll(keepingCapacity: true)
            queued.removeAll(keepingCapacity: true)
            head = 0
            return nil
        }

        let element = queue[head]
        head += 1
        queued.remove(element)

        if head > 128 && head * 2 > queue.count {
            queue.removeFirst(head)
            head = 0
        }

        return element
    }
}
