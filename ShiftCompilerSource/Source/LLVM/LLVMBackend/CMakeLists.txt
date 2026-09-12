add_library(ShiftBackend STATIC
    Backend.swift
    BackendDriver.swift
    BackendError.swift
    BackendOptions.swift
    Linker.swift
    LLVMBackend.swift
    ProcessRunner.swift
    TargetInfo.swift
    Toolchain.swift
)

target_link_libraries(ShiftBackend
    PRIVATE
        ShiftIRGen
)
