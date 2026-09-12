import Foundation

protocol ASTNode {
    var location: SourceLocation { get }
}

struct SourceFile: ASTNode {
    let declarations: [Declaration]
    let location: SourceLocation
}

enum Declaration: ASTNode {
    case variable(VariableDeclaration)
    case function(FunctionDeclaration)
    case structDecl(StructDeclaration)
    case classDecl(ClassDeclaration)
    case enumDecl(EnumDeclaration)
    case protocolDecl(ProtocolDeclaration)
    case extensionDecl(ExtensionDeclaration)

    var location: SourceLocation {
        switch self {
        case .variable(let value):
            return value.location
        case .function(let value):
            return value.location
        case .structDecl(let value):
            return value.location
        case .classDecl(let value):
            return value.location
        case .enumDecl(let value):
            return value.location
        case .protocolDecl(let value):
            return value.location
        case .extensionDecl(let value):
            return value.location
        }
    }
}

struct Identifier: ASTNode {
    let name: String
    let location: SourceLocation
}