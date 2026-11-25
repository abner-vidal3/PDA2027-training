// Datos compartidos por las partes de la clase: grafos de ejemplo.
#import "/plantilla/clase.typ": *

// Aplica estilos a aristas dadas como "u-v": con-estilos(aristas, ("c-a": retroceso))
#let con-estilos(aristas, estilos) = aristas.map(e => {
  let st = estilos.at(e, default: none)
  if st == none { e } else { let (a, b) = e.split("-"); (a, b, st) }
})
#let invertir(aristas) = aristas.map(e => { let (a, b) = e.split("-"); b + "-" + a })

// Diccionario {nodo: color} para nodos en listas (gris / negro de la DFS).
#let pintar(..grupos) = {
  let d = (:)
  for (nodos, color) in grupos.pos() { for n in nodos { d.insert(n, color) } }
  d
}

// ---------------------------------------------------------------- DAG D ----
// Ejemplo para orden topológico.
#let D-nodos = (a: (0, 1), b: (1, 1.8), c: (1, 0.2), d: (2, 1.8), e: (2, 0.2), f: (3, 1))
#let D-aristas = ("a-b", "a-c", "b-d", "c-d", "c-e", "d-f", "e-f")

// ------------------------------------------------------- Grafo G (SCC) ----
// Listas de adyacencia en orden alfabético.
// SCC: A = {a, b, c}, B = {d, e}, C = {f, g}, D = {h}
#let G-nodos = (
  a: (0, 1), b: (1, 1.8), c: (1, 0.2),
  d: (2.3, 1.8), e: (3.4, 1.8), f: (2.3, 0.2), g: (3.4, 0.2), h: (4.5, 1),
)
#let G-aristas = ("a-b", "b-c", "b-d", "c-a", "c-f", "d-e", "e-d", "e-g", "e-h", "f-g", "g-f", "g-h")
#let G-scc = (a: 0, b: 0, c: 0, d: 1, e: 1, f: 2, g: 2, h: 3)
#let G-arbol = ("a-b", "b-c", "c-f", "f-g", "g-h", "b-d", "d-e")  // árbol DFS desde a

// Grafo condensado de G.
#let GC-nodos = (A: (0, 1), B: (1.3, 1.8), C: (1.3, 0.2), D: (2.6, 1))
#let GC-aristas = ("A-B", "A-C", "B-C", "B-D", "C-D")
#let GC-colores = (A: 0, B: 1, C: 2, D: 3)

// ------------------------------------------- Grafo U (no dirigido) ----
// Puentes: c-d, f-g. Puntos de articulación: c, d, f.
#let U-nodos = (a: (0, 0.2), b: (0, 1.8), c: (1.1, 1), d: (2.4, 1), e: (3.3, 1.8), f: (3.3, 0.2), g: (4.6, 0.2))
#let U-aristas = ("a-b", "b-c", "c-a", "c-d", "d-e", "e-f", "f-d", "f-g")
#let U-tl = (a: "1/1", b: "2/1", c: "3/1", d: "4/4", e: "5/4", f: "6/4", g: "7/7")

// Literal de 2-SAT para etiquetas.
#let nx(i) = $not x_#i$
#let px(i) = $x_#i$
