




RUBBER_INSTALLED := $(shell command -v rubber 2>/dev/null)

WD := $(shell pwd)

all: template.pdf

template.pdf: template.tex
ifdef RUBBER_INSTALLED
	rubber -d template.tex
else
	pdflatex template.tex
	#bibtex 
	pdflatex template.tex
	pdflatex template.tex
	@echo "=============================="
	@echo "= consider installing rubber ="
	@echo "=============================="
endif

clean:
	rm -f *.out
	rm -f *.toc
	rm -f *.log
	rm -f *.aux
	rm -f *.pdf
	rm -f *.bbl
	rm -f *.blg
	rm -f *~
	rm -f *.tar.gz
		
show: 
	evince *.pdf &
