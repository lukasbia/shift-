import Foundation

indirect enum TypeSyntax: ASTNode {
    case named(
        Identifier
    )

    case array(
        TypeSyntax,
        SourceLocation
    )

    case pointer(
        TypeSyntax,
        SourceLocation
    )

    case optional(
        TypeSyntax,
        SourceLocation
    )

    case tuple(
        [TypeSyntax],
        SourceLocation
    )

    case function(
        parameters: [TypeSyntax],
        returnType: TypeSyntax?,
        SourceLocation
    )

    var location: SourceLocation {
        switch self {
        case .named(let identifier):
            return identifier.location

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