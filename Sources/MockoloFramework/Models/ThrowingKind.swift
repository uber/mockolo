enum ThrowingKind: Equatable {
    case none
    case any
    case `rethrows`
    case typed(errorType: String)

    var hasError: Bool {
        switch self {
        case .none:
            return false
        case .any:
            return true
        case .rethrows:
            return true
        case .typed(let errorType):
            return errorType != .neverType && errorType != "Swift.\(String.neverType)"
        }
    }

    var syntax: String? {
        switch self {
        case .none:
            return nil
        case .any:
            return .throws
        case .rethrows:
            return .rethrows
        case .typed(let errorType):
            return "\(String.throws)(\(errorType))"
        }
    }
}
