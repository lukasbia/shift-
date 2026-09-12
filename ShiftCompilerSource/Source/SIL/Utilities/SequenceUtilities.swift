enum SILSequenceUtilities {
    static func first<T>(
        _ sequence: some Sequence<T>,
        where predicate: (T) throws -> Bool
    ) rethrows -> T? {
        for element in sequence {
            if try predicate(element) {
                return element
            }
        }

        return nil
    }

    static func contains<T>(
        _ sequence: some Sequence<T>,
        where predicate: (T) throws -> Bool
    ) rethrows -> Bool {
        try first(sequence, where: predicate) != nil
    }

    static func all<T>(
        _ sequence: some Sequence<T>,
        where predicate: (T) throws -> Bool
    ) rethrows -> Bool {
        for element in sequence {
            if try !predicate(element) {
                return false
            }
        }

        return true
    }
}
