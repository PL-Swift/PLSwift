# GNUmakefile

# Common configurations

ifeq ($(prefix),)
  prefix=/usr/local
endif

SHARED_LIBRARY_PREFIX=lib

MKDIR_P      = mkdir -p
INSTALL_FILE = cp

UNAME_S := $(shell uname -s)

# Apache stuff

ifeq ($(PG_CONFIG),)
  PG_CONFIG=$(shell which pg_config)
endif
ifneq ($(PG_CONFIG),)
  HAVE_PG_CONFIG=yes
else
  HAVE_PG_CONFIG=no
endif
USE_PG_CONFIG=$(HAVE_PG_CONFIG)

ifeq ($(HAVE_PG_CONFIG),yes)
  PG_CONFIG_EXTRA_CFLAGS=
  PG_CONFIG_EXTRA_LDFLAGS=
endif


# System specific configuration

USE_BREW=no

ifeq ($(UNAME_S),Darwin)
  SHARED_LIBRARY_SUFFIX=.dylib
  PG_MODULE_SUFFIX:=.so # yes
  INSTALL_FILE = cp -X
  
  ifeq ($(USE_PG_CONFIG),yes)
    PG_CONFIG_EXTRA_CFLAGS += -Wno-nullability-completeness

    ifneq ($(brew),no)
      ifeq ($(BREW),)
        BREW=$(shell which brew)
      endif
      ifneq (,$(BREW)) # use Homebrew locations
        USE_BREW=yes
      endif
    endif
  endif

  ifeq ($(prefix),)
    prefix = /usr/local # TBD
  endif
else # Linux
  # e.g.: OS=ubuntu VER=14.04
  # OS=$(shell lsb_release -si | tr A-Z a-z)
  # VER=$(shell lsb_release -sr)

  SHARED_LIBRARY_SUFFIX=.so
endif

ifeq ($(PG_MODULE_SUFFIX),)
  PG_MODULE_SUFFIX:=$(SHARED_LIBRARY_SUFFIX)
endif


# Debug or Release?

ifeq ($(debug),on)
  PG_CONFIG_EXTRA_CFLAGS  += -g
  PG_CONFIG_EXTRA_LDFLAGS += -g
endif


# APR and APU configs

ifeq ($(USE_PG_CONFIG),yes)
  PKGCONFIG_LDFLAGS  +=
  PKGCONFIG_LIB_DIRS += 
endif


# We have set prefix above, or we got it via ./config.make
# Now we need to derive:
# - BINARY_INSTALL_DIR            e.g. /usr/local/bin
# - APACHE_MODULE_INSTALL_DIR
# - HEADER_FILES_INSTALL_DIR      e.g. /usr/local/include
# - PKGCONFIG_INSTALL_DIR         e.g. /usr/local/lib/pkgconfig
# - XCCONFIG_INSTALL_DIR          e.g. /usr/local/lib/xcconfig
# - MODMAP_INSTALL_DIR            e.g. /usr/local/lib/modmap
# - SWIFT_SHIM_INSTALL_DIR        e.g. /usr/local/lib/swift/shims

ifeq ($(BINARY_INSTALL_DIR),)
  BINARY_INSTALL_DIR=$(prefix)/bin
endif

ifeq ($(APACHE_MODULE_INSTALL_DIR),)
  ifeq ($(USE_PG_CONFIG),yes)
    APACHE_MODULE_RELDIR3=$(shell apxs -q | grep ^libexecdir | sed "s/libexecdir=.*}//g" | sed "sTlibexecdir=$(prefix)TTg" | sed "s/libexecdir=//g" )
    APACHE_MODULE_RELDIR2=$(subst /usr/local,,$(APACHE_MODULE_RELDIR3))
    APACHE_MODULE_RELDIR=$(subst /usr,,$(APACHE_MODULE_RELDIR2))
    APACHE_MODULE_INSTALL_DIR=${prefix}/${APACHE_MODULE_RELDIR}
  else
    ifeq ($(UNAME_S),Darwin)
      APACHE_MODULE_INSTALL_DIR="$(prefix)/libexec/apache2"
    else # Linux: this may be different depending on the distro
      APACHE_MODULE_INSTALL_DIR="$(prefix)/lib/apache2/modules"
    endif
  endif
endif

ifeq ($(HEADER_FILES_INSTALL_DIR),)
  HEADER_FILES_INSTALL_DIR=$(prefix)/include
endif
ifeq ($(PKGCONFIG_INSTALL_DIR),)
  # on Trusty most live in lib/x86_64-linux-gnu/pkgconfig. TBD
  PKGCONFIG_INSTALL_DIR=$(prefix)/lib/pkgconfig
endif

ifeq ($(XCCONFIG_INSTALL_DIR),)
  XCCONFIG_INSTALL_DIR=$(prefix)/lib/xcconfig
endif
ifeq ($(MODMAP_INSTALL_DIR),)
  MODMAP_INSTALL_DIR=$(prefix)/lib/modmap
endif

ifeq ($(SWIFT_SHIM_INSTALL_DIR),)
  SWIFT_SHIM_INSTALL_DIR=$(prefix)/lib/swift/shims
endif
