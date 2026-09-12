public enum IRGenVerifier {
    public static func verify(_ ir: String) throws {
        guard ir.contains("ModuleID") else { throw IRGenError.invalidFunction("LLVM IR has no module header") }
        var depth = 0
        for line in ir.split(separator: "\n", omittingEmptySubsequences: true) {
            if line.hasPrefix("define ") { depth += 1 }
            if line == "}" { depth -= 1 }
            if depth < 0 { throw IRGenError.malformedControlFlow("unbalanced function body") }
        }
        if depth != 0 { throw IRGenError.malformedControlFlow("unbalanced function body") }
    }
}
