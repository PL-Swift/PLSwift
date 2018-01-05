# GNUmakefile

-include config.make
include xcconfig/config.make

PACKAGE=plswift

MAJOR=0
MINOR=1
SUBMINOR=0

SWIFT_SHIM_FILES = $(wildcard shims/*.h)

SCRIPTS = $(wildcard swift-pl/swift-pl*)

PACKAGE_DESCRIPTION = "Swift language support for PostgreSQL Server Extensions"

include xcconfig/rules-pgconfig.make
