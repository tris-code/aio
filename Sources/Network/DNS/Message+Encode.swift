/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

extension Message {
    var bytes: [UInt8] {
        var bytes = [UInt8]()
        encode(to: &bytes)
        return bytes
    }

    func encode(to buffer: inout [UInt8]) {
        let id = UInt16(extendingOrTruncating: self.id)
        buffer.append(UInt8(extendingOrTruncating: id >> 8))
        buffer.append(UInt8(extendingOrTruncating: id))

        var mask: UInt16 = 0

        mask |= type.rawValue << 15
        mask |= kind.rawValue << 11
        mask |= ((isAuthoritative ? 1 : 0) as UInt16) << 10
        mask |= ((isTruncated ? 1 : 0) as UInt16) << 9
        mask |= ((isRecursionDesired ? 1 : 0) as UInt16) << 8
        mask |= ((isRecursionAvailable ? 1 : 0) as UInt16) << 7

        buffer.append(UInt8(extendingOrTruncating: mask >> 8))
        buffer.append(UInt8(extendingOrTruncating: mask))

        let count = UInt16(extendingOrTruncating: question.count)
        buffer.append(UInt8(extendingOrTruncating: count >> 8))
        buffer.append(UInt8(extendingOrTruncating: count))

        buffer.append(0)
        buffer.append(0)

        buffer.append(0)
        buffer.append(0)

        buffer.append(0)
        buffer.append(0)

        for questionRecord in question {
            for part in questionRecord.name.components(separatedBy: ".") {
                buffer.append(UInt8(extendingOrTruncating: part.utf8.count))
                buffer.append(contentsOf: [UInt8](part.utf8))
            }
            buffer.append(0)

            let type = questionRecord.type.rawValue
            buffer.append(UInt8(extendingOrTruncating: type >> 8))
            buffer.append(UInt8(extendingOrTruncating: type))

            let klass = ResourceClass.in.rawValue
            buffer.append(UInt8(extendingOrTruncating: klass >> 8))
            buffer.append(UInt8(extendingOrTruncating: klass))
        }
    }
}