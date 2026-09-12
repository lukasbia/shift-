//
// SemanticError.swift
// Shift
//

enum SemanticError: Error {

    case failed

    case undefinedSymbol(
        name: String,
        location: SourceLocation
    )

    case duplicateDeclaration(
        name: String,
        location: SourceLocation
    )

    case typeMismatch(
        expected: SemanticType,
        actual: SemanticType,
        location: SourceLocation
    )

    case invalidCondition(
        type: SemanticType,
        location: SourceLocation
    )

    case invalidOperand(
        operator: String,
        type: SemanticType,
        location: SourceLocation
    )

    case invalidBinaryOperands(
        operator: String,
        left: SemanticType,
        right: SemanticType,
        location: SourceLocation
    )

    case invalidAssignmentTarget(
        location: SourceLocation
    )

    case immutableAssignment(
        name: String,
        location: SourceLocation
    )

    case notCallable(
        type: SemanticType,
        location: SourceLocation
    )

    case wrongArgumentCount(
        expected: Int,
        actual: Int,
        location: SourceLocation
    )

    case invalidReturn(
        location: SourceLocation
    )

    case missingReturn(
        location: SourceLocation
    )

    case invalidMember(
        member: String,
        type: SemanticType,
        location: SourceLocation
    )
}