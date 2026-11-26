// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ComicInfoMetron",
  platforms: [
    .macOS(.v27),
    .iOS(.v27),
  ],
  products: [
    .library(
      name: "ComicInfoMetron",
      targets: ["ComicInfoMetron"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/veganstraightedge/ComicInfo.swift.git", from: "1.10.0")
  ],
  targets: [
    .target(
      name: "ComicInfoMetron",
      dependencies: [
        .product(name: "ComicInfo", package: "ComicInfo.swift")
      ]
    ),
    .testTarget(
      name: "ComicInfoMetronTests",
      dependencies: ["ComicInfoMetron"],
      resources: [.copy("Fixtures")]
    ),
  ]
)
