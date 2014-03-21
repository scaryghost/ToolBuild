ifndef APP_NAME
    $(error Required variable "APP_NAME" not set)
endif
ifndef MODULES
    $(error Required variable "MODULES" not set)
endif

$(shell ./ToolBuild/configure_version.sh)
-include project_version.mk

BUILD_DIR?=build
DIST_DIR?=dist
CONFIGURATION?=release

ifndef PLATFORM
    ifeq ($(shell uname -m), x86_64)
        PLATFORM:=x64
    else
        PLATFORM:=x86
    endif
endif

SRCS:=

MODULES_CONFIG:= $(addsuffix /src/config.mk, $(MODULES))
MODULES_RULES:= $(addsuffix /src/rules.mk, $(MODULES))

include $(MODULES_CONFIG)
-include $(MODULES_RULES)

CXXFLAGS:=$(C_FLAGS) $(addprefix -I,$(INC_DIRS))
ifeq ($(CONFIGURATION),debug)
    APP_NAME:=$(APP_NAME)_d
    CXXFLAGS+=-g
else ifeq ($(CONFIGURATION),release)
    CXXFLAGS+=-O3
else
    $(error Invalid value for "CONFIGURATION", must be 'release' or 'debug')
endif

ifeq ($(APP_TYPE),static_lib)
    CXXFLAGS+=-fPIC
    APP_NAME:=lib$(APP_NAME).a
else ifeq ($(APP_TYPE),dynamic_lib)
    APP_SO_NAME:=lib$(APP_NAME).so
    APP_SHORT_NAME:=$(APP_SO_NAME).$(VERSION_MAJOR)
    APP_NAME:=$(APP_SO_NAME).$(VERSION)
    CXXFLAGS+=-fPIC
    LD_FLAGS:=-s -shared -Wl,--soname,$(APP_SHORT_NAME)
else ifeq ($(APP_TYPE),app)
    LD_FLAGS:=$(addprefix -L,$(LIB_DIRS)) $(addprefix -l,$(LIB_NAMES))
else
    $(error Invalid value for "APP_TYPE", must be 'static_lib', 'dynamic_lib', or 'app')
endif

ifeq ($(PLATFORM),x86)
    CXXFLAGS+=-m32
else ifeq ($(PLATFORM),x64)
    CXXFLAGS+=-m64
else
    $(error Unrecognized PLATFORM value, use x86 or x64)
endif
REAL_DIST_DIR:=$(DIST_DIR)/$(PLATFORM)
REAL_BUILD_DIR:=$(BUILD_DIR)/$(PLATFORM)/$(CONFIGURATION)

OBJS:=$(addprefix $(REAL_BUILD_DIR)/,$(SRCS:%.cpp=%.o))
APP_OUTPUT:=$(REAL_DIST_DIR)/$(APP_NAME)

all: $(REAL_BUILD_DIR) $(REAL_DIST_DIR) $(APP_OUTPUT)

$(REAL_BUILD_DIR)/%.o: %.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(REAL_BUILD_DIR):
	find $(MODULES) -type d -exec mkdir -p -- "$@/{}" \;

$(REAL_DIST_DIR):
	mkdir -p $@

$(APP_OUTPUT): $(OBJS)
ifeq ($(APP_TYPE),static_lib)
	$(AR) -cvru $@ $?
else ifeq ($(APP_TYPE),dynamic_lib)
	$(CXX) -o $@ $(LD_FLAGS) $^
	ln -s $(APP_NAME) $(REAL_DIST_DIR)/$(APP_SHORT_NAME)
	ln -s $(APP_SHORT_NAME) $(REAL_DIST_DIR)/$(APP_SO_NAME)
else ifeq ($(APP_TYPE),app)
	$(CXX) -o $@ $^ $(LD_FLAGS)
endif

clean:
	rm -Rf $(OBJS) $(REAL_DIST_DIR)

cleanest:
	rm -Rf $(BUILD_DIR) $(DIST_DIR)
