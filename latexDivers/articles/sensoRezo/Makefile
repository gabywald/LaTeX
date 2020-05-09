
## naming WITHOUT the extensions [.tex] or [.bib]
LATEXFILE=modele_sensorezo
BIBTEFILE=modele_sensorezo_biblio

## the local software...
CCLATEX=latex
CCBIBTE=bibtex
CCPDFTE=dvipdf
CCPSTEX=dvips





all : pdf

pdf : $(LATEXFILE).dvi
	$(CCPDFTE) $(LATEXFILE).dvi

ps : $(LATEXFILE).dvi
	$(CCPSTEX) $(LATEXFILE).dvi

clean : $(LATEXFILE).dvi $(LATEXFILE).log mrproper
	rm $(LATEXFILE).log
	rm $(LATEXFILE).lot
	rm $(LATEXFILE).lof
	rm $(LATEXFILE).dvi
	# rm $(LATEXFILE).pdf

mrproper : $(LATEXFILE).aux $(LATEXFILE).bbl $(LATEXFILE).blg $(LATEXFILE).toc
	rm $(LATEXFILE).aux
	rm $(LATEXFILE).bbl
	rm $(LATEXFILE).blg
	rm $(LATEXFILE).toc

$(LATEXFILE).dvi : $(LATEXFILE).tex $(BIBTEFILE).bib img/page_sensorezo.eps
	$(CCLATEX) $(LATEXFILE).tex
	$(CCBIBTE) $(LATEXFILE)
	$(CCLATEX) $(LATEXFILE).tex
	$(CCLATEX) $(LATEXFILE).tex
	$(CCLATEX) $(LATEXFILE).tex
