.PHONY: test

test:
	## double $$ because of make evaluation of variables
	Rscript -e 'devtools::test(reporter = MochaReporter$$new())'
