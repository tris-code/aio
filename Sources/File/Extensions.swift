/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Stream

extension String {
    @inlinable
    public init<T: Unicode.Encoding>(
        reading file: File,
        as encoding: T.Type) throws
    {
        let reader = try file.open()
        try self.init(readingFrom: reader.inputStream, as: encoding)
        try file.close()
    }

    @inlinable
    public init<T: Unicode.Encoding>(
        readingFrom reader: StreamReader,
        as encoding: T.Type) throws
    {
        self = try reader.read(while: { _ in true }) { bytes in
            let bytes = bytes.bindMemory(to: T.CodeUnit.self)
            return String(decoding: bytes, as: encoding)
        }
    }
}
