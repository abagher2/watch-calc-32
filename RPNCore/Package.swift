// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RPNCore",
    platforms: [
        .watchOS(.v10),
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "RPNCore",
            targets: ["RPNCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/abdel-17/swift-rational.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "RPNCoreC"),
        .target(
            name: "RPNCore",
            dependencies: [
                "RPNCoreC",
                .product(name: "RationalModule", package: "swift-rational")
            ]),
        .testTarget(
            name: "RPNCoreTests",
            dependencies: ["RPNCore"]),
        .executableTarget(
            name: "ParityExporter",
            dependencies: ["RPNCore"]),
        .executableTarget(
            name: "FontExporter",
            dependencies: ["RPNCore"])
    ]
)
