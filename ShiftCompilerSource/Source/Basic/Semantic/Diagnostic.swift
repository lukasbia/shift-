//
// Diagnostic.swift
// Shift
//

enum DiagnosticSeverity {

    case note
    case warning
    case error
}

struct Diagnostic {

    let severity: DiagnosticSeverity
    let message: String
    let location: SourceLocation

    init(
        severity: DiagnosticSeverity,
        message: String,
        location: SourceLocation
    ) {
        self.severity = severity
        self.message = message
        self.location = location
    }
}

final class DiagnosticEngine {

    private(set) var diagnostics: [Diagnostic] = []

    var hasErrors: Bool {
        diagnostics.contains {
            $0.severity == .error
        }
    }

    func diagnose(
        _ severity: DiagnosticSeverity,
        _ message: String,
        at location: SourceLocation
    ) {
        diagnostics.append(
            Diagnostic(
                severity: severity,
                message: message,
                location: location
            )
        )
    }

    func error(
        _ message: String,
        at location: SourceLocation
    ) {
        diagnose(
            .error,
            message,
            at: location
        )
    }

    func warning(
        _ message: String,
        at location: SourceLocation
    ) {
        diagnose(
            .warning,
            message,
            at: location
        )
    }

    func note(
        _ message: String,
        at location: SourceLocation
    ) {
        diagnose(
            .note,
            message,
            at: location
        )
    }

    func clear() {
        diagnostics.removeAll(
            keepingCapacity: true
        )
    }
}