public final class LLVMIRBuilder {
    private var lines: [String] = []
    private var nextTemporary: Int = 0
    private var nextString: Int = 0

    public init() {}

    public func append(_ line: String = "") { lines.append(line) }

    public func temporary() -> String {
        defer { nextTemporary += 1 }
        return "%\(nextTemporary)"
    }

    public func stringName() -> String {
        defer { nextString += 1 }
        return ".str.\(nextString)"
    }

    public func build() -> String { lines.joined(separator: "\n") + "\n" }
}
