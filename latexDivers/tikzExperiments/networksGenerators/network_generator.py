#!/usr/bin/env python3

"""
Description: Random <Network Generator Diagram
Author: Gabriel Chandesris 
Date Created: March 5, 2026
Date Modified: March 5, 2026
Version: 1.0.0
Python Version: 3.8.10
License: GPL
"""

import random
import math

def generate_network():
    num_nodes = random.randint(5, 15)
    node_types = ["server", "terminal", "router", "firewall", "ai", "communication",
                  "datacenter", "iot", "storage", "control", "mainframe", "security",
                  "virtualization", "vpn"]
    security_levels = ["Low", "Medium", "High"]

    nodes = []
    for i in range(num_nodes):
        node_type = random.choice(node_types)
        security = random.choice(security_levels)
        nodes.append((f"{node_type.capitalize()} {i+1}", node_type, security))

    return nodes

def generate_latex(nodes, layout="circular"):
    num_nodes = len(nodes)
    radius = 4.0
    center_x, center_y = (0, 0)

    latex_code = r"""\documentclass[a4paper, landscape]{article}
\usepackage{tikz}
\usetikzlibrary{shapes, arrows, positioning}

% Définition des styles avec logos intégrés
\newcommand{\networkstyles}{
    \tikzset{
        server/.style={
            %% rectangle, draw=black, fill=blue!20, 
            text width=4em, text centered, rounded corners, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[blue!50!white] (-0.7,0.5) rectangle (0.7,-0.5);
                        \filldraw[blue!50!white] (-0.5,0.7) rectangle (0.5,-0.7);
                        \filldraw[blue!50!white] (-0.3,0.9) rectangle (0.3,-0.9);
                    \end{tikzpicture}
                };
            }
        },
        terminal/.style={
            %% rectangle, draw=black, fill=green!20, 
            text width=4em, text centered, rounded corners, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[green!50!white] (-0.6,0.6) rectangle (0.6,-0.6);
                        \filldraw[green!50!white] (-0.4,0.4) rectangle (0.4,-0.4);
                        \filldraw[black!50!white] (-0.3,0.3) rectangle (0.3,-0.3);
                    \end{tikzpicture}
                };
            }
        },
        router/.style={
            %% diamond, draw=black, fill=red!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[red!50!white] (0,0) circle (0.6cm);
                        \filldraw[red!50!white] (-0.6,0) -- (0,0.6) -- (0.6,0) -- (0,-0.6) -- cycle;
                    \end{tikzpicture}
                };
            }
        },
        firewall/.style={
            %% ellipse, draw=black, fill=yellow!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[yellow!50!white] (0,0) ellipse (0.8cm and 0.5cm);
                        \filldraw[black!50!white] (-0.6,0) -- (-0.4,0.3) -- (0.4,0.3) -- (0.6,0) -- (0.4,-0.3) -- (-0.4,-0.3) -- cycle;
                    \end{tikzpicture}
                };
            }
        },
        ai/.style={
            %% circle, draw=black, fill=purple!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[purple!50!white] (0,0) circle (0.6cm);
                        \filldraw[purple!50!white] (-0.4,0.4) -- (0.4,0.4) -- (0.4,-0.4) -- (-0.4,-0.4) -- cycle;
                        \filldraw[white] (-0.2,0.2) circle (0.1cm);
                        \filldraw[white] (0.2,0.2) circle (0.1cm);
                    \end{tikzpicture}
                };
            }
        },
        communication/.style={
            %% trapezium, draw=black, fill=cyan!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[cyan!50!white] (0,0) circle (0.6cm);
                        \filldraw[cyan!50!white] (-0.6,0) -- (0,0.6) -- (0.6,0) -- (0,-0.6) -- cycle;
                        \filldraw[cyan!50!white] (-0.6,0) -- (0,-0.6);
                        \filldraw[cyan!50!white] (0,0.6) -- (0.6,0);
                    \end{tikzpicture}
                };
            }
        },
        datacenter/.style={
            %% regular polygon, regular polygon sides=6, draw=black, fill=orange!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[orange!50!white] (-0.6,0.6) rectangle (0.6,-0.6);
                        \filldraw[orange!50!white] (-0.5,0.5) rectangle (0.5,-0.5);
                        \filldraw[orange!50!white] (-0.4,0.4) rectangle (0.4,-0.4);
                        \filldraw[orange!50!white] (-0.3,0.3) rectangle (0.3,-0.3);
                    \end{tikzpicture}
                };
            }
        },
        iot/.style={
            %% rectangle, draw=black, fill=teal!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[teal!50!white] (0,0) circle (0.6cm);
                        \filldraw[teal!50!white] (-0.4,0.4) -- (0.4,0.4) -- (0.4,-0.4) -- (-0.4,-0.4) -- cycle;
                        \filldraw[teal!50!white] (-0.3,0.3) rectangle (0.3,-0.3);
                        \draw[teal!50!white, line width=0.1cm] (0,0.6) -- (0,1);
                    \end{tikzpicture}
                };
            }
        },
        storage/.style={
            %% cylinder, draw=black, fill=brown!20, 
			text width=4em, text centered, shape aspect=0.2, minimum height=2em, shape border rotate=90,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[brown!50!white] (-0.6,0.6) rectangle (0.6,-0.6);
                        \filldraw[brown!50!white] (-0.5,0.5) rectangle (0.5,-0.5);
                        \filldraw[brown!50!white] (-0.4,0.4) rectangle (0.4,-0.4);
                    \end{tikzpicture}
                };
            }
        },
        control/.style={
            %% star, draw=black, fill=magenta!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[magenta!50!white] (0,0) circle (0.6cm);
                        \filldraw[magenta!50!white] (-0.5,0.5) -- (0.5,0.5) -- (0.5,-0.5) -- (-0.5,-0.5) -- cycle;
                        \filldraw[magenta!50!white] (-0.4,0.4) -- (0.4,0.4) -- (0.4,-0.4) -- (-0.4,-0.4) -- cycle;
                    \end{tikzpicture}
                };
            }
        },
        mainframe/.style={
            %% rectangle, draw=black, fill=gray!20, 
			text width=4em, text centered, minimum height=3em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[gray!50!white] (-0.7,0.7) rectangle (0.7,-0.7);
                        \filldraw[gray!50!white] (-0.6,0.6) rectangle (0.6,-0.6);
                        \filldraw[gray!50!white] (-0.5,0.5) rectangle (0.5,-0.5);
                    \end{tikzpicture}
                };
            }
        },
        security/.style={
            %% ellipse, draw=black, fill=black!20, text=white, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[black!50!white] (0,0) ellipse (0.8cm and 0.5cm);
                        \filldraw[black!50!white] (-0.6,0) -- (-0.4,0.3) -- (0.4,0.3) -- (0.6,0) -- (0.4,-0.3) -- (-0.4,-0.3) -- cycle;
                    \end{tikzpicture}
                };
            }
        },
        virtualization/.style={
            %% rectangle, draw=black, fill=lime!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[lime!50!white] (-0.7,0.5) rectangle (0.7,-0.5);
                        \filldraw[lime!50!white] (-0.5,0.7) rectangle (0.5,-0.7);
                    \end{tikzpicture}
                };
            }
        },
        vpn/.style={
            %% rectangle, draw=black, fill=pink!20, 
			text width=4em, text centered, minimum height=2em,
            path picture={
                \node at (path picture bounding box.center) {
                    \begin{tikzpicture}[scale=0.75]
                        \filldraw[pink!50!white] (-0.7,0.5) rectangle (0.7,-0.5);
                        \filldraw[pink!50!white] (-0.5,0.7) rectangle (0.5,-0.7);
                    \end{tikzpicture}
                };
            }
        },
        line/.style={draw, -latex'}
    }
}

\usepackage{geometry}
\geometry{a4paper, margin=0.5in}

\begin{document}

"""

    if layout == "circular":
        latex_code += r"""
\begin{tikzpicture}[node distance=2cm, auto]
    \networkstyles % Utilisation des styles définis

    % Nodes
"""
        angles = [2 * math.pi * i / num_nodes for i in range(num_nodes)]
        for idx, (name, node_type, security) in enumerate(nodes):
            x = center_x + radius * math.cos(angles[idx])
            y = center_y + radius * math.sin(angles[idx])
            latex_code += f"\n\t\\node [{node_type}] (Node{idx}) at ({x},{y}) {{{name} ({security})}};"

        # Connections
        latex_code += "\n\n    % Connections"
        for i in range(num_nodes):
            for j in range(i+1, num_nodes):
                if random.random() < 0.3:  # Probabilité de connexion
                    latex_code += f"\n\t\\path [line] (Node{i}) -- (Node{j});"

        latex_code += r"""
\end{tikzpicture}
"""
    elif layout == "matrix":
        cols = 4
        rows = math.ceil(num_nodes / cols)
        latex_code += r"""
\begin{tikzpicture}[node distance=2cm, auto]
    \networkstyles % Utilisation des styles définis

    % Nodes in matrix layout
    \matrix [column sep=1cm, row sep=1cm] {
"""
        for i in range(rows):
            row_nodes = []
            for j in range(cols):
                idx = i * cols + j
                if idx < num_nodes:
                    name, node_type, security = nodes[idx]
                    row_nodes.append(f"\\node[{node_type}] (Node{idx}) {{{name} ({security})}};")
                else:
                    row_nodes.append("\\node{};")
            latex_code += "        " + " & ".join(row_nodes) + " \\\\\n"
        latex_code += r"""    };

    % Connections
"""
        for i in range(num_nodes):
            for j in range(i+1, num_nodes):
                if random.random() < 0.3:  # Probabilité de connexion
                    latex_code += f"\n\t\\path [line] (Node{i}) -- (Node{j});"

        latex_code += r"""
\end{tikzpicture}
"""
    else:  # combined layout
        half = num_nodes // 2
        latex_code += r"""
\begin{tikzpicture}[node distance=2cm, auto]
    \networkstyles % Utilisation des styles définis

    % Circular layout for first half of nodes
"""
        angles = [2 * math.pi * i / half for i in range(half)]
        for idx, (name, node_type, security) in enumerate(nodes[:half]):
            x = center_x + radius * math.cos(angles[idx])
            y = center_y + radius * math.sin(angles[idx])
            latex_code += f"\n\t\\node [{node_type}] (Node{idx}) at ({x},{y}) {{{name} ({security})}};"

        # Matrix layout for second half of nodes
        cols = 4
        rows = math.ceil(half / cols)
        latex_code += r"""
    % Matrix layout for second half of nodes
    \matrix [column sep=1cm, row sep=1cm] at (8,0) {
"""
        for i in range(rows):
            row_nodes = []
            for j in range(cols):
                idx = half + i * cols + j
                if idx < num_nodes:
                    name, node_type, security = nodes[idx]
                    row_nodes.append(f"\\node[{node_type}] (Node{idx}) {{{name} ({security})}};")
                else:
                    row_nodes.append("\\node{};")
            latex_code += "        " + " & ".join(row_nodes) + " \\\\\n"
        latex_code += r"""    };

    % Connections
"""
        for i in range(num_nodes):
            for j in range(i+1, num_nodes):
                if random.random() < 0.3:  # Probabilité de connexion
                    latex_code += f"\n\t\\path [line] (Node{i}) -- (Node{j});"

        latex_code += r"""
\end{tikzpicture}
"""

    # Légende
    latex_code += r"""
%% \vspace{1cm}

\vfill~\\

% Légende
\begin{center}
\begin{tikzpicture}
    \networkstyles % Utilisation des styles définis
	\begin{scope}[scale=0.35]
    \matrix [draw, column sep=1cm, row sep=0.5cm] {
        \node [server, label=right:Serveur] {}; &
        \node [terminal, label=right:Terminal] {}; &
        \node [router, label=right:Routeur] {}; \\
        \node [firewall, label=right:Pare-feu] {}; &
        \node [ai, label=right:IA] {}; &
        \node [communication, label=right:Nœud de Communication] {}; \\
        \node [datacenter, label=right:Data Center] {}; &
        \node [iot, label=right:Dispositif IoT] {}; &
        \node [storage, label=right:Nœud de Stockage] {}; \\
        \node [control, label=right:Nœud de Contrôle] {}; &
        \node [mainframe, label=right:Mainframe] {}; &
        \node [security, label=right:Nœud de Sécurité] {}; \\
        \node [virtualization, label=right:Nœud de Virtualisation] {}; &
        \node [vpn, label=right:Nœud VPN] {}; &
        \node {}; \\
    };
    \end{scope}
\end{tikzpicture}
\end{center}

\end{document}
    """

    with open("network_diagram.tex", "w") as f:
        f.write(latex_code)

if __name__ == "__main__":
    nodes = generate_network()
    # Choisissez le layout : "circular", "matrix" ou autre pour le layout combiné
    generate_latex(nodes, layout="matrix")  # ou "circular" ou autre
    print("Diagramme UML généré dans network_diagram.tex")
