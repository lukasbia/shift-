struct SILModRefInfo: Hashable {
    let mayRead: Bool
    let mayWrite: Bool

    static let none = Self(mayRead: false, mayWrite: false)
    static let read = Self(mayRead: true, mayWrite: false)
    static let write = Self(mayRead: false, mayWrite: true)
    static let readWrite = Self(mayRead: true, mayWrite: true)
}
