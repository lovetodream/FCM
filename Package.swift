// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "FCM",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "FCM", targets: ["FCM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.1.2"),
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "5.0.0-alpha"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.27.0"),
    ],
    targets: [
        .target(name: "FCM", dependencies: [
            .product(name: "JWTKit", package: "jwt-kit"),
            .product(name: "MultipartKit", package: "multipart-kit"),
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
        ]),
        .testTarget(name: "FCMTests", dependencies: [
            .target(name: "FCM"),
        ]),
    ]
)
