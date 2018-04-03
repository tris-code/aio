/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

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
