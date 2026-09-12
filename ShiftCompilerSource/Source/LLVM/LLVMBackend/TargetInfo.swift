import Foundation

public struct TargetInfo: Equatable, Sendable {
    public let triple: String
    public let cpu: String?
    public let features: String?

    public init(triple: String, cpu: String? = nil, features: String? = nil) throws {
        guard !triple.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BackendError.invalidTargetTriple(triple)
        }
        self.triple = triple
        self.cpu = cpu
        self.features = features
    }

    public static func host(cpu: String? = nil, features: String? = nil) -> TargetInfo {
        #if os(macOS)
        #if arch(arm64)
        return try! TargetInfo(triple: "arm64-apple-macosx", cpu: cpu, features: features)
        #else
        return try! TargetInfo(triple: "x86_64-apple-macosx", cpu: cpu, features: features)
        #endif
        #elseif os(Linux)
        #if arch(arm64)
        return try! TargetInfo(triple: "aarch64-unknown-linux-gnu", cpu: cpu, features: features)
        #elseif arch(x86_64)
        return try! TargetInfo(triple: "x86_64-unknown-linux-gnu", cpu: cpu, features: features)
        #else
        return try! TargetInfo(triple: "unknown-unknown-linux", cpu: cpu, features: features)
        #endif
        #elseif os(Windows)
        return try! TargetInfo(triple: "x86_64-pc-windows-msvc", cpu: cpu, features: features)
        #else
        return try! TargetInfo(triple: "unknown-unknown", cpu: cpu, features: features)
        #endif
    }
}
