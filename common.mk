ifndef APP_NAME
    $(error Required variable "APP_NAME" not set)
endif
ifndef MODULES
    $(error Required variable "MODULES" not set)
endif

BUILD_DIR?=build
DIST_DIR?=dist
PLATFORM?=x64

SRCS:=

MODULES_CONFIG:= $(addsuffix /src/config.mk, $(MODULES))
MODULES_RULES:= $(addsuffix /src/rules.mk, $(MODULES))

include $(MODULES_CONFIG)
-include $(MODULES_RULES)

CXXFLAGS:=$(C_FLAGS) $(addprefix -I,$(INC_DIRS))
ifeq ($(APP_TYPE),static_lib)
    CXXFLAGS+=-fPIC
    APP_NAME:=lib$(APP_NAME).a
else ifeq ($(APP_TYPE),dynamic_lib)
    CXXFLAGS+=-fPIC
    LD_FLAGS:=-s -shared -Wl,--soname,$(SO_SHORT_NAME)
    APP_SO_NAME:=lib$(APP_NAME).so
    APP_SHORT_NAME:=$(APP_SO_NAME).$(VERSION_MAJOR)
    APP_NAME:=$(APP_SO_NAME).$(VERSION)
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
DIST_DIR_PLATFORM:=$(DIST_DIR)/$(PLATFORM)
BUILD_DIR_PLATFORM:=$(BUILD_DIR)/$(PLATFORM)

OBJS:=$(addprefix $(BUILD_DIR_PLATFORM)/,$(SRCS:%.cpp=%.o))
APP_OUTPUT:=$(DIST_DIR_PLATFORM)/$(APP_NAME)

all: $(BUILD_DIR_PLATFORM) $(DIST_DIR_PLATFORM) $(APP_OUTPUT)

$(BUILD_DIR_PLATFORM)/%.o: %.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD_DIR_PLATFORM):
	find $(MODULES) -type d -exec mkdir -p -- "$@/{}" \;

$(DIST_DIR_PLATFORM):
	mkdir -p $@

$(APP_OUTPUT): $(OBJS)
ifeq ($(APP_TYPE),static_lib)
	$(AR) -cvru $@ $?
else ifeq ($(APP_TYPE),dynamic_lib)
	$(CXX) -o $@ $(LD_FLAGS) $^
	ln -s $(APP_NAME) $(DIST_DIR_PLATFORM)/$(APP_SHORT_NAME)
	ln -s $(APP_SHORT_NAME) $(DIST_DIR_PLATFORM)/$(APP_SO_NAME)
else ifeq ($(APP_TYPE),app)
	$(CXX) -o $@ $^ $(LD_FLAGS)
endif
