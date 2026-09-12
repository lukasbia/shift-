//
// DeclContext.swift
// Shift
//

public enum DeclContextKind {
    case module
    case function
    case structDecl
    case classDecl
    case enumDecl
    case protocolDecl
    case extensionDecl
}

public protocol DeclContext {
    var contextKind: DeclContextKind { get }
    var parentContext: DeclContext? { get }
}

public final class ModuleDeclContext: DeclContext {

    public let contextKind: DeclContextKind = .module
    public let parentContext: DeclContext? = nil

    public init() {}
}

public final class FunctionDeclContext: DeclContext {

    public let contextKind: DeclContextKind = .function
    public let parentContext: DeclContext?

    public init(
        parentContext: DeclContext?
    ) {
        self.parentContext = parentContext
    }
}