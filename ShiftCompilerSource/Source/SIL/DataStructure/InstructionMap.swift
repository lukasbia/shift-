struct InstructionMap<Value> {
    private var storage: [ObjectIdentifier: Value] = [:]

    // SILInstruction is currently an enum value, so this map is intentionally
    // keyed by a stable integer supplied by a future SIL instruction arena.
    private var indexedStorage: [Int: Value] = [:]

    subscript(index: Int) -> Value? {
        get { indexedStorage[index] }
        set { indexedStorage[index] = newValue }
    }

    var count: Int {
        indexedStorage.count
    }
}
