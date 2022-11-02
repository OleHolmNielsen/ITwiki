# Customized makefile for Sphinx documentation
# based upon .../site-packages/sphinx/templates/quickstart/Makefile.new_t

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build
#
# CUSTOMIZE this: Location of your web-server pages
WEBTOPDIR     = /var/www/wiki

# Default rule is dirhtml
# Check for Python virtual environment
ifneq ($(VIRTUAL_ENV),)
dirhtml:
else
$(error VIRTUAL_ENV not set! Please use a Python virtual environment: . venv/bin/activate )
endif

# Rsync HTML files.
# The destination directory is WEBTOPDIR + the name of the current directory $PWD
rsync: dirhtml
	@echo Rsyncing HTML pages to ${WEBTOPDIR}/`basename $$PWD`/
	@rsync -av --delete ./_build/dirhtml/ ${WEBTOPDIR}/`basename $$PWD`/

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
