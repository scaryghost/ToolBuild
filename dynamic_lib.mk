SO_REAL_NAME:=$(APP_OUTPUT).$(VERSION)
SO_NAME:=$(APP_OUTPUT).$(VERSION_MAJOR)
LD_FLAGS:=-s -shared -W1,--soname,$(SO_nAME)

$(APP_OUTPUT): $(OBJS)
	$(CXX) -o $@ $(LD_FLAGS) $^
