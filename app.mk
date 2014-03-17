LD_FLAGS:=$(addprefix -L,$(LIB_DIRS)) $(addprefix -l,$(LIB_NAMES))

$(APP_OUTPUT): $(OBJS)
	$(CXX) -o $@ $^ $(LD_FLAGS)
