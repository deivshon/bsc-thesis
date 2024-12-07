build:
	latexmk -pdf --shell-escape slides.tex
watch:
	latexmk -pdf -pvc --shell-escape slides.tex
clean:
	rm -f *blx.bib *.bbl *.nav *.snm *.fls
	rm -f indent.log
	latexmk -C -bibtex-cond1
