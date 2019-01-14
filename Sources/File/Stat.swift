import Platform

struct Stat {
    let st: stat

    var isDirectory: Bool {
        return st.st_mode & S_IFDIR != 0
    }

    init(for path: Path) throws {
        var st = stat()
        try system { stat(path.string, &st) }
        self.st = st
    }
}
