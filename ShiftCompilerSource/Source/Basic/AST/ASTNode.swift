//
// ASTNode.swift
// Shift
//

public protocol ASTNode {
    var location: SourceLocation { get }
}

public struct SourceRange: Equatable, Hashable {
    public let start: SourceLocation
    public let end: SourceLocation

    public init(
        start: SourceLocation,
        end: SourceLocation
    ) {
        self.start = start
        self.end = end
    }
}