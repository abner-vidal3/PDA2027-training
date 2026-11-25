#import "comun.typ": *

= DFS avanzado

== Tiempos de entrada y salida

#columnas(anchos: (1fr, 1fr))[
  Usamos un *reloj global* que avanza al entrar y al salir de cada nodo:
  - `tin[u]`: momento en que la DFS *entra* a $u$ (se pinta gris).
  - `tout[u]`: momento en que *sale* (se pinta negro).

  #v(0.3em)
  ```cpp
  void dfs(int u) {
      tin[u] = ++timer_;
      for (int v : g[u])
          if (!tin[v]) dfs(v);
      tout[u] = ++timer_;
  }
  ```
][
  #align(center, grafo(G-nodos, con-estilos(G-aristas, G-arbol.map(e => (e, arbol)).to-dict()),
    colores: G-scc, escala: 1.9cm,
    anotaciones: (a: "1/16", b: "2/15", c: "3/10", f: "4/9", g: "5/8", h: "6/7", d: "11/14", e: "12/13")))
  #align(center, suave[El grafo de la parte 2, desde `a`. Anotación `tin/tout`.])
]

== Teorema del paréntesis

#let intervalos(ivs, total: 16, u: 0.8cm, alto: 0.62cm, sep: 0.12cm) = {
  let niveles = calc.max(..ivs.map(x => x.at(3))) + 1
  box(width: total * u, height: niveles * (alto + sep) + 0.7cm, {
    for (nombre, a, b, nivel, col) in ivs {
      place(dx: (a - 1) * u, dy: nivel * (alto + sep),
        box(width: (b - a + 1) * u, height: alto, fill: col.lighten(55%), stroke: 1pt + col.darken(20%), radius: 3pt,
          align(left + horizon, pad(left: 4pt, text(size: 14pt, weight: "bold")[#nombre]))))
    }
    for t in range(1, total + 1) {
      place(dx: (t - 1) * u, dy: niveles * (alto + sep) + 0.1cm,
        box(width: u, align(center, text(size: 11pt, fill: c-suave)[#t])))
    }
  })
}

#let P(i) = paleta-grafo.at(i)
#align(center, intervalos((
  ("a", 1, 16, 0, P(0)), ("b", 2, 15, 1, P(0)), ("c", 3, 10, 2, P(0)), ("d", 11, 14, 2, P(1)),
  ("f", 4, 9, 3, P(2)), ("e", 12, 13, 3, P(1)), ("g", 5, 8, 4, P(2)), ("h", 6, 7, 5, P(3)),
)))

#teorema[
  Para dos nodos $u, v$, los intervalos $["tin", "tout"]$ son *disjuntos* o uno está *contenido* en el otro.
  Además, $[t_v] subset [t_u]$ $<==>$ $v$ es descendiente de $u$ en el árbol DFS.
]
#align(center, text(size: 17pt, font: f-codigo)[(a (b (c (f (g (h h) g) f) c) (d (e e) d) b) a)])

== Árbol DFS y camino blanco

#columnas(anchos: (1fr, 1.3fr))[
  #align(center, grafo(
    (a: (1, 4), b: (1, 3), c: (0.3, 2), d: (1.7, 2), f: (0.3, 1), e: (1.7, 1), g: (0.3, 0), h: (1.3, 0)),
    G-arbol.map(e => { let (x, y) = e.split("-"); (x, y, arbol) }),
    colores: G-scc, escala: 1.6cm, radio: 0.42cm, tam-texto: 14pt,
  ))
][
  - Las aristas por las que la DFS descubre nodos forman un *árbol* (o *bosque* si hay que lanzar varias DFS): el *árbol DFS*.
  - Es un *árbol generador* de lo alcanzable desde la raíz.

  #teorema(nombre: [camino blanco])[
    $v$ es descendiente de $u$ en el árbol DFS $<==>$ al momento de entrar a $u$ existía un camino $u arrow.squiggly v$ formado solo por nodos *blancos*.
  ]
]

== Tipos de aristas (grafos dirigidos)

#let H-nodos = (a: (1.2, 2), b: (0, 1.1), c: (0.6, 0), d: (2.4, 1.1), e: (2.4, 0))
#let H-tipos = (
  "a-b": arbol, "b-c": arbol, "a-d": arbol, "d-e": arbol,
  "c-a": retroceso, "e-d": retroceso,
  "a-c": avance + (curva: 0.35),
  "d-c": cruce,
)
#let H-aristas = ("a-b", "a-c", "a-d", "b-c", "c-a", "d-c", "d-e", "e-d")

#columnas(anchos: (1fr, 1.2fr))[
  #align(center, grafo(H-nodos, con-estilos(H-aristas, H-tipos), escala: 2.6cm,
    colores: pintar((("a", "b", "c", "d", "e"), negro)),
    anotaciones: (a: ("1/10", top), b: ("2/5", left), c: "3/4", d: ("6/9", right), e: "7/8")))
][
  Al revisar $u -> v$, según lo que encontramos en $v$:
  #v(0.2em)
  #leyenda(
    (arbol, [*Árbol*: descubre a $v$.]),
    (retroceso, [*Retroceso*: $v$ es ancestro de $u$.]),
    (avance, [*Avance*: $v$ es descendiente (no hijo directo).]),
    (cruce, [*Cruce*: $v$ en otra rama, ya terminada.]),
  )
  #v(0.5em)
  #suave[Listas de adyacencia en orden alfabético: `a: b c d`, `b: c`, `c: a`, `d: c e`, `e: d`.]
]

