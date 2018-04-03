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

@inline(__always)
@discardableResult
func systemError<T: SignedNumeric>(_ task: () -> T) throws -> T {
    let result = task()
    guard result != -1 else {
        throw SystemError()
    }
    return result
}


@inline(__always)
func systemError<T>(
    _ task: () -> UnsafeMutablePointer<T>?) throws -> UnsafeMutablePointer<T>
{
    guard let result = task() else {
        throw SystemError()
    }
    return result
}

@inline(__always)
func systemError(
    _ task: () -> OpaquePointer?) throws -> OpaquePointer
{
    guard let result = task() else {
        throw SystemError()
    }
    return result
}
