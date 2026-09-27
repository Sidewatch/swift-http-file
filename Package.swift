// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-http-file",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "HTTPFile", targets: ["HTTPFile"])
    ],
    dependencies: [
        .package(url: "https://github.com/arraypress/swift-curl-parse.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "HTTPFile", dependencies: [.product(name: "CurlParse", package: "swift-curl-parse")],
            swiftSettings: [.swiftLanguageMode(.v6)]),
        .testTarget(name: "HTTPFileTests", dependencies: ["HTTPFile"], swiftSettings: [.swiftLanguageMode(.v6)]),
    ]
)
