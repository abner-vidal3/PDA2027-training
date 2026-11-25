#import "comun.typ": *

= Algoritmo de Kosaraju

== La idea: empezar por un sumidero

#let dos-scc = (x: (0, 1), y: (1, 1), z: (2.3, 1), w: (3.3, 1))
#let dos-aristas = ("x-y", "y-x", "y-z", "z-w", "w-z")
#columnas(anchos: (1fr, 1fr))[
  === DFS desde `z` (SCC sumidero)
  #align(center, grafo(dos-scc, dos-aristas, colores: (z: 1, w: 1), resaltados: ("z",), apagados: ("x", "y"), escala: 2.5cm))
  Visita *exactamente* su SCC: $\{z, w\}$. #h(0.3em) ✓
][
  === DFS desde `x` (SCC fuente)
  #align(center, grafo(dos-scc, dos-aristas, colores: (x: 0, y: 0, z: 0, w: 0), resaltados: ("x",), escala: 2.5cm))
  Visita todo: mezcla dos SCC. #h(0.3em) ✗
]

#v(1fr)
#idea[
  Si procesamos las SCC desde los *sumideros* del condensado hacia atrás, y marcamos lo visitado,
  cada DFS encuentra exactamente una SCC. Problema: ¿cómo encontramos un nodo en una SCC sumidero?
]

== Lema clave: los tiempos de salida

Para una SCC $C$ definimos $"tout"(C) = max_(u in C) "tout"[u]$ (después de una DFS completa sobre $G$).

#columnas(anchos: (3fr, 1fr))[
  #lema[Si hay una arista $C -> C'$ en el condensado, entonces $"tout"(C) > "tout"(C')$.]
][
  #align(center + horizon, grafo(
    (C: (0, 0), Cp: (1.6, 0)), ("C-Cp",),
    etiquetas: (C: $C$, Cp: $C'$), colores: (C: 0, Cp: 1),
    radio: 0.6cm, tam-texto: 20pt, escala: 2cm,
  ))
]
#demostracion[
  - *La DFS entra primero a $C$*, por un nodo $x$: en ese momento todo $C$ y $C'$ es blanco y alcanzable desde $x$, así que se visita dentro de $x$; $x$ sale al final.
  - *La DFS entra primero a $C'$*: no hay camino $C' arrow.squiggly C$ (el condensado es DAG), así que $C'$ termina completo antes de tocar $C$.
]

== Consecuencia

#columnas(anchos: (1fr, 1fr))[
  #align(center, grafo(GC-nodos, GC-aristas, colores: GC-colores, escala: 2cm, radio: 0.5cm,
    anotaciones: (A: "tout 16", B: "tout 14", C: "tout 9", D: "tout 7")))
  #align(center)[$G$]
][
  #align(center, grafo(GC-nodos, invertir(GC-aristas), colores: GC-colores, escala: 2cm, radio: 0.5cm,
    resaltados: ("A",)))
  #align(center)[$G^T$ (aristas invertidas)]
]

- El nodo con *mayor* tout está en una SCC *fuente* de $G$.
- Invertir las aristas no cambia las SCC, pero las fuentes pasan a ser *sumideros*.
- En $G^T$, una DFS desde ese nodo visita exactamente su SCC. Luego seguimos con el siguiente nodo no asignado de mayor tout.

== Algoritmo

#definicion(nombre: [Kosaraju])[
  + DFS sobre $G$; guardar los nodos en orden de *salida*.
  + Construir $G^T$ (invertir todas las aristas).
  + Recorrer los nodos por tout *decreciente*. Para cada nodo $u$ sin componente: DFS en $G^T$ desde $u$, marcando con una nueva componente todo lo que visite (sin pasar por nodos ya asignados).
]

#v(0.3em)
#columnas(anchos: (1fr, 1fr))[
  #complejidad[$O(n + m)$]: dos DFS.
][
  #nota[Las componentes salen numeradas en *orden topológico* del condensado. Lo usaremos en 2-SAT.]
]

== Paso 1: DFS en $G$

