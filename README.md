<h2>PL/Swift
  <img src="http://zeezide.com/img/plswift.svg"
       align="right" width="128" height="128" />
</h2>

![PostgreSQL](https://img.shields.io/badge/postgresql-10-yellow.svg)
![Swift3](https://img.shields.io/badge/swift-3-blue.svg)
![Swift4](https://img.shields.io/badge/swift-4-blue.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)

A Swift API for PostgreSQL Server Extensions.
This wraps the CPLSwift system package and
provides Swift convenience on top of that.
This package is part of the [PL/Swift](https://github.com/PL-Swift/) effort.

All this is a very low level API.


### Using the PLSwift package

*NOTE*: This *requires* a PL/Swift installation. W/o it, it will
        fail to built CPLSwift!

If you setup a new module from scratch, use:

    swift pl init
    
for example:

    mkdir base36 && cd base36
    swift pl init

Otherwise setup your Package.swift to include PLSwift:

```Swift
import PackageDescription

let package = Package(
  name: "MyTool",

  dependencies: [
    .Package(url: "git@github.com:PL-Swift/PLSwift.git", majorVersion: 0),
  ]
)
```


# Building an PLSwift module

Simply invoke

    swift pl build

This wraps Swift Package Manager to build your package
and then produce a proper module which can be loaded
into PostgreSQL.


### Who

**PL/Swift** is brought to you by
[ZeeZide](http://zeezide.de).
We like feedback, GitHub stars, cool contract work,
presumably any form of praise you can think of.
