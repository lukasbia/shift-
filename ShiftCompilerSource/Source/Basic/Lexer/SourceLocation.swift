public struct SourceLocation: Equatable, Hashable, Comparable, Sendable {
    public let line: Int
    public let column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }

    public static func < (
        lhs: SourceLocation,
        rhs: SourceLocation
    ) -> Bool {
        if lhs.line != rhs.line {
            return lhs.line < rhs.line
        }

        return lhs.column < rhs.column
    }

    public var description: String {
        "\(line):\(column)"
    }
}