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
