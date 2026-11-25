#import "comun.typ": *

= Algoritmo de Tarjan

== La idea: una sola DFS

#let T-arbol-nodos = (a: (1, 4), b: (1, 3), c: (0.3, 2), d: (1.7, 2), f: (0.3, 1), e: (1.7, 1), g: (0.3, 0), h: (1.3, 0))
#columnas(anchos: (1fr, 1.5fr))[
  #align(center, grafo(T-arbol-nodos,
    G-arbol.map(e => { let (x, y) = e.split("-"); (x, y, arbol) }) + (("c", "a", retroceso + (curva: -0.5)), ("g", "f", retroceso + (curva: -0.6)), ("e", "d", retroceso + (curva: 0.6))),
    colores: G-scc, resaltados: ("a", "d", "f", "h"),
    escala: 1.6cm, radio: 0.42cm, tam-texto: 14pt,
  ))
  #align(center, suave[Árbol DFS de $G$ desde `a`])
][
  - Cada SCC ocupa un *subárbol conexo* del árbol DFS.
  - Su *raíz* es el primer nodo de la SCC que visita la DFS (bordes naranjos: `a`, `d`, `f`, `h`).
  - La SCC de una raíz $r$ es su subárbol *menos* las SCC que ya se cerraron dentro de él.

  #idea[
    Guardamos los nodos en una *pila* al entrar. Al terminar una raíz $r$, sacamos de la pila todo lo que está sobre $r$ (incluido $r$): esa es su SCC.
  ]
  Falta saber: *¿cómo reconocemos una raíz?*
]

== El valor low

#definicion(nombre: [low])[
  `low[u]` es el menor `tin` alcanzable desde el subárbol de $u$ usando aristas del árbol y, al final,
  *a lo más una* arista hacia un nodo que *sigue en la pila* (es decir, de una SCC aún abierta).
]

#columnas(anchos: (1fr, 1fr))[
  Al revisar $u -> v$:
  - $v$ no visitado (árbol): `dfs(v)`, luego \ `low[u] = min(low[u], low[v])`
  - $v$ en la pila (retroceso o cruce a SCC abierta): \ `low[u] = min(low[u], tin[v])`
  - $v$ visitado y fuera de la pila: *ignorar*.
][
  #teorema[
    $u$ es raíz de una SCC $<==>$ `low[u] == tin[u]`.
  ]
  #suave[Si `low[u] < tin[u]`, desde el subárbol de $u$ se vuelve a un nodo anterior que sigue abierto: $u$ pertenece a la SCC de ese nodo.]
]

== Tarjan paso a paso

