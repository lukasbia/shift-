//
// GenericSignature.swift
// Shift
//

public struct GenericParameter: Equatable, Hashable {

    public let name: String
    public let index: Int

    public init(
        name: String,
        index: Int
    ) {
        self.name = name
        self.index = index
    }
}

public struct GenericRequirement: Equatable, Hashable {

    public let left: TypeSyntax
    public let right: TypeSyntax

    public init(
        left: TypeSyntax,
        right: TypeSyntax
    ) {
        self.left = left
        self.right = right
    }
}

public struct GenericSignature {

    public let parameters: [GenericParameter]
    public let requirements: [GenericRequirement]

    public init(
        parameters: [GenericParameter],
        requirements: [GenericRequirement]
    ) {
        self.parameters = parameters
        self.requirements = requirements
    }
}
