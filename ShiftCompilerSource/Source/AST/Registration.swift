//
// Registration.swift
// Shift
//

public final class ASTRegistration {

    public static let shared = ASTRegistration()

    private var registrations: [
        String: Declaration
    ] = [:]

    private init() {}

    public func register(
        name: String,
        declaration: Declaration
    ) {
        registrations[name] = declaration
    }

    public func lookup(
        name: String
    ) -> Declaration? {
        registrations[name]
    }

    public func clear() {
        registrations.removeAll(keepingCapacity: true)
    }
}
