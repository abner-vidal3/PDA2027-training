#import "comun.typ": *

= Componentes fuertemente conexas

== ¿Y si el grafo tiene ciclos?

#columnas(anchos: (1.2fr, 1fr))[
  #align(center + horizon, grafo(G-nodos, G-aristas, escala: 2.3cm))
][
  - No hay orden topológico: Kahn se detiene y la DFS encuentra aristas de retroceso.
  - Pero los ciclos tienen estructura: hay grupos de nodos que se alcanzan *todos entre todos*.
  - Si "comprimimos" cada grupo en un solo nodo... ¿qué queda?

  #v(0.5em)
  #idea[Vamos a encontrar esos grupos y comprimirlos.]
]

== Definición

#definicion(nombre: [Alcanzabilidad mutua])[
  $u tilde.op v$ si existe un camino $u arrow.squiggly v$ *y* un camino $v arrow.squiggly u$.
]

#columnas(anchos: (1.3fr, 1fr))[
  $tilde.op$ es una *relación de equivalencia*:
  - reflexiva: $u tilde.op u$ (camino vacío)
  - simétrica: por definición
  - transitiva: se concatenan caminos

  Por lo tanto *particiona* los nodos en clases.
][
  #definicion(nombre: [SCC])[
    Una *componente fuertemente conexa* es una clase de equivalencia de $tilde.op$: un conjunto maximal de nodos que se alcanzan mutuamente.
  ]
]

== Las SCC de nuestro grafo

#let pasos-scc = (
  (:),
  (a: 0, b: 0, c: 0),
  (a: 0, b: 0, c: 0, d: 1, e: 1),
  (a: 0, b: 0, c: 0, d: 1, e: 1, f: 2, g: 2),
  G-scc,
)
#let notas-scc = (
  [¿Cuáles son los grupos?],
  [`a → b → c → a`: un ciclo. Desde `a` se llega a todo, pero solo `b` y `c` vuelven a `a`.],
  [`d ⇄ e` forman otra SCC.],
  [`f ⇄ g` también.],
  [`h` no vuelve a nadie: es una SCC de un solo nodo.],
)
#pasos(pasos-scc.len(), p => columnas(anchos: (1.3fr, 1fr))[
  #align(center, grafo(G-nodos, G-aristas, colores: pasos-scc.at(p - 1), escala: 2.3cm))
][
  #v(1em)
  #notas-scc.at(p - 1)
  #v(1fr)
  #if p == pasos-scc.len() [
    #box(circle(radius: 6pt, fill: paleta-grafo.at(0))) A = {a, b, c} \
    #box(circle(radius: 6pt, fill: paleta-grafo.at(1))) B = {d, e} \
    #box(circle(radius: 6pt, fill: paleta-grafo.at(2))) C = {f, g} \
    #box(circle(radius: 6pt, fill: paleta-grafo.at(3))) D = {h}
  ]
])

== El grafo condensado

#columnas(anchos: (1.35fr, 1fr))[
  #align(center, grafo(G-nodos, G-aristas, colores: G-scc, escala: 2.1cm))
  #align(center, text(size: 30pt, fill: c-acento)[$arrow.b$])
  #align(center, grafo(GC-nodos, GC-aristas, colores: GC-colores, escala: 2.1cm, radio: 0.5cm))
][
  #definicion(nombre: [Grafo condensado $G^"SCC"$])[
    - Un nodo por cada SCC.
    - Una arista $C -> C'$ si existe $u -> v$ en $G$ con $u in C$, $v in C'$, $C != C'$.
  ]
  #v(0.5em)
  Las aristas dentro de una SCC desaparecen; las que cruzan entre SCC se mantienen (posiblemente repetidas).
]

== El condensado es un DAG

#teorema[$G^"SCC"$ no tiene ciclos.]
#demostracion[
  Supongamos un ciclo $C_1 -> C_2 -> dots -> C_k -> C_1$ en $G^"SCC"$. Dentro de cada SCC podemos movernos
  libremente, así que cualquier nodo de $C_1$ alcanza a cualquiera de $C_2$ y viceversa (dando la vuelta al ciclo).
  Entonces $C_1$ y $C_2$ serían la *misma* SCC. Contradicción con la maximalidad.
]

