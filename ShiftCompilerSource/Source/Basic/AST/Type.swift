//
// Types.swift
// Shift
//

public indirect enum TypeSyntax: ASTNode {

    case named(
        name: String,
        location: SourceLocation
    )

    case array(
        element: TypeSyntax,
        location: SourceLocation
    )

    case pointer(
        pointee: TypeSyntax,
        location: SourceLocation
    )

    case optional(
        wrapped: TypeSyntax,
        location: SourceLocation
    )

    case tuple(
        elements: [TypeSyntax],
        location: SourceLocation
    )

    case function(
        parameters: [TypeSyntax],
        returnType: TypeSyntax,
        location: SourceLocation
    )

    public var location: SourceLocation {
        switch self {
        case .named(_, let location):
            return location

        case .array(_, let location):
            return location

        case .pointer(_, let location):
            return location

        case .optional(_, let location):
            return location

        case .tuple(_, let location):
            return location

        case .function(_, _, let location):
            return location
        }
    }
}