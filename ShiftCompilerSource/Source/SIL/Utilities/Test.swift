enum SILTestSupport {
    static func assert(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String = "SIL test assertion failed"
    ) {
        guard condition() else {
            fatalError(message())
        }
    }

    static func equal<T: Equatable>(
        _ lhs: T,
        _ rhs: T,
        _ message: @autoclosure () -> String = "SIL values are not equal"
    ) {
        guard lhs == rhs else {
            fatalError(message())
        }
    }
}
