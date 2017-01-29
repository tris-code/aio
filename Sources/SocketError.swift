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

public struct SocketError: Error, CustomStringConvertible {
    let error = SystemError()
    public var number: Int {
        return Int(error.number)
    }
    public var description: String {
        return error.description
    }
}
