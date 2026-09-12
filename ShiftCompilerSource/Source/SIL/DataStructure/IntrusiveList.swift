final class IntrusiveList<Element> {
    final class Node {
        let value: Element
        var next: Node?
        weak var previous: Node?

        init(_ value: Element) {
            self.value = value
        }
    }

    private(set) var head: Node?
    private(set) var tail: Node?
    private(set) var count: Int = 0

    func append(_ value: Element) -> Node {
        let node = Node(value)

        if let tail {
            tail.next = node
            node.previous = tail
        } else {
            head = node
        }

        tail = node
        count += 1
        return node
    }

    func remove(_ node: Node) {
        if node.previous == nil {
            head = node.next
        } else {
            node.previous?.next = node.next
        }

        if node.next == nil {
            tail = node.previous
        } else {
            node.next?.previous = node.previous
        }

        node.next = nil
        node.previous = nil
        count -= 1
    }
}