#v(0.5em)
#idea[
  *Todo* grafo dirigido es "un DAG de SCCs". Muchos problemas en grafos generales se resuelven así:
  + comprimir las SCC,
  + resolver en el DAG con orden topológico / DP.
]

== Uso 1: DP sobre el condensado

#let monedas = (a: 3, b: 1, c: 2, d: 4, e: 1, f: 2, g: 5, h: 3)
#pasos(2, p => columnas(anchos: (1.25fr, 1fr))[
  #align(center, grafo(G-nodos, G-aristas, colores: G-scc, escala: 1.7cm,
    anotaciones: monedas.pairs().map(((k, v)) => (k, [#v \$])).to-dict()))
  #v(-0.4em)
  #align(center, text(size: 22pt, fill: c-acento)[$arrow.b$])
  #v(-0.4em)
  #align(center, grafo(GC-nodos, GC-aristas, colores: GC-colores, escala: 1.7cm, radio: 0.5cm,
    resaltados: if p == 2 { ("A", "B", "C", "D") } else { () },
    anotaciones: if p == 1 { (A: [6 \$], B: [5 \$], C: [7 \$], D: [3 \$]) }
      else { (A: [dp = 6], B: [dp = 11], C: [dp = 18], D: [dp = 21]) },
  ))
][
  #problema("Coin Collector", juez: "CSES", url: "https://cses.fi/problemset/task/1686")[
    Cada nodo tiene monedas (se recogen una vez). ¿Máximo de monedas en un camino?
  ]
  - Dentro de una SCC se recogen *todas*: sumar.
  - En el DAG: camino de peso máximo, DP en orden topológico.
  #desde(2, p)[
    $ "dp"[C] = "suma"(C) + max_(C' -> C) "dp"[C'] $
    Respuesta: $21$ por $A -> B -> C -> D$.
  ]
])

== Uso 2: hacer el grafo fuertemente conexo

#columnas(anchos: (1fr, 1fr))[
  #align(center, grafo(
    (S1: (0, 1.8), S2: (0, 0.2), M: (1.5, 1), T1: (3, 1.9), T2: (3, 1), T3: (3, 0.1)),
    ("S1-M", "S2-M", "M-T1", "M-T2", "S2-T3",
      ("T1", "S1", (color: c-acento, punteada: true, curva: 0.35)),
      ("T2", "S2", (color: c-acento, punteada: true, curva: -0.15)),
      ("T3", "S1", (color: c-acento, punteada: true, curva: -0.5))),
    colores: (S1: c-ejemplo.lighten(40%), S2: c-ejemplo.lighten(40%), T1: c-cuidado.lighten(40%), T2: c-cuidado.lighten(40%), T3: c-cuidado.lighten(40%)),
    escala: 2.3cm, radio: 0.5cm, tam-texto: 14pt,
  ))
  #align(center, suave[condensado: fuentes en verde, sumideros en rojo])
][
  ¿Mínimo de aristas a *agregar* para que todo sea una sola SCC?

  #teorema[
    Si el condensado tiene $k > 1$ nodos, $s$ fuentes (indeg 0) y $t$ sumideros (outdeg 0), la respuesta es $max(s, t)$.
  ]
  - Cada fuente necesita una arista entrante y cada sumidero una saliente.
  - Basta unir sumideros con fuentes (en buen orden).
  - Si $k = 1$: 0 aristas.
]

== Problemas: SCC y condensado

#problema("Flight Routes Check", juez: "CSES", url: "https://cses.fi/problemset/task/1682")[
  ¿Es fuertemente conexo? Si no, mostrar un par $(u, v)$ sin camino. (También sale con 2 BFS: en $G$ y en $G^T$.)
]
#problema("Planets and Kingdoms", juez: "CSES", url: "https://cses.fi/problemset/task/1683")[
  Etiquetar cada nodo con su SCC. Directo.
]
#problema("Coin Collector", juez: "CSES", url: "https://cses.fi/problemset/task/1686")[
  Condensar + DP de camino máximo en el DAG.
]
#nota[¿Cómo encontramos las SCC? Siguiente parte: *Kosaraju*.]