#let T-pasos = (
  (col: pintar((("a", "b", "c"), gris)), an: (a: "1/1", b: "2/2", c: "3/1"),
    ar: ("a-b": arbol, "b-c": arbol, "c-a": retroceso), pila: ("a", "b", "c"), scc: (),
    nota: [`a → b → c`. `c → a`: `a` está en la pila $=>$ `low[c] = min(3, tin[a]) = 1`.]),
  (col: pintar((("a", "b", "c", "f", "g"), gris)) + (h: 3), an: (a: "1/1", b: "2/2", c: "3/1", f: "4/4", g: "5/4", h: "6/6"),
    ar: ("a-b": arbol, "b-c": arbol, "c-a": retroceso, "c-f": arbol, "f-g": arbol, "g-f": retroceso, "g-h": arbol),
    pila: ("a", "b", "c", "f", "g"), scc: (("h",),),
    nota: [`c → f → g`; `g → f` en pila $=>$ `low[g] = 4`. `g → h`: `h` no tiene salidas y `low[h] == tin[h]` $=>$ se saca *{h}*.]),
  (col: pintar((("a", "b", "c"), gris)) + (f: 2, g: 2, h: 3), an: (a: "1/1", b: "2/2", c: "3/1", f: "4/4", g: "5/4", h: "6/6"),
    ar: ("a-b": arbol, "b-c": arbol, "c-a": retroceso, "c-f": arbol, "f-g": arbol, "g-f": retroceso, "g-h": arbol),
    pila: ("a", "b", "c"), scc: (("h",), ("f", "g")),
    nota: [Vuelve a `f`: `low[f] = min(4, low[g]) = 4 == tin[f]` $=>$ se saca *{g, f}*.]),
  (col: pintar((("a", "b", "c", "d", "e"), gris)) + (f: 2, g: 2, h: 3), an: (a: "1/1", b: "2/1", c: "3/1", f: "4/4", g: "5/4", h: "6/6", d: "7/7", e: "8/7"),
    ar: ("a-b": arbol, "b-c": arbol, "c-a": retroceso, "c-f": arbol, "f-g": arbol, "g-f": retroceso, "g-h": arbol,
      "b-d": arbol, "d-e": arbol, "e-d": retroceso, "e-g": cruce, "e-h": cruce),
    pila: ("a", "b", "c", "d", "e"), scc: (("h",), ("f", "g")),
    nota: [`low[c] = 1`, `low[b] = 1`. `b → d → e`; `e → d` en pila $=>$ `low[e] = 7`. `e → g`, `e → h`: SCC *cerradas* $=>$ se ignoran.]),
  (col: pintar((("a", "b", "c"), gris)) + (d: 1, e: 1, f: 2, g: 2, h: 3), an: (a: "1/1", b: "2/1", c: "3/1", f: "4/4", g: "5/4", h: "6/6", d: "7/7", e: "8/7"),
    ar: ("a-b": arbol, "b-c": arbol, "c-a": retroceso, "c-f": arbol, "f-g": arbol, "g-f": retroceso, "g-h": arbol,
      "b-d": arbol, "d-e": arbol, "e-d": retroceso, "e-g": cruce, "e-h": cruce),
    pila: ("a", "b", "c"), scc: (("h",), ("f", "g"), ("d", "e")),
    nota: [Vuelve a `d`: `low[d] == tin[d] = 7` $=>$ se saca *{e, d}*.]),
  (col: G-scc, an: (a: "1/1", b: "2/1", c: "3/1", f: "4/4", g: "5/4", h: "6/6", d: "7/7", e: "8/7"),
    ar: ("a-b": arbol, "b-c": arbol, "c-a": retroceso, "c-f": arbol, "f-g": arbol, "g-f": retroceso, "g-h": arbol,
      "b-d": arbol, "d-e": arbol, "e-d": retroceso, "e-g": cruce, "e-h": cruce),
    pila: (), scc: (("h",), ("f", "g"), ("d", "e"), ("a", "b", "c")),
    nota: [Vuelve a `b` y a `a`: `low[a] == tin[a] = 1` $=>$ se saca *{c, b, a}*. ¡Listo!]),
)
#let color-scc = (h: 3, f: 2, g: 2, d: 1, e: 1, a: 0, b: 0, c: 0)
#pasos(T-pasos.len(), p => {
  let s = T-pasos.at(p - 1)
  columnas(anchos: (2.4fr, 0.6fr, 1.5fr))[
    #align(center, grafo(G-nodos,
      G-aristas.map(e => { let (x, y) = e.split("-"); (x, y, s.ar.at(e, default: (apagada: true))) }),
      colores: s.col, anotaciones: s.an, escala: 2.4cm))
    #align(center, suave[anotación: `tin/low`])
  ][
    #pila(s.pila.map(x => (x, gris)))
  ][
    #set text(size: 17pt)
    #s.nota
    #v(0.6em)
    #text(size: 14pt, fill: c-suave)[SCC encontradas:] \
    #for c in s.scc { box(cola(c.map(x => (x, paleta-grafo.at(color-scc.at(x)))), ancho: 0.8cm)) + h(0.4em) }
  ]
})

== ¿Por qué ignorar lo que está fuera de la pila?

#columnas(anchos: (1.2fr, 1fr))[
  #align(center, grafo(G-nodos,
    G-aristas.map(e => { let (x, y) = e.split("-"); (x, y, if e == "e-g" { resaltada } else if e in ("e-h",) { (apagada: true) } else { (:) }) }),
    colores: pintar((("a", "b", "c", "d", "e"), gris)) + (f: 2, g: 2, h: 3),
    anotaciones: (d: "7/7", e: "8/?", g: "5/4"), escala: 2.3cm))
][
  Cuando revisamos `e → g`, la SCC {f, g} *ya se cerró* y salió de la pila.

  Si igual usáramos `tin[g] = 5`:
  - `low[e] = 5`, luego `low[d] = 5 ≠ tin[d]`.
  - `d` no sería raíz: {d, e} quedarían en la pila y se mezclarían con {a, b, c}. ✗

  #idea[Una arista hacia una SCC cerrada nunca permite "volver": el condensado es un DAG.]
]

== Tarjan: código

#columnas(anchos: (2.1fr, 1fr))[
  #codigo(read("../codigo/tarjan_scc.cpp"), desde: "void dfs(int u)")
][
  - `enPila[v]` distingue "SCC abierta" de "SCC cerrada".
  - Al encontrar una raíz se saca la pila hasta `u`, inclusive.
  #complejidad[$O(n + m)$]
  #cuidado[Las componentes quedan en orden topológico *inverso*.]
]

== Kosaraju vs. Tarjan

#{
  set text(size: 19pt)
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none, inset: (x: 10pt, y: 9pt),
    fill: (_, y) => if y == 0 { c-primario } else if calc.odd(y) { c-codigo } else { none },
    table.header(..([], [Kosaraju], [Tarjan]).map(t => text(fill: white, weight: "bold", t))),
    [DFS], [2], [1],
    [Grafo transpuesto], [sí], [no],
    [Memoria extra], [`gt`, `orden`], [`tin`, `low`, pila],
    [Orden de `comp`], [topológico], [topológico *inverso*],
    [Idea reutilizable], [—], [`low`: puentes, articulación],
    [Facilidad], [muy fácil de recordar], [más sutil, pero más rápido],
  )
}
#v(0.5em)
#nota[En competencia, ambos sirven. Practica *Planets and Kingdoms* (CSES 1683) con los dos y verifica que den las mismas componentes.]
