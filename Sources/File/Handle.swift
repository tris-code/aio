import Platform

typealias FileHandle = Descriptor

#if os(Linux)
typealias DirectoryHandle = OpaquePointer
#else
typealias DirectoryHandle = UnsafeMutablePointer<DIR>
#endif
