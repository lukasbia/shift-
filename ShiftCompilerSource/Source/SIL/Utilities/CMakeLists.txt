add_library(ShiftSILUtilities STATIC
    AccessUtils.swift
    BorrowUtils.swift
    Cloner.swift
    ForwardingUtils.swift
    PhiUpdater.swift
    SSAUpdater.swift
    SequenceUtilities.swift
    SmallProjectionPath.swift
    Test.swift
    Verifier.swift
    WalkUtils.swift
)

target_link_libraries(ShiftSILUtilities
    PRIVATE
    ShiftSIL
    ShiftSILDataStructures
)
