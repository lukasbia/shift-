//
// ASTContext.swift
// Shift
//

public final class ASTContext {

    public private(set) var declarations: [Declaration] = []

    public init() {}

    public func register(
        _ declaration: Declaration
    ) {
        declarations.append(declaration)
    }

    public func clear() {
        declarations.removeAll(keepingCapacity: true)
    }
}
