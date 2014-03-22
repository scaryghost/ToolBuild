TOOL_BUILD_DIR:=ToolBuild
COMMON_MK:=$(TOOL_BUILD_DIR)/common.mk
BASE_MAKE:=make -f $(COMMON_NK) $(MAKE_FLAGS)

all:
	$(BASE_MAKE)

static_lib:
	$(BASE_MAKE) APP_TYPE=static_lib

dynamic_lib:
	$(BASE_MAKE) APP_TYPE=dynamic_lib

all_lib: release_static_lib release_dynamic_lib

debug:
	$(BASE_MAKE) CONFIGURATION=debug

debug_static_lib:
	$(BASE_MAKE) CONFIGURATION=debug APP_TYPE=static_lib

debug_dynamic_lib:
	$(BASE_MAKE) CONFIGURATION=debug APP_TYPE=dynamic_lib

all_debug_lib: debug_static_lib debug_dynamic_lib

clean_debug:
	$(BASE_MK) CONFIGURATION=debug clean

clean:
	$(BASE_MK) CONFIGURATION=release clean

cleanest:
	$(BASE_MK) cleanest
