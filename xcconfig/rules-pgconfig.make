# GNUmakefile


ifeq ($(USE_PG_CONFIG),no)
  ifeq ($(UNAME_S),Darwin)
    $(error missing pg_config)
  else
    $(error missing pg_config, did you install postgresql-server-dev?)
  endif
endif


PG_CONFIG_INCLUDE_DIRS = \
	$(shell $(PG_CONFIG) --includedir-server)	\
	$(shell $(PG_CONFIG) --pkgincludedir)/internal 	\
	$(patsubst -I%,%,$(filter -I%,$(shell $(PG_CONFIG) --cppflags)))

FILTEROUT_PG_CONFIG_LDFLAGS = \
	-L../../src/common \
	-L../../../src/common
	
PG_CONFIG_LDFLAGS = \
	$(filter-out $(FILTEROUT_PG_CONFIG_LDFLAGS),$(shell $(PG_CONFIG) --ldflags))

#RUNTIME_LIBS=-lswiftFoundation -lswiftDarwin -lswiftCore
RUNTIME_LIBS=


HELPER_BUILD_DIR = .build

PACKAGE_PKGCONFIG = $(HELPER_BUILD_DIR)/$(PACKAGE).pc
PACKAGE_XCCONFIG  = $(HELPER_BUILD_DIR)/$(PACKAGE).xcconfig
PACKAGE_MODMAP    = $(HELPER_BUILD_DIR)/module.map
PACKAGE_HELPERS   = $(PACKAGE_PKGCONFIG) $(PACKAGE_XCCONFIG) $(PACKAGE_MODMAP)

PACKAGE_MODMAP_INSTALL_DIR = $(MODMAP_INSTALL_DIR)/$(PACKAGE)/

HEADER_FILES_INSTALL_PATHES = $(addprefix $(HEADER_FILES_INSTALL_DIR)/,$(HFILES))
SHIM_FILES_INSTALL_PATHES   = $(addprefix $(SWIFT_SHIM_INSTALL_DIR)/,$(notdir $(SWIFT_SHIM_FILES)))

all : package-helpers

package-helper-build-dir :
	$(MKDIR_P) $(HELPER_BUILD_DIR)
	
package-helpers : package-helper-build-dir $(PACKAGE_HELPERS)

clean :
	rm -f  $(PACKAGE_HELPERS)

distclean : clean
	rm -rf $(HELPER_BUILD_DIR)
	rm -f config.make

install : all
	$(MKDIR_P) $(PKGCONFIG_INSTALL_DIR)	\
		   $(SWIFT_SHIM_INSTALL_DIR)	\
		   $(BINARY_INSTALL_DIR)
	$(INSTALL_FILE) $(SWIFT_SHIM_FILES)   $(SWIFT_SHIM_INSTALL_DIR)/
	$(INSTALL_FILE) $(PACKAGE_PKGCONFIG)  $(PKGCONFIG_INSTALL_DIR)/
	if test "$(UNAME_S)" = "Darwin"; then \
	  $(MKDIR_P) $(XCCONFIG_INSTALL_DIR)  $(PACKAGE_MODMAP_INSTALL_DIR); \
	  $(INSTALL_FILE) $(PACKAGE_XCCONFIG) $(XCCONFIG_INSTALL_DIR)/;	\
	  $(INSTALL_FILE) $(PACKAGE_MODMAP)   $(PACKAGE_MODMAP_INSTALL_DIR)/; \
	fi;
	$(INSTALL_FILE) $(SCRIPTS)            $(BINARY_INSTALL_DIR)/

uninstall :
	rm -f $(SHIM_FILES_INSTALL_PATHES)   				\
	      $(PKGCONFIG_INSTALL_DIR)/$(PACKAGE).pc 			\
	      $(XCCONFIG_INSTALL_DIR)/$(PACKAGE).xcconfig 		\
	      $(PACKAGE_MODMAP_INSTALL_DIR)/module.map 			\
	      $(addprefix $(BINARY_INSTALL_DIR)/,$(notdir $(SCRIPTS)))	\


# config test

testconfig:
	@echo "Brew:                $(BREW)"
	@echo "Use brew:            $(USE_BREW)"
	@echo "pg_config:           $(PG_CONFIG)"
	@echo "Prefix:              $(prefix)"
	@echo "Install module in:   $(APACHE_MODULE_INSTALL_DIR)"
	@echo "Install headers in:  $(HEADER_FILES_INSTALL_DIR)"
	@echo "Install pc in:       $(PKGCONFIG_INSTALL_DIR)"