#let k1 = (
  (col: pintar((("a", "b", "c", "f", "g", "h"), gris)), an: (a: "1/", b: "2/", c: "3/", f: "4/", g: "5/", h: "6/"),
    arb: ("a-b", "b-c", "c-f", "f-g", "g-h"), sal: (),
    nota: [`a → b → c`; `c → a` ya está gris; seguimos `c → f → g → h`.]),
  (col: pintar((("a", "b"), gris), (("c", "f", "g", "h"), negro)), an: (a: "1/", b: "2/", c: "3/10", f: "4/9", g: "5/8", h: "6/7"),
    arb: ("a-b", "b-c", "c-f", "f-g", "g-h"), sal: ("h", "g", "f", "c"),
    nota: [`h`, `g`, `f`, `c` terminan.]),
  (col: pintar((("a", "b", "c", "d", "e", "f", "g", "h"), negro)), an: (a: "1/16", b: "2/15", c: "3/10", f: "4/9", g: "5/8", h: "6/7", d: "11/14", e: "12/13"),
    arb: G-arbol, sal: ("h", "g", "f", "c", "e", "d", "b", "a"),
    nota: [Desde `b` visitamos `d → e`. Todo terminó.]),
)
#pasos(k1.len(), p => {
  let s = k1.at(p - 1)
  align(center, grafo(G-nodos, con-estilos(G-aristas, s.arb.map(e => (e, arbol)).to-dict()),
    colores: s.col, anotaciones: s.an, escala: 2.6cm))
  v(0.3em)
  columnas(anchos: (auto, 1fr))[
    #cola(s.sal, titulo: [salida:])
  ][
    #s.nota
  ]
})

== Paso 2: transponer

#columnas(anchos: (1fr, 1fr))[
  #align(center, grafo(G-nodos, G-aristas, escala: 1.9cm))
  #align(center)[$G$]
][
  #align(center, grafo(G-nodos, invertir(G-aristas), escala: 1.9cm))
  #align(center)[$G^T$]
]

#v(0.5em)
- Las SCC de $G^T$ son *las mismas* que las de $G$: un ciclo invertido sigue siendo un ciclo.
- Las aristas *entre* SCC cambian de sentido: el condensado de $G^T$ es el de $G$ invertido.

#v(0.3em)
#align(center)[Orden de procesamiento (tout decreciente): #h(0.5em) #cola(("a", "b", "d", "e", "c", "f", "g", "h"))]

== Paso 3: DFS en $G^T$ por tout decreciente

#let orden-k = ("a", "b", "d", "e", "c", "f", "g", "h")
#let k3 = (
  (comp: (a: 0, b: 0, c: 0), act: "a", nota: [Desde `a` en $G^T$: `a → c → b`. Componente *0* = {a, b, c}.]),
  (comp: (a: 0, b: 0, c: 0, d: 1, e: 1), act: "d", nota: [`b` ya tiene componente. Desde `d`: `d → e` (no entra a `b`, ya asignado). Componente *1* = {d, e}.]),
  (comp: (a: 0, b: 0, c: 0, d: 1, e: 1, f: 2, g: 2), act: "f", nota: [`e`, `c` ya asignados. Desde `f`: `f → g`. Componente *2* = {f, g}.]),
  (comp: G-scc, act: "h", nota: [Desde `h`: solo `h`. Componente *3* = {h}. ¡Listo!]),
)
#pasos(k3.len(), p => {
  let s = k3.at(p - 1)
  align(center, grafo(G-nodos, invertir(G-aristas), colores: s.comp, resaltados: (s.act,), escala: 2.6cm,
    anotaciones: s.comp.pairs().map(((k, v)) => (k, "comp " + str(v))).to-dict()))
  v(0.3em)
  columnas(anchos: (auto, 1fr))[
    #cola(orden-k.map(x => if x in s.comp { (x, paleta-grafo.at(s.comp.at(x))) } else { x }), titulo: [orden:])
  ][
    #s.nota
  ]
})

== Kosaraju: código

#columnas(anchos: (2.1fr, 1fr))[
  #codigo(read("../codigo/kosaraju.cpp"), desde: "void dfs1", hasta: "return k;", mas: 1)
][
  - `gt` se arma al leer: por cada `a → b`, agregar `b → a`.
  - Si $u -> v$: `comp[u] <= comp[v]`.
  #cuidado[Recursión de profundidad hasta $n$.]
]

== Construir el condensado

#columnas(anchos: (2.1fr, 1fr))[
  #codigo(read("../codigo/kosaraju.cpp"), desde: "// Grafo condensado")
  #v(0.5em)
  #codigo(read("../codigo/kosaraju.cpp"), desde: "int main()", hasta: "gt[b].push_back(a);", mas: 1)
][
  - Puede tener aristas repetidas: si molesta, usar `sort` + `unique` por lista.
  - Como `comp` ya está en orden topológico, una DP sobre el DAG se recorre con `for c = 0..k-1` (o al revés).
]
