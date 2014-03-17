$(APP_OUTPUT): $(OBJS)
	$(AR) -cvru $@ $?
