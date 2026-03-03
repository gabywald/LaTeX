#!/usr/bin/env python3

"""
Description: Random <Network Generator Diagram
Author: Gabriel Chandesris 
Date Created: March 2, 2026
Date Modified: March 3, 2026
Version: 1.0.0
Python Version: 3.8.10
License: GPL
"""

import random
import math

def generate_network():
    num_nodes = random.randint(5, 15)
    node_types = ["server", "terminal", "router", "firewall", "ai", "communication", "datacenter", "iot", "storage", "control", "mainframe", "security", "virtualization", "vpn"]
    security_levels = ["Low", "Medium", "High"]

    nodes = []
    for i in range(num_nodes):
        node_type = random.choice(node_types)
        security = random.choice(security_levels)
        nodes.append((f"{node_type.capitalize()} {i+1}", node_type, security))

    return nodes

def generate_latex(nodes):
    num_nodes = len(nodes)
    radius = 5.0
    center_x, center_y = (0, 0)

    latex_code = r"""\documentclass[a4paper, landscape]{article}
\usepackage{tikz}
\usetikzlibrary{shapes, arrows, positioning}

\def\StylesTikzSetNetwork{
  \tikzset{
    server/.style={rectangle, draw=black, fill=blue!20, text width=5em, text centered, rounded corners, minimum height=2em},
    terminal/.style={rectangle, draw=black, fill=green!20, text width=5em, text centered, rounded corners, minimum height=2em},
    router/.style={diamond, draw=black, fill=red!20, text width=5em, text centered, minimum height=2em},
    firewall/.style={ellipse, draw=black, fill=yellow!20, text width=5em, text centered, minimum height=2em},
    ai/.style={circle, draw=black, fill=purple!20, text width=5em, text centered, minimum height=2em},
    communication/.style={trapezium, draw=black, fill=cyan!20, text width=5em, text centered, minimum height=2em},
    datacenter/.style={regular polygon, regular polygon sides=6, draw=black, fill=orange!20, text width=5em, text centered, minimum height=2em},
    iot/.style={rectangle, draw=black, fill=teal!20, text width=5em, text centered, minimum height=2em},
    storage/.style={cylinder, draw=black, fill=brown!20, text width=5em, text centered, shape aspect=0.2, minimum height=2em, shape border rotate=90},
    control/.style={star, draw=black, fill=magenta!20, text width=5em, text centered, minimum height=2em},
    mainframe/.style={rectangle, draw=black, fill=gray!20, text width=5em, text centered, minimum height=4em},
    security/.style={ellipse, draw=black, fill=black!20, text=white, text width=5em, text centered, minimum height=2em},
    virtualization/.style={rectangle, draw=black, fill=lime!20, text width=5em, text centered, minimum height=2em},
    vpn/.style={rectangle, draw=black, fill=pink!20, text width=5em, text centered, minimum height=2em},
    line/.style={draw, -latex'}
  }
}

\begin{document}

\begin{tikzpicture}[node distance=2cm, auto]

    % Styles
	\StylesTikzSetNetwork

    % Nodes
"""

    angles = [2 * math.pi * i / num_nodes for i in range(num_nodes)]
    for idx, (name, node_type, security) in enumerate(nodes):
        x = center_x + radius * math.cos(angles[idx])
        y = center_y + radius * math.sin(angles[idx])
        latex_code += f"\n    \\node [{node_type}] (Node{idx}) at ({x},{y}) {{{name} ({security})}};"

    # Connections
    latex_code += "\n\n    % Connections"
    for i in range(num_nodes):
        for j in range(i+1, num_nodes):
            if random.random() < 0.3:  # Probabilité de connexion
                latex_code += f"\n    \\path [line] (Node{i}) -- (Node{j});"

    # Légende
    latex_code += r"""
\end{tikzpicture}

\vspace{1cm}
% Légende
\begin{center}
\begin{tikzpicture}
    % Styles
	\StylesTikzSetNetwork
	% Utilisation
    \matrix [draw, column sep=1cm, row sep=0.5cm] {
        \node [server, label=right:Serveur] {{}}; &
        \node [terminal, label=right:Terminal] {{}}; &
        \node [router, label=right:Routeur] {{}}; &
        \node [firewall, label=right:Pare-feu] {{}}; \\
        \node [ai, label=right:IA] {{}}; &
        \node [communication, label=right:Noeud de Communication] {{}}; &
        \node [datacenter, label=right:Data Center] {{}}; &
        \node [iot, label=right:Dispositif IoT] {{}}; \\
        \node [storage, label=right:Noeud de Stockage] {{}}; &
        \node [control, label=right:Noeud de Contrôle] {{}}; &
        \node [mainframe, label=right:Mainframe] {{}}; &
        \node [security, label=right:Noeud de Sécurité] {{}}; \\
        \node [virtualization, label=right:Noeud de Virtualisation] {{}}; &
        \node [vpn, label=right:Noeud VPN] {{}}; &
        \node {{}}; &
        \node {{}}; \\
    };
\end{tikzpicture}
\end{center}

\end{document}
    """

    with open("network_diagram.tex", "w") as f:
        f.write(latex_code)

if __name__ == "__main__":
    nodes = generate_network()
    generate_latex(nodes)
    print("Diagramme UML généré dans network_diagram.tex")
