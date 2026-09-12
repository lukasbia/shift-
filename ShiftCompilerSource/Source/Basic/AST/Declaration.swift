//
// Declarations.swift
// Shift
//

public enum DeclarationModifier: Equatable, Hashable {
    case `public`
    case `private`
    case `internal`
    case `static`
    case mutating
    case unsafe
}

public indirect enum Declaration: ASTNode {

    case variable(VariableDeclaration)
    case function(FunctionDeclaration)
    case structDecl(StructDeclaration)
    case classDecl(ClassDeclaration)
    case enumDecl(EnumDeclaration)
    case protocolDecl(ProtocolDeclaration)
    case extensionDecl(ExtensionDeclaration)

    public var location: SourceLocation {
        switch self {
        case .variable(let declaration):
            return declaration.location

        case .function(let declaration):
            return declaration.location

        case .structDecl(let declaration):
            return declaration.location

        case .classDecl(let declaration):
            return declaration.location

        case .enumDecl(let declaration):
            return declaration.location

        case .protocolDecl(let declaration):
            return declaration.location

        case .extensionDecl(let declaration):
            return declaration.location
        }
    }
}

public struct VariableDeclaration: ASTNode {

    public let name: String
    public let type: TypeSyntax?
    public let initializer: Expression?
    public let isMutable: Bool
    public let modifiers: [DeclarationModifier]
    public let location: SourceLocation

    public init(
        name: String,
        type: TypeSyntax?,
        initializer: Expression?,
        isMutable: Bool,
        modifiers: [DeclarationModifier],
        location: SourceLocation
    ) {
        self.name = name
        self.type = type
        self.initializer = initializer
        self.isMutable = isMutable
        self.modifiers = modifiers
        self.location = location
    }
}

public struct FunctionDeclaration: ASTNode {

    public let name: String
    public let parameters: [FunctionParameter]
    public let returnType: TypeSyntax?
    public let body: [Statement]
    public let modifiers: [DeclarationModifier]
    public let location: SourceLocation

    public init(
        name: String,
        parameters: [FunctionParameter],
        returnType: TypeSyntax?,
        body: [Statement],
        modifiers: [DeclarationModifier],
        location: SourceLocation
    ) {
        self.name = name
        self.parameters = parameters
        self.returnType = returnType
        self.body = body
        self.modifiers = modifiers
        self.location = location
    }
}

public struct FunctionParameter: ASTNode {

    public let externalName: String?
    public let localName: String
    public let type: TypeSyntax
    public let defaultValue: Expression?
    public let location: SourceLocation

    public init(
        externalName: String?,
        localName: String,
        type: TypeSyntax,
        defaultValue: Expression?,
        location: SourceLocation
    ) {
        self.externalName = externalName
        self.localName = localName
        self.type = type
        self.defaultValue = defaultValue
        self.location = location
    }
}

public struct StructDeclaration: ASTNode {

    public let name: String
    public let members: [Declaration]
    public let modifiers: [DeclarationModifier]
    public let location: SourceLocation

    public init(
        name: String,
        members: [Declaration],
        modifiers: [DeclarationModifier],
        location: SourceLocation
    ) {
        self.name = name
        self.members = members
        self.modifiers = modifiers
        self.location = location
    }
}

public struct ClassDeclaration: ASTNode {

    public let name: String
    public let superclass: TypeSyntax?
    public let members: [Declaration]
    public let modifiers: [DeclarationModifier]
    public let location: SourceLocation

    public init(
        name: String,
        superclass: TypeSyntax?,
        members: [Declaration],
        modifiers: [DeclarationModifier],
        location: SourceLocation
    ) {
        self.name = name
        self.superclass = superclass
        self.members = members
        self.modifiers = modifiers
        self.location = location
    }
}

public struct EnumDeclaration: ASTNode {

    public let name: String
    public let cases: [EnumCase]
    public let members: [Declaration]
    public let modifiers: [DeclarationModifier]
    public let location: SourceLocation

    public init(
        name: String,
        cases: [EnumCase],
        members: [Declaration],
        modifiers: [DeclarationModifier],
        location: SourceLocation
    ) {
        self.name = name
        self.cases = cases
        self.members = members
        self.modifiers = modifiers
        self.location = location
    }
}

public struct EnumCase: ASTNode {

    public let name: String
    public let associatedValues: [TypeSyntax]
    public let rawValue: Expression?
    public let location: SourceLocation

    public init(
        name: String,
        associatedValues: [TypeSyntax],
        rawValue: Expression?,
        location: SourceLocation
    ) {
        self.name = name
        self.associatedValues = associatedValues
        self.rawValue = rawValue
        self.location = location
    }
}

public struct ProtocolDeclaration: ASTNode {

    public let name: String
    public let requirements: [Declaration]
    public let modifiers: [DeclarationModifier]
    public let location: SourceLocation

    public init(
        name: String,
        requirements: [Declaration],
        modifiers: [DeclarationModifier],
        location: SourceLocation
    ) {
        self.name = name
        self.requirements = requirements
        self.modifiers = modifiers
        self.location = location
    }
}

public struct ExtensionDeclaration: ASTNode {

    public let extendedType: TypeSyntax
    public let members: [Declaration]
    public let modifiers: [DeclarationModifier]
    public let location: SourceLocation

    public init(
        extendedType: TypeSyntax,
        members: [Declaration],
        modifiers: [DeclarationModifier],
        location: SourceLocation
    ) {
        self.extendedType = extendedType
        self.members = members
        self.modifiers = modifiers
        self.location = location
    }
}