struct DenseMap<Key: Hashable, Value> {
    private var storage: [Key: Value] = [:]

    var count: Int {
        storage.count
    }

    var isEmpty: Bool {
        storage.isEmpty
    }

    subscript(key: Key) -> Value? {
        get { storage[key] }
        set { storage[key] = newValue }
    }

    func contains(_ key: Key) -> Bool {
        storage[key] != nil
    }

    mutating func remove(_ key: Key) {
        storage.removeValue(forKey: key)
    }

    mutating func removeAll() {
        storage.removeAll(keepingCapacity: true)
    }
}
