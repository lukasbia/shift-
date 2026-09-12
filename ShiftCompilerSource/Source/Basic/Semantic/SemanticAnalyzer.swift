//
// SemanticAnalyzer.swift
// Shift
//

final class SemanticAnalyzer {

    let diagnostics: DiagnosticEngine

    private var globalScope: Scope
    private var currentScope: Scope

    private var currentFunctionReturnType: SemanticType?

    init(
        diagnostics: DiagnosticEngine = DiagnosticEngine()
    ) {
        self.diagnostics = diagnostics

        let scope = Scope()

        self.globalScope = scope
        self.currentScope = scope
    }

    // MARK: - Entry Point

    @discardableResult
    func analyze(
        _ program: Program
    ) -> Bool {

        diagnostics.clear()

        registerBuiltins()

        registerTopLevelDeclarations(
            program.declarations
        )

        for declaration in program.declarations {
            analyzeDeclaration(
                declaration
            )
        }

        for statement in program.statements {
            _ = analyzeStatement(
                statement
            )
        }

        return !diagnostics.hasErrors
    }

    // MARK: - Builtins

    private func registerBuiltins() {

        declareBuiltin(
            name: "Int",
            type: .int
        )

        declareBuiltin(
            name: "UInt",
            type: .uint
        )

        declareBuiltin(
            name: "Int8",
            type: .int8
        )

        declareBuiltin(
            name: "Int16",
            type: .int16
        )

        declareBuiltin(
            name: "Int32",
            type: .int32
        )

        declareBuiltin(
            name: "Int64",
            type: .int64
        )

        declareBuiltin(
            name: "UInt8",
            type: .uint8
        )

        declareBuiltin(
            name: "UInt16",
            type: .uint16
        )

        declareBuiltin(
            name: "UInt32",
            type: .uint32
        )

        declareBuiltin(
            name: "UInt64",
            type: .uint64
        )

        declareBuiltin(
            name: "Float",
            type: .float
        )

        declareBuiltin(
            name: "Double",
            type: .double
        )

        declareBuiltin(
            name: "Bool",
            type: .bool
        )

        declareBuiltin(
            name: "String",
            type: .string
        )

        declareBuiltin(
            name: "Void",
            type: .void
        )

        // print(T...) is intentionally represented
        // as a generic builtin callable here.
        //
        // The actual implementation belongs to lib.
    }

    private func declareBuiltin(
        name: String,
        type: SemanticType
    ) {
        _ = globalScope.declare(
            Symbol(
                name: name,
                kind: .type,
                type: type
            )
        )
    }

    // MARK: - Top Level Registration

    private func registerTopLevelDeclarations(
        _ declarations: [Declaration]
    ) {

        for declaration in declarations {

            switch declaration {

            case .variable(let variable):

                let type = resolveVariableType(
                    variable
                )

                let symbol = Symbol(
                    name: variable.name,
                    kind: variable.isMutable
                        ? .variable
                        : .constant,
                    type: type,
                    isMutable: variable.isMutable,
                    declaration: declaration
                )

                if !globalScope.declare(symbol) {

                    diagnostics.error(
                        "invalid redeclaration of '\(variable.name)'",
                        at: variable.location
                    )
                }

            case .function(let function):

                let parameterTypes = function.parameters.map {
                    resolveType($0.type)
                }

                let returnType =
                    function.returnType
                    .map(resolveType)
                    ?? .void

                let type = SemanticType.function(
                    parameters: parameterTypes,
                    returnType: returnType
                )

                let symbol = Symbol(
                    name: function.name,
                    kind: .function,
                    type: type,
                    declaration: declaration
                )

                if !globalScope.declare(symbol) {

                    diagnostics.error(
                        "invalid redeclaration of '\(function.name)'",
                        at: function.location
                    )
                }

            case .structDecl(let declaration):

                registerType(
                    name: declaration.name,
                    location: declaration.location
                )

            case .classDecl(let declaration):

                registerType(
                    name: declaration.name,
                    location: declaration.location
                )

            case .enumDecl(let declaration):

                registerType(
                    name: declaration.name,
                    location: declaration.location
                )

            case .protocolDecl(let declaration):

                registerType(
                    name: declaration.name,
                    location: declaration.location
                )

            case .extensionDecl:
                break
            }
        }
    }

