add_library(ShiftIRGen STATIC
    IRGenError.swift
    IRGenFunction.swift
    IRGenOptions.swift
    IRGenValue.swift
    IRGenVerifier.swift
    LLVMIRBuilder.swift
    LLVMIRGen.swift
    LLVMType.swift
)

target_link_libraries(ShiftIRGen
    PRIVATE
        ShiftSIL
)
