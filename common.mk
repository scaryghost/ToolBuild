BUILD_DIR:=build
DIST_DIR?=dist

SRCS:=

MODULES_CONFIG:= $(addsuffix /src/config.mk, $(MODULES))
MODULES_RULES:= $(addsuffix /src/rules.mk, $(MODULES))

include $(MODULES_CONFIG)
-include $(MODULES_RULES)

CXXFLAGS:=$(C_FLAGS) $(addprefix -I,$(INC_DIRS))
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