    private func registerType(
        name: String,
        location: SourceLocation
    ) {

        let symbol = Symbol(
            name: name,
            kind: .type,
            type: .named(name)
        )

        if !globalScope.declare(symbol) {

            diagnostics.error(
                "invalid redeclaration of '\(name)'",
                at: location
            )
        }
    }

    // MARK: - Declarations

    private func analyzeDeclaration(
        _ declaration: Declaration
    ) {

        switch declaration {

        case .variable(let variable):
            analyzeVariableDeclaration(
                variable
            )

        case .function(let function):
            analyzeFunctionDeclaration(
                function
            )

        case .structDecl(let declaration):
            analyzeStructDeclaration(
                declaration
            )

        case .classDecl(let declaration):
            analyzeClassDeclaration(
                declaration
            )

        case .enumDecl(let declaration):
            analyzeEnumDeclaration(
                declaration
            )

        case .protocolDecl(let declaration):
            analyzeProtocolDeclaration(
                declaration
            )

        case .extensionDecl(let declaration):
            analyzeExtensionDeclaration(
                declaration
            )
        }
    }

    private func analyzeVariableDeclaration(
        _ declaration: VariableDeclaration
    ) {

        let declaredType: SemanticType

        if let type = declaration.type {

            declaredType = resolveType(
                type
            )

        } else if let initializer = declaration.initializer {

            declaredType = analyzeExpression(
                initializer
            )

        } else {

            diagnostics.error(
                "variable '\(declaration.name)' requires a type or initializer",
                at: declaration.location
            )

            return
        }

        if let initializer = declaration.initializer {

            let initializerType = analyzeExpression(
                initializer
            )

            requireCompatible(
                expected: declaredType,
                actual: initializerType,
                location: initializer.location
            )
        }
    }

    private func analyzeFunctionDeclaration(
        _ declaration: FunctionDeclaration
    ) {

        let previousScope = currentScope
        let previousReturnType = currentFunctionReturnType

        let functionScope = Scope(
            parent: currentScope
        )

        currentScope = functionScope

        currentFunctionReturnType =
            declaration.returnType
            .map(resolveType)
            ?? .void

        for parameter in declaration.parameters {

            let parameterType = resolveType(
                parameter.type
            )

            let symbol = Symbol(
                name: parameter.localName,
                kind: .parameter,
                type: parameterType,
                isMutable: false
            )

            if !currentScope.declare(symbol) {

                diagnostics.error(
                    "invalid redeclaration of parameter '\(parameter.localName)'",
                    at: parameter.location
                )
            }

            if let defaultValue = parameter.defaultValue {

                let defaultType = analyzeExpression(
                    defaultValue
                )

                requireCompatible(
                    expected: parameterType,
                    actual: defaultType,
                    location: defaultValue.location
                )
            }
        }

        for statement in declaration.body {

            _ = analyzeStatement(
                statement
            )
        }

        currentFunctionReturnType = previousReturnType
        currentScope = previousScope
    }

    private func analyzeStructDeclaration(
        _ declaration: StructDeclaration
    ) {

        let previousScope = currentScope

        currentScope = Scope(
            parent: currentScope
        )

        for member in declaration.members {

            analyzeDeclaration(
                member
            )
        }

        currentScope = previousScope
    }

    private func analyzeClassDeclaration(
        _ declaration: ClassDeclaration
    ) {

        if let superclass = declaration.superclass {

            _ = resolveType(
                superclass
            )
        }

        let previousScope = currentScope

        currentScope = Scope(
            parent: currentScope
        )

        for member in declaration.members {

            analyzeDeclaration(
                member
            )
        }

        currentScope = previousScope
    }

    private func analyzeEnumDeclaration(
        _ declaration: EnumDeclaration
    ) {

        for enumCase in declaration.cases {

            if let rawValue = enumCase.rawValue {

                _ = analyzeExpression(
                    rawValue
                )
            }
        }

        let previousScope = currentScope

        currentScope = Scope(
            parent: currentScope
        )

        for member in declaration.members {

            analyzeDeclaration(
                member
            )
        }

        currentScope = previousScope
    }

