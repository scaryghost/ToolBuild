MODULES_CONFIG:= $(addsuffix /src/config.mk, $(MODuLES))
MODULES_RULES:= $(addsuffix /src/rules.mk, $(MODuLES))

include $(MODULES_CONFIG)
include $(MODULES_RULES)

CXXFLAGS:=$(C_FLAGS) $(addprefix -I,$(INC_DIRS))
ifeq ($(PLATFORM),x86)
    CXXFLAGS+=-m32
else
    ifeq($(PLATFORM),x64)
        CXXFLAGS+=-m64
    else
        $(error Unrecognized PLATFORM value, use x86 or x64)
    endif
endif
OJBS:=$(addprefix $(BUILD_DIR)/$(PLATFORM)/,$(SRCS:%.c=%.o))

APP_OUTPUT:=$(DIST_DIR)/$(PLATFORM)/$(APP_NAME)

all: $(APP_OUTPUT) $(DIST_DIR)/$(PLATFORM)

$(DIST_DIR)/$(PLATFORM):
	mkdir -p $@

