#import "comun.typ": *

= Puentes y puntos de articulación

== Definiciones

#columnas(anchos: (1.2fr, 1fr))[
  #align(center, grafo(U-nodos,
    con-estilos(U-aristas, ("c-d": puente, "f-g": puente)),
    dirigido: false, resaltados: ("c", "d", "f"), escala: 2.3cm))
  #align(center, suave[puentes en rojo; puntos de articulación con borde naranjo])
][
  Grafo *no dirigido* y conexo:
  #definicion(nombre: [Puente])[Arista cuya eliminación desconecta el grafo.]
  #definicion(nombre: [Punto de articulación])[Nodo cuya eliminación (con sus aristas) desconecta el grafo.]
  #suave[Fuerza bruta: quitar cada arista/nodo y revisar conexidad: $O(m (n + m))$. Con DFS y `low`: #complejidad[$O(n + m)$].]
]

== low en grafos no dirigidos

#columnas(anchos: (1fr, 1fr))[
  Recordemos: en un grafo no dirigido solo hay aristas de *árbol* y de *retroceso*.

  #definicion(nombre: [low])[
    `low[u]` = menor `tin` alcanzable desde el subárbol de $u$ usando *a lo más una* arista de retroceso.
  ]
  Es la misma idea de Tarjan, pero sin pila: no hay "SCC cerradas" de las que preocuparse.
][
  Al revisar la arista $\{u, v\}$ desde $u$:
  - es la arista por la que llegamos a $u$: *ignorar*;
  - $v$ no visitado (árbol): `dfs(v)`, luego \ `low[u] = min(low[u], low[v])`;
  - $v$ ya visitado (retroceso): \ `low[u] = min(low[u], tin[v])`.

  #idea[`low[v]` dice qué tan *arriba* puede escapar el subárbol de $v$ sin usar la arista a su padre.]
]

== Condiciones (arista de árbol $u - v$)

#let caso-nodos = (p: (0, 3), u: (0, 2), v: (0, 1), w: (-0.6, 0), x: (0.6, 0))
#let caso-arbol = ("p-u", "u-v", "v-w", "w-x")
#let caso(atras, curva, tl, puente-uv: false, corte: false) = grafo(caso-nodos,
  caso-arbol.map(e => { let (a, b) = e.split("-"); (a, b, if e == "u-v" and puente-uv { puente } else { arbol }) })
    + ((atras.at(0), atras.at(1), retroceso + (curva: curva)),),
  dirigido: false, escala: 1.75cm, radio: 0.4cm, tam-texto: 14pt,
  resaltados: if corte { ("u",) } else { () },
  anotaciones: tl + (x: (tl.x, right)), lado-anotacion: left)

#columnas(anchos: (1fr, 1fr, 1fr))[
  #align(center, caso(("x", "v"), 0.3, (p: "1/1", u: "2/2", v: "3/3", w: "4/3", x: "5/3"), puente-uv: true, corte: true))
  #align(center)[
    `low[v] = 3 > tin[u] = 2` \
    *$u - v$ es puente* \
    #suave[(y $u$ es de articulación)]
  ]
][
  #align(center, caso(("x", "u"), 0.45, (p: "1/1", u: "2/2", v: "3/2", w: "4/2", x: "5/2"), corte: true))
  #align(center)[
    `low[v] = 2 = tin[u]` \
    *$u$ es de articulación* \
    #suave[($u - v$ no es puente)]
  ]
][
  #align(center, caso(("x", "p"), 0.5, (p: "1/1", u: "2/1", v: "3/1", w: "4/1", x: "5/1")))
  #align(center)[
    `low[v] = 1 < tin[u]` \
    *nada* \
    #suave[(el subárbol escapa por arriba de $u$)]
  ]
]

== Resumen de condiciones

#teorema(nombre: [puente])[
  La arista de árbol $u - v$ ($v$ hijo de $u$) es puente $<==>$ `low[v] > tin[u]`.
]
#teorema(nombre: [punto de articulación])[
  - $u$ *no raíz* es de articulación $<==>$ tiene un hijo $v$ con `low[v] >= tin[u]`.
  - La *raíz* es de articulación $<==>$ tiene *2 o más hijos* en el árbol DFS.
]
#v(0.3em)
#nota[Las aristas de retroceso nunca son puentes: forman un ciclo con el árbol.]

== El caso de la raíz

#let raiz-nodos = (r: (1, 1), a: (0, 0), b: (2, 0))
#columnas(anchos: (1fr, 1fr))[
  #align(center, grafo(raiz-nodos, (("r", "a", arbol), ("r", "b", arbol)), dirigido: false,
    resaltados: ("r",), escala: 2.2cm, anotaciones: (r: ("1/1", top), a: "2/2", b: "3/3")))
  #align(center)[2 hijos $=>$ *`r` es de articulación*]
][
  #align(center, grafo(raiz-nodos, (("r", "a", arbol), ("a", "b", arbol), ("b", "r", retroceso + (curva: 0))), dirigido: false,
    escala: 2.2cm, anotaciones: (r: ("1/1", top), a: "2/1", b: "3/1")))
  #align(center)[1 hijo $=>$ `r` *no* es de articulación]
]

#v(0.5em)
#cuidado(titulo: [¿Por qué es especial?])[
  Para la raíz, `low[v] >= tin[r] = 1` se cumple *siempre*: no hay nada más arriba. Lo que importa es
  si hay subárboles que *solo* se conectan a través de ella, y eso pasa exactamente cuando tiene $>= 2$ hijos.
]

== Trampa: multiaristas