== Cómo clasificarlas

Al revisar la arista $u -> v$ desde $u$:

#{
  set text(size: 19pt)
  table(
    columns: (auto, auto, 1fr),
    stroke: none, inset: (x: 10pt, y: 9pt),
    fill: (_, y) => if y == 0 { c-primario } else if calc.odd(y) { c-codigo } else { none },
    table.header(..([Estado de $v$], [Tipo], [Por qué]).map(t => text(fill: white, weight: "bold", t))),
    [blanco], text(weight: "bold")[árbol], [la DFS entra a $v$ desde $u$],
    [gris], text(fill: c-cuidado, weight: "bold")[retroceso], [$v$ está en la pila de recursión: es ancestro],
    [negro, $"tin"[u] < "tin"[v]$], text(fill: c-ejemplo, weight: "bold")[avance], [$v$ se descubrió (y terminó) dentro de $u$],
    [negro, $"tin"[u] > "tin"[v]$], text(fill: c-teo, weight: "bold")[cruce], [$v$ terminó antes de que existiera $u$],
  )
}

#v(0.5em)
#teorema[$G$ tiene un ciclo $<==>$ la DFS encuentra una arista de *retroceso*.]
#suave[($==>$): sea $v$ el primer nodo del ciclo que se descubre; por camino blanco, su predecesor $u$ en el ciclo queda como descendiente, y $u -> v$ es de retroceso.]

== Clasificación paso a paso

#let H-pasos = (
  (col: pintar((("a", "b", "c"), gris)), an: (a: ("1/", top), b: ("2/", left), c: "3/"),
    ok: ("a-b", "b-c", "c-a"), nota: [`a → b → c` (árbol). `c → a`: `a` es gris $=>$ *retroceso*.]),
  (col: pintar((("a",), gris), (("b", "c"), negro)), an: (a: ("1/", top), b: ("2/5", left), c: "3/4"),
    ok: ("a-b", "b-c", "c-a", "a-c"), nota: [`c`, `b` terminan. `a → c`: `c` es negro y $"tin"[a] < "tin"[c]$ $=>$ *avance*.]),
  (col: pintar((("a", "d"), gris), (("b", "c"), negro)), an: (a: ("1/", top), b: ("2/5", left), c: "3/4", d: ("6/", right)),
    ok: ("a-b", "b-c", "c-a", "a-c", "a-d", "d-c"), nota: [`a → d` (árbol). `d → c`: negro y $"tin"[d] > "tin"[c]$ $=>$ *cruce*.]),
  (col: pintar((("a", "b", "c", "d", "e"), negro)), an: (a: ("1/10", top), b: ("2/5", left), c: "3/4", d: ("6/9", right), e: "7/8"),
    ok: H-aristas, nota: [`d → e` (árbol). `e → d`: `d` es gris $=>$ *retroceso*. Fin.]),
)
#pasos(H-pasos.len(), p => {
  let s = H-pasos.at(p - 1)
  columnas(anchos: (1fr, 1.2fr))[
    #align(center, grafo(H-nodos,
      H-aristas.map(e => { let (x, y) = e.split("-"); (x, y, if e in s.ok { H-tipos.at(e) } else { (apagada: true) + if e == "a-c" { (curva: 0.35) } else { (:) } }) }),
      escala: 2.6cm, colores: s.col, anotaciones: s.an))
  ][
    #v(1em)
    #s.nota
    #v(1fr)
    #leyenda((arbol, [árbol]), (retroceso, [retroceso]), (avance, [avance]), (cruce, [cruce]))
  ]
})

== Grafos no dirigidos

#columnas(anchos: (1.2fr, 1fr))[
  #align(center, grafo(U-nodos,
    con-estilos(U-aristas, ("a-b": arbol, "b-c": arbol, "c-d": arbol, "d-e": arbol, "e-f": arbol, "f-g": arbol,
      "c-a": retroceso + (curva: 0), "f-d": retroceso + (curva: 0))),
    dirigido: false, escala: 2.2cm, anotaciones: U-tl.pairs().map(((k, v)) => (k, v.split("/").at(0))).to-dict()))
  #align(center, suave[DFS desde `a`; anotación: `tin`])
][
  #teorema[En un grafo *no dirigido*, la DFS solo produce aristas de *árbol* y de *retroceso*.]
  #suave[Si $u$ se descubre antes que $v$, la arista se revisa mientras $u$ está gris: o descubre a $v$, o $v$ ya es su descendiente.]
  #idea[La arista al *padre* aparece en la lista de $v$, pero no es de retroceso (parte 7).]
]
