#!/bin/bash

# Générer le réseau aléatoire
# Compiler le fichier LaTeX
# Nettoyer les fichiers temporaires
# Afficher "Diagramme UML généré dans network_diagram.pdf"
python3 network_generator.py && pdflatex network_diagram.tex && rm network_diagram.aux network_diagram.log && echo "Diagramme UML généré dans network_diagram.pdf" 
