
## naming WITHOUT the extensions [.tex] or [.bib]
LATEXFILE=modele_letter
#BIBTEFILE=modele_biblio

## the local software...
CCPDFLA=pdflatex
CCLATEX=latex
CCBIBTE=bibtex
CCPDFTE=dvipdf
CCPSTEX=dvips

all : pdflatex

pdf : $(LATEXFILE).dvi
	$(CCPDFTE) $(LATEXFILE).dvi

ps : $(LATEXFILE).dvi
	$(CCPSTEX) $(LATEXFILE).dvi

clean : $(LATEXFILE).log $(LATEXFILE).out mrproper
	rm $(LATEXFILE).log
	rm $(LATEXFILE).out
	# rm $(LATEXFILE).dvi
	# rm $(LATEXFILE).pdf

mrproper : $(LATEXFILE).aux
	rm $(LATEXFILE).aux

$(LATEXFILE).dvi : $(LATEXFILE).tex #$(BIBTEFILE).bib
	$(CCLATEX) $(LATEXFILE).tex
	# $(CCBIBTE) $(LATEXFILE)
	$(CCLATEX) $(LATEXFILE).tex
	$(CCLATEX) $(LATEXFILE).tex

pdflatex : $(LATEXFILE).tex #$(BIBTEFILE).bib
	$(CCPDFLA) $(LATEXFILE).tex
	# $(CCBIBTE) $(BIBTEFILE)
	$(CCPDFLA) $(LATEXFILE).tex
	$(CCPDFLA) $(LATEXFILE).tex
