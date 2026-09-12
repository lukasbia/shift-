enum SILForwardingUtils {
    static func forwardedValue(
        from value: SILValue,
        replacements: [SILValue: SILValue]
    ) -> SILValue {
        var current = value
        var visited: Swift.Set<SILValue> = []

        while let replacement = replacements[current],
              visited.insert(current).inserted {
            current = replacement
        }

        return current
    }

    static func forwardingChain(
        from value: SILValue,
        replacements: [SILValue: SILValue]
    ) -> [SILValue] {
        var result = [value]
        var current = value
        var visited: Swift.Set<SILValue> = [value]

        while let replacement = replacements[current],
              visited.insert(replacement).inserted {
            result.append(replacement)
            current = replacement
        }

        return result
    }
}
