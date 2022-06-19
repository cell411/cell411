export PARSE_FLAVOR=parse
SHELL:=/bin/bash -o pipefail

makeRelationships:

all:

%: %.mjs
	@echo $@.out:1:output
	node --trace-uncaught $@.mjs 2>&1 | tee $@.out

#    fuck: makeRelationships.js.json
#    
#    makeRelationships.js.psn:

%: %.js.json
	touch $@ && rm -f $@


%.json: %
	@echo $@:1:data
	bash runtest.sh node $<
	touch $<

%js.json: %.js
	@echo $@:1:data
	bash runtest.sh $<

