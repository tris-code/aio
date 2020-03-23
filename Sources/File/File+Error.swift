import Platform

extension File {
    public enum Error: Swift.Error, Equatable {
        case invalidName   // Invalid file name
        case invalidPath   // Invalid file path
        case alreadyOpened // The file is already opened
        case closed        // The file was closed or wasn't opened
        case exists        // The file is already exists
        case doesntExist   // The file doesn't exist
        case system(SystemError)
    }
}

extension File.Error {
    init(systemError: SystemError) {
        switch systemError.number {
        case EEXIST: self = .exists
        case ENOENT: self = .doesntExist
        // TODO:
        case EBADF: self = .system(systemError)
        default: self = .system(systemError)
        }
    }
}

extension File.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidName: return "Invalid file name"
        case .invalidPath: return "Invalid file path"
        case .alreadyOpened: return "The file is already opened"
        case .closed: return "The file was closed or wasn't opened"
        case .exists: return "The file is already exists"
        case .doesntExist: return "The file doesn't exist"
        case .system(let error): return "System error: \(error)"
        }
    }
}
