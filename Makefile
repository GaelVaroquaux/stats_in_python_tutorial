# Makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         = a4
PYTHON        = python

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d _build/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .


.PHONY: help clean html web pickle htmlhelp latex changes linkcheck zip

all: test html

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  html      to make standalone HTML files"
	@echo "  pickle    to make pickle files (usable by e.g. sphinx-web)"
	@echo "  htmlhelp  to make HTML files and a HTML help project"
	@echo "  latex     to make LaTeX files, you can set PAPER=a4 or PAPER=letter"
	@echo "  pdf       to make PDF from LaTeX, you can set PAPER=a4 or PAPER=letter"
	@echo "  changes   to make an overview over all changed/added/deprecated items"
	@echo "  linkcheck to check all external links for integrity"
	@echo "  install   to upload to github the web pages"
	@echo "  zip       to create the zip file with examples and doc"

clean:
	-rm -rf _build/*

test:
	nosetests -v --with-doctest --doctest-tests --doctest-extension=rst $(shell find . -name \*.rst -print)

html:
	mkdir -p _build/html _build/doctrees
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) _build/html
	@echo
	@echo "Build finished. The HTML pages are in _build/html."

pickle:
	mkdir -p _build/pickle _build/doctrees
	$(SPHINXBUILD) -b pickle $(ALLSPHINXOPTS) _build/pickle
	@echo
	@echo "Build finished; now you can process the pickle files or run"
	@echo "  sphinx-web _build/pickle"
	@echo "to start the sphinx-web server."

web: pickle

htmlhelp:
	mkdir -p _build/htmlhelp _build/doctrees
	$(SPHINXBUILD) -b htmlhelp $(ALLSPHINXOPTS) _build/htmlhelp
	@echo
	@echo "Build finished; now you can run HTML Help Workshop with the" \
	      ".hhp project file in _build/htmlhelp."

latex:
	mkdir -p _build/latex _build/doctrees
	$(SPHINXBUILD) -b $@ $(ALLSPHINXOPTS) _build/latex
	@echo
	@echo "Build finished; the LaTeX files are in _build/latex."
	@echo "Run \`make all-pdf' or \`make all-ps' in that directory to" \
	      "run these through (pdf)latex."

latexpdf: latex
	$(MAKE) -C _build/latex all-pdf

changes:
	mkdir -p _build/changes _build/doctrees
	$(SPHINXBUILD) -b changes $(ALLSPHINXOPTS) _build/changes
	@echo
	@echo "The overview file is in _build/changes."

linkcheck:
	mkdir -p _build/linkcheck _build/doctrees
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) _build/linkcheck
	@echo
	@echo "Link check complete; look for any errors in the above output " \
	      "or in _build/linkcheck/output.txt."

zip: html
	mkdir -p _build/stats_in_python ;
	cp -r _build/html _build/stats_in_python ;
	zip -r _build/stats_in_python.zip _build/stats_in_python

install: html
	rm -rf _build/gh-pages
	cd _build/ && \
        git clone .. gh-pages && \
	cd gh-pages && \
	git remote add github git@github.com:GaelVaroquaux/stats_in_python_tutorial.git && \
	git checkout gh-pages && \
	git fetch github && \
	git merge github/gh-pages && \
	cp -r ../html/* . && \
	git add * && \
	git commit -a -m 'Make install' && \
	git push github

epub:
	$(SPHINXBUILD) -b epub $(ALLSPHINXOPTS) _build/epub
	@echo
	@echo "Build finished. The epub file is in _build/epub."


