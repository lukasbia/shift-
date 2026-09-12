add_library(ShiftAST STATIC
    ASTNode.swift
    ASTContext.swift
    DeclContext.swift
    Declarations.swift
    Expressions.swift
    Statements.swift
    Types.swift
    GenericSignature.swift
    SubstitutionMap.swift
    Registration.swift
)

target_link_libraries(ShiftAST
    PRIVATE
    ShiftBasic
)