#testconfig-swift-docker:
#	docker run --rm -v $(PWD):/src helje5/swift-pl-dev bash -c "cd /src; make testconfig"


# pkg config

PACKAGE_VERSION_STRING=$(MAJOR).$(MINOR).$(SUBMINOR)

PKGCONFIG_CFLAGS = \
	"-I\$${includedir}"		\
	"-I\$${libdir}/swift/shims"	\
	$(addprefix -I,$(PG_CONFIG_INCLUDE_DIRS))

PKGCONFIG_LDFLAGS_NO_LIBS =

# Also: libs. Not served by apxs which doesn't need libs, but we might still
#.      want to do those for apr/apu apps?
$(PACKAGE_PKGCONFIG) : $(wildcard config.make)
	@echo "prefix=$(prefix)" > "$(PACKAGE_PKGCONFIG)"
	@echo "includedir=$(HEADER_FILES_INSTALL_DIR)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "libdir=$(prefix)/lib" >> "$(PACKAGE_PKGCONFIG)"
	@echo "" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Name: $(PACKAGE)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Description: $(PACKAGE_DESCRIPTION)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Version: $(PACKAGE_VERSION_STRING)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Cflags: $(PKGCONFIG_CFLAGS)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Libs: $(PKGCONFIG_LDFLAGS_NO_LIBS)" >> "$(PACKAGE_PKGCONFIG)"


# xcconfig

$(PACKAGE_XCCONFIG) : $(wildcard config.make)
	@echo "// Xcode configuration set for PL/Swift" > "$(PACKAGE_XCCONFIG)"
	@echo "// generated on $(shell date)" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "DYLIB_INSTALL_NAME_BASE = $(shell $(PG_CONFIG) --pkglibdir)" >> "$(PACKAGE_XCCONFIG)"
	@echo "EXECUTABLE_EXTENSION    = so" >> "$(PACKAGE_XCCONFIG)"
	@echo "EXECUTABLE_PREFIX       = "   >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "HEADER_SEARCH_PATHS     = \$$(inherited) $(HEADER_FILES_INSTALL_DIR) $(PG_CONFIG_INCLUDE_DIRS)" >> "$(PACKAGE_XCCONFIG)"
	@echo "LIBRARY_SEARCH_PATHS    = \$$(inherited) $(PKGCONFIG_LIB_DIRS) \$$(TOOLCHAIN_DIR)/usr/lib/swift/macosx \$$(BUILT_PRODUCTS_DIR)" >> "$(PACKAGE_XCCONFIG)"
	@echo "LD_RUNPATH_SEARCH_PATHS = \$$(inherited) \$$(TOOLCHAIN_DIR)/usr/lib/swift/macosx \$$(BUILT_PRODUCTS_DIR)" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "OTHER_CFLAGS            = \$$(inherited) $(shell $(PG_CONFIG) --cflags)" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "OTHER_LDFLAGS           = \$$(inherited) $(shell $(PG_CONFIG) --cflags) -rpath \$$(TOOLCHAIN_DIR)/usr/lib/swift/macosx -rpath \$$(BUILT_PRODUCTS_DIR) -undefined dynamic_lookup $(PG_CONFIG_LDFLAGS) $(BUNDLE_FLAGS) $(RUNTIME_LIBS)" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "SWIFT_INCLUDE_PATHS     = \$$(inherited) $(PACKAGE_MODMAP_INSTALL_DIR) \$$(TOOLCHAIN_DIR)/usr/lib/swift" >> "$(PACKAGE_XCCONFIG)"

# modmap

$(PACKAGE_MODMAP) : $(wildcard config.make)
	@echo "// PL/Swift module.map" > "$(PACKAGE_MODMAP)"
	@echo "// generated on $(shell date)" >> "$(PACKAGE_MODMAP)"
	@echo "" >> "$(PACKAGE_MODMAP)"
	@echo "module CPLSwift [system] {" >> "$(PACKAGE_MODMAP)"
	@echo "  header \"$(SWIFT_SHIM_INSTALL_DIR)/PLSwiftShim.h\"" >> "$(PACKAGE_MODMAP)"
	@echo "  export *" >> "$(PACKAGE_MODMAP)"
	@echo "}" >> "$(PACKAGE_MODMAP)"
