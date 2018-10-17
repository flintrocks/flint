// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "swift-langsrv",
    targets: [
        Target(name: "langsrvlib", dependencies: []),
        Target(name: "langsrv", dependencies: ["langsrvlib"])
    ],
    dependencies: [
        .Package(url: "https://github.com/theguild/json-swift.git", majorVersion: 4, minor: 0),
        .Package(url: "https://github.com/theguild/swift-lsp.git", majorVersion: 4, minor: 0)
    ]   
)