    private func analyzeProtocolDeclaration(
        _ declaration: ProtocolDeclaration
    ) {

        let previousScope = currentScope

        currentScope = Scope(
            parent: currentScope
        )

        for requirement in declaration.requirements {

            analyzeDeclaration(
                requirement
            )
        }

        currentScope = previousScope
    }

    private func analyzeExtensionDeclaration(
        _ declaration: ExtensionDeclaration
    ) {

        _ = resolveType(
            declaration.extendedType
        )

        let previousScope = currentScope

        currentScope = Scope(
            parent: currentScope
        )

        for member in declaration.members {

            analyzeDeclaration(
                member
            )
        }

        currentScope = previousScope
    }

    // MARK: - Statements

    @discardableResult
    private func analyzeStatement(
        _ statement: Statement
    ) -> SemanticType {

        switch statement {

        case .expression(let expression):

            return analyzeExpression(
                expression
            )

        case .variable(let declaration):

            analyzeVariableDeclaration(
                declaration
            )

            let type = resolveVariableType(
                declaration
            )

            let symbol = Symbol(
                name: declaration.name,
                kind: declaration.isMutable
                    ? .variable
                    : .constant,
                type: type,
                isMutable: declaration.isMutable
            )

            if !currentScope.declare(symbol) {

                diagnostics.error(
                    "invalid redeclaration of '\(declaration.name)'",
                    at: declaration.location
                )
            }

            return .void

        case .returnStatement(let expression):

            return analyzeReturn(
                expression,
                location: statement.location
            )

        case .ifStatement(
            let condition,
            let body,
            let elseBody
        ):

            let conditionType = analyzeExpression(
                condition
            )

            requireBoolean(
                conditionType,
                location: condition.location
            )

            analyzeBlock(
                body
            )

            if let elseBody {
                analyzeBlock(
                    elseBody
                )
            }

            return .void

        case .whileStatement(
            let condition,
            let body
        ):

            let conditionType = analyzeExpression(
                condition
            )

            requireBoolean(
                conditionType,
                location: condition.location
            )

            analyzeBlock(
                body
            )

            return .void

        case .forInStatement(
            let variable,
            let sequence,
            let body
        ):

            let sequenceType = analyzeExpression(
                sequence
            )

            let elementType: SemanticType

            switch sequenceType {

            case .array(let element):
                elementType = element

            default:
                diagnostics.error(
                    "for-in sequence must be an array",
                    at: sequence.location
                )

                elementType = .void
            }

            let previousScope = currentScope

            currentScope = Scope(
                parent: currentScope
            )

            let symbol = Symbol(
                name: variable,
                kind: .variable,
                type: elementType,
                isMutable: true
            )

            _ = currentScope.declare(symbol)

            analyzeBlockWithoutNewScope(
                body
            )

            currentScope = previousScope

            return .void

        case .breakStatement:
            return .void

        case .continueStatement:
            return .void

        case .switchStatement(
            let expression,
            let cases
        ):

            let expressionType = analyzeExpression(
                expression
            )

            for switchCase in cases {

                for pattern in switchCase.patterns {

                    let patternType = analyzeExpression(
                        pattern
                    )

                    requireCompatible(
                        expected: expressionType,
                        actual: patternType,
                        location: pattern.location
                    )
                }

                analyzeBlock(
                    switchCase.statements
                )
            }

            return .void
        }
    }

    private func analyzeBlock(
        _ statements: [Statement]
    ) {

        let previousScope = currentScope

        currentScope = Scope(
            parent: currentScope
        )

        analyzeBlockWithoutNewScope(
            statements
        )

        currentScope = previousScope
    }

    private func analyzeBlockWithoutNewScope(
        _ statements: [Statement]
    ) {

        for statement in statements {

            _ = analyzeStatement(
                statement
            )
        }
    }

    // MARK: - Return

