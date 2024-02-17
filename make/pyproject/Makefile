#!/bin/echo Not executable, try 'make TARGET' instead, or 'make help' for specifics.

LINKS := $(shell find bin -type l)

# : # UTILITY #

#### GENERIC TARGETS #########################################################

help: 				# return makefile targets
	@echo ' usage: make target [...target]'
	@cat Makefile | grep -E '^[a-z][^:]*:|^# : ' | sed 's/\([^:]*\):[^#]*/\1#/g' | { \
		while IFS=# read -r ITEM COMMENT ; do printf '\t%-20s %s\n' $${ITEM} "$${COMMENT### }" | tr '#' '\n' ; done ; \
	}

#### DEPENDANCIES ############################################################



#### PACKAGING ###############################################################
.PHONY: dci-validation-config-bundle

# : # PACKAGING #

${package}.zip: # Package the DCI Validation 
	zip -u ${package}.zip stage/${package}

${package}.tgz: # Package the DCI Validation 
	tar -czvf ${package}.zip stage/${package}
 
# : # DEVELOPMENT #

installvenv: .virtualenv # install required components

venvactivate: .virtualenv	# activate virtual environment
	@echo source .virtualenv/bin/activate





# : # BUILD TARGETS #





#### CLEANUP TARGETS #########################################################
.PHONY: clean cleansymlinks

cleanvenv: # install required components
	rm -rf .virtualenv

cleansymlinks: # removes symlinks from local repository.
	@for LINK in ${LINKS}; do echo "rm $${LINK}" ; rm $${LINK} ; done

clean: cleansymlinks
