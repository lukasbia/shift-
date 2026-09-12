add_library(ShiftSema STATIC
    Diagnostic.swift
    Scope.swift
    SemanticAnalyzer.swift
    SemanticError.swift
    SemanticType.swift
    Symbol.swift
)

target_link_libraries(ShiftSema
    PRIVATE
    ShiftAST
)