#columnas(anchos: (1fr, 1.3fr))[
  #align(center, grafo((p: (0, 0), u: (1.5, 0), v: (3, 0)),
    (("p", "u", arbol), ("u", "v", arbol + (curva: 0.3)), ("u", "v", (curva: -0.3, color: c-cuidado, punteada: true))),
    dirigido: false, escala: 2.2cm, anotaciones: (p: "1/1", u: "2/2", v: "3/2")))
  #align(center, suave[dos aristas entre `u` y `v`])
][
  `u - v` *no* es puente: si se borra una, queda la otra.
  - ✗ *Saltar por vértice padre* (`if (v == padre) continue;`): desde `v` se ignoran *ambas* aristas a `u`, entonces `low[v] = 3 > tin[u]` y se reporta un puente falso.
  - ✓ *Saltar por id de arista* (`if (id == pe) continue;`): solo se ignora la arista usada; la otra es de retroceso y da `low[v] = 2`.

  #nota[Para puntos de articulación da igual, pero acostúmbrate a usar el id.]
]

== Paso a paso

#let U-arbol = ("a-b": arbol, "b-c": arbol, "c-d": arbol, "d-e": arbol, "e-f": arbol, "f-g": arbol)
#let U-pasos = (
  (col: pintar((("a", "b", "c"), gris)), an: (a: "1/1", b: "2/2", c: "3/1"),
    ar: ("a-b": arbol, "b-c": arbol, "c-a": retroceso + (curva: 0)), cortes: (),
    nota: [`a → b → c`. `c - a` es retroceso: `low[c] = tin[a] = 1`.]),
  (col: pintar((("a", "b", "c", "d", "e", "f"), gris), (("g",), negro)), an: (a: "1/1", b: "2/2", c: "3/1", d: "4/4", e: "5/5", f: "6/4", g: "7/7"),
    ar: U-arbol + ("c-a": retroceso + (curva: 0), "f-d": retroceso + (curva: 0), "f-g": puente), cortes: ("f",),
    nota: [`c → d → e → f`; `f - d` retroceso: `low[f] = 4`. `g` termina con `low[g] = 7 > tin[f] = 6` $=>$ *`f - g` puente*, *`f` de corte*.]),
  (col: pintar((("a", "b", "c"), gris), (("d", "e", "f", "g"), negro)), an: (a: "1/1", b: "2/2", c: "3/1", d: "4/4", e: "5/4", f: "6/4", g: "7/7"),
    ar: U-arbol + ("c-a": retroceso + (curva: 0), "f-d": retroceso + (curva: 0), "f-g": puente, "c-d": puente), cortes: ("f", "d", "c"),
    nota: [`low[e] = 4 >= tin[d]` $=>$ *`d` de corte*. `low[d] = 4 > tin[c] = 3` $=>$ *`c - d` puente*, *`c` de corte*.]),
  (col: pintar((("a", "b", "c", "d", "e", "f", "g"), negro)), an: U-tl,
    ar: U-arbol + ("c-a": retroceso + (curva: 0), "f-d": retroceso + (curva: 0), "f-g": puente, "c-d": puente), cortes: ("f", "d", "c"),
    nota: [`low[b] = 1`. La raíz `a` tiene un solo hijo $=>$ no es de corte. Puentes: `c - d`, `f - g`. Articulación: `c`, `d`, `f`.]),
)
#pasos(U-pasos.len(), p => {
  let s = U-pasos.at(p - 1)
  align(center, grafo(U-nodos,
    U-aristas.map(e => { let (x, y) = e.split("-"); (x, y, s.ar.at(e, default: (apagada: true))) }),
    dirigido: false, colores: s.col, anotaciones: s.an, resaltados: s.cortes, escala: 2.6cm))
  v(0.3em)
  columnas(anchos: (1fr, auto))[
    #s.nota
  ][
    #suave[anotación: `tin/low`]
  ]
})

== Código

#columnas(anchos: (2.1fr, 1fr))[
  #codigo(read("../codigo/puentes_articulacion.cpp"), desde: "// pe = id")
][
  - `g[u]`: pares `(vecino, id)`; cada arista aparece dos veces con el mismo id.
  - Puentes y articulación en la *misma* DFS.
  #complejidad[$O(n + m)$]
]

== Más allá

#columnas(anchos: (1fr, 1fr))[
  === Componentes 2-arista-conexas
  Quitar los puentes y tomar componentes conexas. Al comprimirlas, los puentes forman un *árbol* (el "árbol de puentes").
  #align(center, grafo(
    (X: (0, 0), Y: (1.5, 0), Z: (3, 0)),
    (("X", "Y", puente), ("Y", "Z", puente)), dirigido: false,
    etiquetas: (X: [abc], Y: [def], Z: [g]), colores: (X: 0, Y: 1, Z: 2), escala: 1.8cm, radio: 0.5cm, tam-texto: 14pt))
][
  === Componentes biconexas
  Conjuntos maximales de *aristas* sin puntos de articulación internos. Se obtienen con la misma DFS y una pila de aristas.
  Con ellas se arma el *block-cut tree*, útil para preguntas como "¿todo camino de $a$ a $b$ pasa por $c$?".
]

#v(1fr)
#idea[Patrón general, igual que con SCC: *comprimir* las partes "robustas" y resolver sobre un *árbol* o un *DAG*.]

== Problemas: puentes y articulación

#problema("Necessary Roads", juez: "CSES", url: "https://cses.fi/problemset/task/2076")[
  Listar todos los puentes.
]
#problema("Necessary Cities", juez: "CSES", url: "https://cses.fi/problemset/task/2077")[
  Listar todos los puntos de articulación.
]
#problema("Bertown roads", juez: "CF 118E", url: "https://codeforces.com/problemset/problem/118/E")[
  Orientar las calles para que el grafo quede fuertemente conexo: posible $<==>$ no hay puentes.
  Se orientan las aristas de árbol hacia abajo y las de retroceso hacia arriba.
]
