SOURCE_DOCS := $(wildcard *.md)
TARGET_DOCS := $(SOURCE_DOCS:.md=.html)

%.html : %.md
	pandoc --css pandoc_notes.css -s -f markdown+smart --to=html5 $< -o $@

.PHONY: all clean

all: $(TARGET_DOCS)

clean:
	/bin/rm $(TARGET_DOCS)
