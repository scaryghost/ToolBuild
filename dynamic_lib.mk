LD_FLAGS:=-s -shared -Wl,--soname,$(SO_SHORT_NAME)

$(APP_OUTPUT): $(OBJS)
	$(CXX) -o $@ $(LD_FLAGS) $^
	ln -s $(APP_NAME) $(DIST_DIR)/$(PLATFORM)/$(APP_SHORT_NAME)
	ln -s $(APP_SHORT_NAME) $(DIST_DIR)/$(PLATFORM)/$(APP_SO_NAME)
