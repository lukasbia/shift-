struct ValueMap<Value: Hashable> {
    private var storage: [SILValue: Value] = [:]

    subscript(key: SILValue) -> Value? {
        get { storage[key] }
        set { storage[key] = newValue }
    }

    func contains(_ key: SILValue) -> Bool {
        storage[key] != nil
    }

    mutating func remove(_ key: SILValue) {
        storage.removeValue(forKey: key)
    }
}
