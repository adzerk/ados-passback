.PHONY: all clean
.PRECIOUS: %.js

%.js: %.coffee
	coffee -c $<

%.js.gz: %.js
	gzip -c $< > $@

all: ados-passback.js.gz

clean:
	rm -f *.js *.gz
