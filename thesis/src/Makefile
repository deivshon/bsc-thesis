build:
	latexmk -pdf --shell-escape thesis.tex
clean:
	rm -f *blx.bib
	rm -f *bbl
	rm -f indent.log
	latexmk -C -bibtex-cond1
