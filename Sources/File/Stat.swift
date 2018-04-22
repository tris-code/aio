/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

import Platform

struct Stat {
    let st: stat

    var isDirectory: Bool {
        return st.st_mode & S_IFDIR != 0
    }

    init(for path: Path) throws {
        var st = stat()
        try systemError { stat(path.string, &st) }
        self.st = st
    }
}
