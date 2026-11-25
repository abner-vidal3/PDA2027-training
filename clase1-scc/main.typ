#import "/plantilla/clase.typ": *

#show: clase.with(
  titulo: [Componentes fuertemente conexas],
  subtitulo: [Orden topológico, Kosaraju, 2-SAT, Tarjan, puentes y puntos de articulación],
  curso: [Programación Competitiva],
  fecha: datetime.today(),
  numero: 1,
)

== Hoja de ruta

#columnas(anchos: (1fr, 1fr))[
  + Orden topológico
  + Componentes fuertemente conexas y grafo condensado
  + Algoritmo de Kosaraju
  + 2-SAT
][
  5. DFS avanzado: tiempos, árbol DFS y tipos de aristas
  6. Algoritmo de Tarjan
  7. Puentes y puntos de articulación
]

#v(1fr)
#nota[
  Convención: $n$ = número de nodos, $m$ = número de aristas. Todo lo de hoy corre en
  #complejidad[$O(n + m)$]. El código completo está en la carpeta `codigo/`.
]

#include "partes/1-toposort.typ"
#include "partes/2-scc.typ"
#include "partes/3-kosaraju.typ"
#include "partes/4-2sat.typ"
#include "partes/5-dfs.typ"
#include "partes/6-tarjan.typ"
#include "partes/7-puentes.typ"

== Resumen

#{
  set text(size: 16pt)
  table(
    columns: (auto, 1fr, auto),
    stroke: none,
    inset: (x: 8pt, y: 6pt),
    fill: (_, y) => if y == 0 { c-primario } else if calc.odd(y) { c-codigo } else { none },
    table.header(..([Algoritmo], [Qué resuelve], [Idea clave]).map(t => text(fill: white, weight: "bold", t))),
    [Kahn], [Orden topológico / detectar ciclo], [Sacar nodos con indeg 0],
    [DFS + salida], [Orden topológico / detectar ciclo], [Invertir orden de salida; gris = ciclo],
    [Kosaraju], [SCC (en orden topológico)], [DFS en $G$, luego DFS en $G^T$ por salida decreciente],
    [2-SAT], [Satisfacer cláusulas de 2 literales], [SCC del grafo de implicación],
    [Tarjan], [SCC (orden topológico inverso)], [Una DFS + pila; raíz si `low == tin`],
    [Puentes], [Aristas cuya eliminación desconecta], [`low[v] > tin[u]`],
    [Articulación], [Nodos cuya eliminación desconecta], [`low[v] >= tin[u]`; raíz con $>= 2$ hijos],
  )
}

#v(0.4em)
#align(center, suave[Todos en #complejidad[$O(n + m)$] · Cuidado con la profundidad de recursión en $n approx 10^5$–$10^6$])