    private func analyzeReturn(
        _ expression: Expression?,
        location: SourceLocation
    ) -> SemanticType {

        guard let expected = currentFunctionReturnType else {

            diagnostics.error(
                "return statement is only valid inside a function",
                at: location
            )

            return .void
        }

        if expected == .void {

            if expression != nil {

                diagnostics.error(
                    "void function cannot return a value",
                    at: location
                )
            }

            return .void
        }

        guard let expression else {

            diagnostics.error(
                "function must return a value of type \(expected.description)",
                at: location
            )

            return .void
        }

        let actual = analyzeExpression(
            expression
        )

        requireCompatible(
            expected: expected,
            actual: actual,
            location: expression.location
        )

        return expected
    }

    // MARK: - Expressions

    @discardableResult
    private func analyzeExpression(
        _ expression: Expression
    ) -> SemanticType {

        switch expression {

        case .identifier(
            let name,
            let location
        ):

            guard let symbol = currentScope.lookup(name) else {

                diagnostics.error(
                    "cannot find '\(name)' in scope",
                    at: location
                )

                return .void
            }

            return symbol.type

        case .integerLiteral:

            return .int

        case .floatingLiteral:

            return .double

        case .stringLiteral:

            return .string

        case .characterLiteral:

            return .character

        case .booleanLiteral:

            return .bool

        case .unary(
            let operation,
            let operand,
            let location
        ):

            let operandType = analyzeExpression(
                operand
            )

            return analyzeUnary(
                operation,
                operandType: operandType,
                location: location
            )

        case .binary(
            let left,
            let operation,
            let right,
            let location
        ):

            let leftType = analyzeExpression(
                left
            )

            let rightType = analyzeExpression(
                right
            )

            return analyzeBinary(
                operation,
                left: leftType,
                right: rightType,
                location: location
            )

        case .assignment(
            let target,
            let value,
            let location
        ):

            return analyzeAssignment(
                target: target,
                value: value,
                location: location
            )

        case .call(
            let callee,
            let arguments,
            let location
        ):

            return analyzeCall(
                callee: callee,
                arguments: arguments,
                location: location
            )

        case .member(
            let base,
            let name,
            let location
        ):

            return analyzeMember(
                base: base,
                name: name,
                location: location
            )

        case .subscriptExpression(
            let base,
            let index,
            let location
        ):

            let baseType = analyzeExpression(
                base
            )

            let indexType = analyzeExpression(
                index
            )

            guard indexType.isInteger else {

                diagnostics.error(
                    "array subscript must be an integer",
                    at: location
                )

                return .void
            }

            switch baseType {

            case .array(let element):
                return element

            case .pointer(let pointee):
                return pointee

            default:

                diagnostics.error(
                    "type '\(baseType.description)' does not support subscripting",
                    at: location
                )

                return .void
            }

        case .arrayLiteral(
            let elements,
            let location
        ):

            guard let first = elements.first else {
                return .array(.void)
            }

            let elementType = analyzeExpression(
                first
            )

            for element in elements.dropFirst() {

                let type = analyzeExpression(
                    element
                )

                requireCompatible(
                    expected: elementType,
                    actual: type,
                    location: element.location
                )
            }

            return .array(elementType)

        case .tuple(let elements, _):

            return .tuple(
                elements.map {
                    analyzeExpression($0)
                }
            )

        case .parenthesized(
            let expression,
            _
        ):

            return analyzeExpression(
                expression
            )
        }
    }

    // MARK: - Unary

    private func analyzeUnary(
        _ operation: UnaryOperator,
        operandType: SemanticType,
        location: SourceLocation
    ) -> SemanticType {

        switch operation {

        case .plus,
             .minus:

            guard operandType.isNumeric else {

                diagnostics.error(
                    "unary operator requires a numeric operand, got '\(operandType.description)'",
                    at: location
                )

                return .void
            }

            return operandType

        case .logicalNot:

            guard operandType == .bool else {

                diagnostics.error(
                    "logical '!' requires a Bool operand",
                    at: location
                )

                return .void
            }

            return .bool

        case .bitwiseNot:

            guard operandType.isInteger else {

                diagnostics.error(
                    "bitwise operation requires an integer operand",
                    at: location
                )

                return .void
            }

            return operandType

        case .addressOf:

            return .pointer(
                operandType
            )

        case .dereference:

            guard case .pointer(let pointee) = operandType else {

                diagnostics.error(
                    "cannot dereference non-pointer type '\(operandType.description)'",
                    at: location
                )

                return .void
            }

            return pointee
        }
    }

