//
// Scope.swift
// Shift
//

final class Scope {

    private var symbols: [String: Symbol] = [:]

    let parent: Scope?

    init(
        parent: Scope? = nil
    ) {
        self.parent = parent
    }

    func declare(
        _ symbol: Symbol
    ) -> Bool {

        guard symbols[symbol.name] == nil else {
            return false
        }

        symbols[symbol.name] = symbol

        return true
    }

    func containsLocal(
        _ name: String
    ) -> Bool {
        symbols[name] != nil
    }

    func lookup(
        _ name: String
    ) -> Symbol? {

        if let symbol = symbols[name] {
            return symbol
        }

        return parent?.lookup(name)
    }
}