// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CustomConfirmationDialog",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CustomConfirmationDialog",
            targets: ["CustomConfirmationDialog"]
        )
    ],
    targets: [
        .target(
            name: "CustomConfirmationDialog",
            path: "Sources/CustomConfirmationDialog"
        )
    ]
)
