
## naming WITHOUT the extensions [.tex] or [.bib]
LATEXFILE=document

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

clean : mrproper
	# rm $(LATEXFILE).dvi
	# rm $(LATEXFILE).pdf

mrproper : $(LATEXFILE).aux $(LATEXFILE).log $(LATEXFILE).toc
	rm $(LATEXFILE).aux
	rm $(LATEXFILE).log
	rm $(LATEXFILE).toc

$(LATEXFILE).dvi : $(LATEXFILE).tex
	$(CCLATEX) $(LATEXFILE).tex
	$(CCLATEX) $(LATEXFILE).tex
	$(CCLATEX) $(LATEXFILE).tex

pdflatex : $(LATEXFILE).tex
	$(CCPDFLA) $(LATEXFILE).tex
	$(CCPDFLA) $(LATEXFILE).tex
	$(CCPDFLA) $(LATEXFILE).tex
