<h2>PL/Swift
  <img src="http://zeezide.com/img/plswift.svg"
       align="right" width="128" height="128" />
</h2>

![PostgreSQL](https://img.shields.io/badge/postgresql-10-yellow.svg)
![Swift3](https://img.shields.io/badge/swift-3-blue.svg)
![Swift4](https://img.shields.io/badge/swift-4-blue.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)


**PL/Swift** allows you to write custom SQL functions and types
for the
[PostgreSQL](https://www.postgresql.org) database server
in the 
[Swift](http://swift.org/)
programming language.

<center>*Bringing Swift to the Backend of the Backend's Backend*</center>

### PL/Swift

Despite the name it is not (currently) a language extension like say
[PL/Python](https://www.postgresql.org/docs/current/static/plpython.html),
which allows you to directly embed Swift code in SQL.
Instead it provides the infrastructure to create PostgreSQL
dynamically loadable objects.

This project/sourcedir contains the `swift-pl` tool,
Xcode base configurations and module maps for the PostgreSQL server.


### What is a PL/Swift Extension

A dynamically loadable PostgreSQL extension module consists of those files:

- the ext.control file, specifies the name and version of the extension
- the ext.sql file, hooks up the C function w/ PostgreSQL
  (i.e. does the `CREATE FUNCTION`)
- the actual ext.so shared library


### Using the PL/Swift package

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


# Building a PL/Swift module

Simply invoke

    swift pl build

This wraps Swift Package Manager to build your package
and then produces a proper module which can be loaded
into PostgreSQL.

To install the module into the local PostgreSQL, call:

    swift pl install


### Use/load the extension

That is very simple, just do a:

```sql
CREATE EXTENSION helloswift;
```

If you rebuild the extension and need to reload, you probably need to
restart / reconnected
`psql` and do a `DROP EXTENSION xyz` first.


### Status

Consider this a demo. Though it should work just fine.

Plans:

- can we make it a real language module? i.e. embed Swift code in the
  SQL and compile it on demand? Why not, might be a bit heavy though.

### Links

- [mod_swift](http://mod-swift.org/), write Apache2 modules in Swift
- [PostgreSQL Server Programming](https://www.postgresql.org/docs/current/static/server-programming.html)
- [PostgreSQL C Language Functions](https://www.postgresql.org/docs/current/static/xfunc-c.html)

### Who

**PL/Swift** is brought to you by
[ZeeZide](http://zeezide.de).
We like feedback, GitHub stars, cool contract work,
presumably any form of praise you can think of.
