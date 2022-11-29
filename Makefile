SUBDIRS = notes
all:
	make -C $(@:SUBDIRS)
clean:
	make -C $(@:SUBDIRS) clean
.PHONY: all clean
