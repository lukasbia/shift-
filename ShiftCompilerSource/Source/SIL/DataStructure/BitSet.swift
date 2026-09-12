struct BitSet: Sequence {
    private var words: [UInt64] = []
    private(set) var capacity: Int = 0

    init(capacity: Int = 0) {
        reserveCapacity(capacity)
    }

    mutating func reserveCapacity(_ capacity: Int) {
        guard capacity > self.capacity else {
            return
        }

        self.capacity = capacity
        let wordCount = (capacity + 63) / 64
        if wordCount > words.count {
            words.append(contentsOf: repeatElement(0, count: wordCount - words.count))
        }
    }

    func contains(_ bit: Int) -> Bool {
        guard bit >= 0 && bit < capacity else {
            return false
        }

        let word = bit >> 6
        let mask = UInt64(1) << UInt64(bit & 63)
        return words[word] & mask != 0
    }

    mutating func insert(_ bit: Int) {
        guard bit >= 0 else {
            return
        }

        reserveCapacity(bit + 1)
        words[bit >> 6] |= UInt64(1) << UInt64(bit & 63)
    }

    mutating func remove(_ bit: Int) {
        guard bit >= 0 && bit < capacity else {
            return
        }

        words[bit >> 6] &= ~(UInt64(1) << UInt64(bit & 63))
    }

    mutating func removeAll() {
        words = repeatElement(0, count: words.count)
            .reduce(into: []) { $0.append($1) }
    }

    func makeIterator() -> AnyIterator<Int> {
        var index = 0
        return AnyIterator {
            while index < self.capacity {
                defer { index += 1 }
                if self.contains(index) {
                    return index
                }
            }
            return nil
        }
    }
}
