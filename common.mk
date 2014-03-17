ifndef APP_NAME
    $(error Required variable "APP_NAME" not set)
endif
ifndef MODULES
    $(error Required variable "MODULES" not set)
endif

BUILD_DIR:=build
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
else
    ifeq ($(APP_TYPE),dynamic_lib)
        CXXFLAGS+=-fPIC
        APP_SO_NAME:=lib$(APP_NAME).so
        APP_SHORT_NAME:=$(APP_SO_NAME).$(VERSION_MAJOR)
        APP_NAME:=$(APP_SO_NAME).$(VERSION)
    else
        ifneq ($(APP_TYPE),app)
            $(error Invalid value for "APP_TYPE", must be 'static_lib', \
                    'dynamic_lib', or 'app')
        endif
    endif
endif

ifeq ($(PLATFORM),x86)
    CXXFLAGS+=-m32
else
    ifeq ($(PLATFORM),x64)
        CXXFLAGS+=-m64
    else
        $(error Unrecognized PLATFORM value, use x86 or x64)
    endif
endif

OBJS:=$(addprefix $(BUILD_DIR)/$(PLATFORM)/,$(SRCS:%.cpp=%.o))
APP_OUTPUT:=$(DIST_DIR)/$(PLATFORM)/$(APP_NAME)

all: $(BUILD_DIR)/$(PLATFORM) $(DIST_DIR)/$(PLATFORM) $(APP_OUTPUT)

$(BUILD_DIR)/$(PLATFORM)/%.o: %.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $<

$(BUILD_DIR)/$(PLATFORM):
	find $(MODULES) -type d -exec mkdir -p -- "$(BUILD_DIR)/$(PLATFORM)/{}" \;

$(DIST_DIR)/$(PLATFORM):
	mkdir -p $@