    // MARK: - Binary

    private func analyzeBinary(
        _ operation: BinaryOperator,
        left: SemanticType,
        right: SemanticType,
        location: SourceLocation
    ) -> SemanticType {

        switch operation {

        case .logicalOr,
             .logicalAnd:

            guard left == .bool,
                  right == .bool else {

                diagnostics.error(
                    "logical operators require Bool operands",
                    at: location
                )

                return .void
            }

            return .bool

        case .bitwiseOr,
             .bitwiseXor,
             .bitwiseAnd:

            guard left.isInteger,
                  right.isInteger,
                  left == right else {

                diagnostics.error(
                    "bitwise operands must have the same integer type",
                    at: location
                )

                return .void
            }

            return left

        case .equal,
             .notEqual:

            requireCompatible(
                expected: left,
                actual: right,
                location: location
            )

            return .bool

        case .less,
             .lessOrEqual,
             .greater,
             .greaterOrEqual:

            guard left.isNumeric,
                  right.isNumeric else {

                diagnostics.error(
                    "comparison requires numeric operands",
                    at: location
                )

                return .void
            }

            requireCompatible(
                expected: left,
                actual: right,
                location: location
            )

            return .bool

        case .addition,
             .subtraction,
             .multiplication,
             .division,
             .remainder:

            guard left.isNumeric,
                  right.isNumeric else {

                diagnostics.error(
                    "arithmetic operator requires numeric operands",
                    at: location
                )

                return .void
            }

            requireCompatible(
                expected: left,
                actual: right,
                location: location
            )

            return left
        }
    }

    // MARK: - Assignment

    private func analyzeAssignment(
        target: Expression,
        value: Expression,
        location: SourceLocation
    ) -> SemanticType {

        guard case .identifier(let name, let targetLocation) = target else {

            diagnostics.error(
                "assignment target must be a variable",
                at: location
            )

            _ = analyzeExpression(value)

            return .void
        }

        guard let symbol = currentScope.lookup(name) else {

            diagnostics.error(
                "cannot find '\(name)' in scope",
                at: targetLocation
            )

            _ = analyzeExpression(value)

            return .void
        }

        guard symbol.isMutable else {

            diagnostics.error(
                "cannot assign to immutable value '\(name)'",
                at: targetLocation
            )

            _ = analyzeExpression(value)

            return .void
        }

        let valueType = analyzeExpression(
            value
        )

        requireCompatible(
            expected: symbol.type,
            actual: valueType,
            location: location
        )

        return symbol.type
    }

    // MARK: - Calls

    private func analyzeCall(
        callee: Expression,
        arguments: [CallArgument],
        location: SourceLocation
    ) -> SemanticType {

        let calleeType = analyzeExpression(
            callee
        )

        guard case let .function(
            parameters,
            returnType
        ) = calleeType else {

            diagnostics.error(
                "value of type '\(calleeType.description)' is not callable",
                at: location
            )

            return .void
        }

        guard parameters.count == arguments.count else {

            diagnostics.error(
                "function expects \(parameters.count) argument(s), but \(arguments.count) were provided",
                at: location
            )

            for argument in arguments {
                _ = analyzeExpression(
                    argument.value
                )
            }

            return returnType
        }

        for (parameterType, argument) in zip(
            parameters,
            arguments
        ) {

            let argumentType = analyzeExpression(
                argument.value
            )

            requireCompatible(
                expected: parameterType,
                actual: argumentType,
                location: argument.location
            )
        }

        return returnType
    }

    // MARK: - Members

    private func analyzeMember(
        base: Expression,
        name: String,
        location: SourceLocation
    ) -> SemanticType {

        let baseType = analyzeExpression(
            base
        )

        switch baseType {

        case .named(let typeName):

            guard let symbol = lookupMember(
                typeName: typeName,
                memberName: name
            ) else {

                diagnostics.error(
                    "type '\(typeName)' has no member '\(name)'",
                    at: location
                )

                return .void
            }

            return symbol.type

        case .pointer(let pointee):

            if name == "pointee" {
                return pointee
            }

            diagnostics.error(
                "pointer type has no member '\(name)'",
                at: location
            )

            return .void

        default:

            diagnostics.error(
                "type '\(baseType.description)' has no member '\(name)'",
                at: location
            )

            return .void
        }
    }

