
## naming WITHOUT the extensions [.tex] or [.bib]
LATEXFILE=modele

## the local software...
CCPDFLA=pdflatex
CCLATEX=latex

all : pdflatex

clean : $(LATEXFILE).log mrproper
	rm $(LATEXFILE).log

mrproper : $(LATEXFILE).aux
	rm $(LATEXFILE).aux

pdflatex : $(LATEXFILE).tex
	$(CCPDFLA) $(LATEXFILE).tex
	$(CCPDFLA) $(LATEXFILE).tex
	$(CCPDFLA) $(LATEXFILE).tex
