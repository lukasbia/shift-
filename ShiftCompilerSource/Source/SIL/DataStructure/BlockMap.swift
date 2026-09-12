struct BlockMap<Value> {
    private var storage: [SILBasicBlock.ID: Value] = [:]

    subscript(key: SILBasicBlock.ID) -> Value? {
        get { storage[key] }
        set { storage[key] = newValue }
    }

    func contains(_ key: SILBasicBlock.ID) -> Bool {
        storage[key] != nil
    }
}
