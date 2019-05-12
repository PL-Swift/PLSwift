import PackageDescription

let package = Package(
    name: "PLSwift",

    dependencies: [
      .Package(url: "https://github.com/PL-Swift/CPLSwift.git", 
               majorVersion: 0, minor: 3)
    ]
)
