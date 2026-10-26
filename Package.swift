// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "FCM",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "FCM", targets: ["FCM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.86.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", branch: "main"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.27.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
    ],
    targets: [
        .target(name: "FCM", dependencies: [
            .product(name: "NIOCore", package: "swift-nio"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
            .product(name: "_NIOFileSystem", package: "swift-nio"),
            .product(name: "JWTKit", package: "jwt-kit"),
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
            .product(name: "HTTPTypes", package: "swift-http-types"),
            .product(name: "Algorithms", package: "swift-algorithms")
        ]),
        .testTarget(name: "FCMTests", dependencies: [
            .target(name: "FCM"),
        ]),
    ]
)
