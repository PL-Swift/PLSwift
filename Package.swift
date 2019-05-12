// swift-tools-version:4.2
//
//  Package.swift
//  PL/Swift
//
//  Created by Helge Hess on 11.05.18.
//  Copyright © 2019 ZeeZide. All rights reserved.
//
import PackageDescription

let package = Package(
    name: "PLSwift",

    products: [
      .library(name: "PLSwift", targets: [ "PLSwift" ]),
    ],

    dependencies: [
      .package(url: "https://github.com/PL-Swift/CPLSwift.git", from: "1.0.2")
    ],
    
    targets: [
      .target(name: "PLSwift", dependencies: [ "CPLSwift" ])
    ]
)