    private func lookupMember(
        typeName: String,
        memberName: String
    ) -> Symbol? {

        guard let symbol = globalScope.lookup(
            typeName
        ),
        let declaration = symbol.declaration else {
            return nil
        }

        switch declaration {

        case .structDecl(let structure):

            for member in structure.members {

                if let result = memberSymbol(
                    member,
                    name: memberName
                ) {
                    return result
                }
            }

        case .classDecl(let classDeclaration):

            for member in classDeclaration.members {

                if let result = memberSymbol(
                    member,
                    name: memberName
                ) {
                    return result
                }
            }

        case .enumDecl(let enumeration):

            for member in enumeration.members {

                if let result = memberSymbol(
                    member,
                    name: memberName
                ) {
                    return result
                }
            }

        default:
            break
        }

        return nil
    }

    private func memberSymbol(
        _ declaration: Declaration,
        name: String
    ) -> Symbol? {

        switch declaration {

        case .variable(let variable):

            guard variable.name == name else {
                return nil
            }

            return Symbol(
                name: variable.name,
                kind: variable.isMutable
                    ? .variable
                    : .constant,
                type: resolveVariableType(variable),
                isMutable: variable.isMutable,
                declaration: declaration
            )

        case .function(let function):

            guard function.name == name else {
                return nil
            }

            return Symbol(
                name: function.name,
                kind: .function,
                type: .function(
                    parameters: function.parameters.map {
                        resolveType($0.type)
                    },
                    returnType:
                        function.returnType
                        .map(resolveType)
                        ?? .void
                ),
                declaration: declaration
            )

        default:
            return nil
        }
    }

    // MARK: - Types

    private func resolveVariableType(
        _ declaration: VariableDeclaration
    ) -> SemanticType {

        if let type = declaration.type {
            return resolveType(type)
        }

        if let initializer = declaration.initializer {
            return analyzeExpression(initializer)
        }

        return .void
    }

    private func resolveType(
        _ type: TypeSyntax
    ) -> SemanticType {

        switch type {

        case .named(
            let name,
            let location
        ):

            switch name {

            case "Int":
                return .int

            case "UInt":
                return .uint

            case "Int8":
                return .int8

            case "Int16":
                return .int16

            case "Int32":
                return .int32

            case "Int64":
                return .int64

            case "UInt8":
                return .uint8

            case "UInt16":
                return .uint16

            case "UInt32":
                return .uint32

            case "UInt64":
                return .uint64

            case "Float":
                return .float

            case "Double":
                return .double

            case "Bool":
                return .bool

            case "String":
                return .string

            case "Void":
                return .void

            default:

                guard globalScope.lookup(name) != nil else {

                    diagnostics.error(
                        "cannot find type '\(name)'",
                        at: location
                    )

                    return .named(name)
                }

                return .named(name)
            }

        case .array(
            let element,
            _
        ):

            return .array(
                resolveType(element)
            )

        case .pointer(
            let pointee,
            _
        ):

            return .pointer(
                resolveType(pointee)
            )

        case .optional(
            let wrapped,
            _
        ):

            return .optional(
                resolveType(wrapped)
            )

        case .tuple(
            let elements,
            _
        ):

            return .tuple(
                elements.map(resolveType)
            )

        case .function(
            let parameters,
            let returnType,
            _
        ):

            return .function(
                parameters: parameters.map(resolveType),
                returnType: resolveType(returnType)
            )
        }
    }

    // MARK: - Type Checking

    private func requireCompatible(
        expected: SemanticType,
        actual: SemanticType,
        location: SourceLocation
    ) {

        guard expected == actual else {

            diagnostics.error(
                "cannot convert value of type '\(actual.description)' to expected type '\(expected.description)'",
                at: location
            )
        }
    }

    private func requireBoolean(
        _ type: SemanticType,
        location: SourceLocation
    ) {

        guard type == .bool else {

            diagnostics.error(
                "condition requires a Bool expression, got '\(type.description)'",
                at: location
            )
        }
    }
}