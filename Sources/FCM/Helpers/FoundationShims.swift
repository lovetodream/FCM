#if canImport(FoundationEssentials)
import struct FoundationEssentials.Date
import struct FoundationEssentials.UUID
#else
import struct Foundation.Date
import struct Foundation.UUID
#endif

typealias FCMDate = Date
typealias FCMUUID = UUID
