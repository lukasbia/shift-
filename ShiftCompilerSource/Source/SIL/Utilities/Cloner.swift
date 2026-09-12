struct SILCloner {
    private var valueMap: [SILValue: SILValue] = [:]

    mutating func map(_ oldValue: SILValue, to newValue: SILValue) {
        valueMap[oldValue] = newValue
    }

    func mappedValue(_ value: SILValue) -> SILValue {
        valueMap[value] ?? value
    }

    mutating func clear() {
        valueMap.removeAll(keepingCapacity: true)
    }
}
