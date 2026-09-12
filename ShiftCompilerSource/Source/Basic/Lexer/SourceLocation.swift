//
// SourceLocation.swift
// Shift
//

struct SourceLocation: Equatable, Hashable {

    let line: Int
    let column: Int

    init(
        line: Int,
        column: Int
    ) {
        self.line = line
        self.column = column
    }
}