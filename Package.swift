// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Komondor",
    products: [
        .executable(name: "komondor", targets: ["Komondor"]),
    ],
    dependencies: [
        // User deps
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6")
    ],
    targets: [
        .target(
            name: "Komondor",
            dependencies: ["ShellOut", "Yams"]
        ),
    ]
)
