//
// SubstitutionMap.swift
// Shift
//

public struct SubstitutionMap {

    private var substitutions: [
        String: TypeSyntax
    ]

    public init() {
        self.substitutions = [:]
    }

    public mutating func add(
        parameter: String,
        type: TypeSyntax
    ) {
        substitutions[parameter] = type
    }

    public func lookup(
        _ parameter: String
    ) -> TypeSyntax? {
        substitutions[parameter]
    }

    public var isEmpty: Bool {
        substitutions.isEmpty
    }
}
