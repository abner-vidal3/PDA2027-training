#import "comun.typ": *

= Orden topológico

== Motivación: prerrequisitos

#columnas(anchos: (1.25fr, 1fr))[
  #align(center + horizon, grafo(
    (P: (0, 1.2), M: (0, -0.2), E: (1.5, 1.2), A: (3, 0.5), G: (4.5, 1.2), C: (4.5, -0.2)),
    ("P-E", "E-A", "M-A", "A-G", "A-C", "G-C"),
    etiquetas: (P: [Prog], M: [Mat], E: [ED], A: [Alg], G: [Graf], C: [PC]),
    radio: 0.6cm, tam-texto: 14pt, escala: 2cm,
  ))
  #v(0.5em)
  #align(center, suave[Una arista $u -> v$: "hay que aprobar $u$ antes de $v$".])
][
  - Cada ramo tiene prerrequisitos.
  - ¿En qué orden tomarlos?
  - Lo mismo aparece en: compilar dependencias, ordenar tareas, evaluar fórmulas en una planilla, DP sobre grafos...

  #ejemplo(titulo: [Un orden válido])[Prog, Mat, ED, Alg, Graf, PC]
]

== Definición

#definicion(nombre: [DAG])[
  Un *grafo dirigido acíclico* (DAG) es un grafo dirigido sin ciclos dirigidos.
]
#definicion(nombre: [Orden topológico])[
  Un orden de los nodos $v_1, v_2, dots, v_n$ tal que para toda arista $v_i -> v_j$ se cumple $i < j$.
  Es decir: *todas las aristas apuntan hacia adelante*.
]
#teorema[
  $G$ tiene un orden topológico $<==>$ $G$ es un DAG.
]

== ¿Por qué solo en DAGs?

#columnas(anchos: (1fr, 1fr))[
  === ($==>$) Con un ciclo es imposible
  Si $v_1 -> v_2 -> dots -> v_k -> v_1$ es un ciclo, el orden necesitaría
  $v_1 < v_2 < dots < v_k < v_1$. #h(0.3em) Contradicción.

  #align(center, grafo(
    (a: (0, 0), b: (1, 0.9), c: (2, 0)),
    ("a-b", "b-c", ("c", "a", resaltada)),
    escala: 1.8cm,
  ))
][
  === ($<==$) Un DAG siempre tiene una fuente
  - En un DAG existe un nodo con *grado de entrada 0*: si no, retrocediendo por aristas entrantes repetiríamos un nodo y habría un ciclo.
  - Lo ponemos primero, lo sacamos del grafo (sigue siendo DAG) y repetimos.

  #idea[Esta demostración ya es un algoritmo: *Kahn*.]
]

== Puede haber muchos órdenes

#columnas(anchos: (1fr, 1.6fr))[
  #align(center + horizon, grafo(D-nodos, D-aristas, escala: 2.4cm))
][
  #let lineal(orden) = {
    let pos = (:)
    for (i, n) in orden.enumerate() { pos.insert(n, (i, 0)) }
    pad(top: 1.3cm, grafo(pos, D-aristas.map(e => { let (a, b) = e.split("-"); (a, b, (curva: -0.45)) }), escala: 1.9cm))
  }
  #lineal(("a", "b", "c", "d", "e", "f"))
  #v(-0.4em)
  #lineal(("a", "c", "e", "b", "d", "f"))
]

#v(1fr)
#nota[Dibujado en orden topológico, *todas* las aristas van de izquierda a derecha.]

== Algoritmo de Kahn

+ Calcular `indeg[v]` (grado de entrada) de cada nodo.
+ Encolar todos los nodos con `indeg = 0`.
+ Mientras la cola no esté vacía: sacar $u$, agregarlo al orden y "borrar" sus aristas: `indeg[v]--` para cada $u -> v$. Si algún `indeg[v]` llega a 0, encolar $v$.
+ Si el orden quedó con menos de $n$ nodos $==>$ hay un ciclo.

#v(0.5em)
#cuidado(titulo: [¿Por qué detecta ciclos?])[
  Los nodos de un ciclo se esperan mutuamente: ninguno llega nunca a `indeg = 0`.
]

== Kahn paso a paso

#let kahn = (
  (fuera: (), deg: (a: 0, b: 1, c: 1, d: 2, e: 1, f: 2), cola: ("a",), orden: (), act: none,
    nota: [Inicio: solo `a` tiene indeg 0.]),
  (fuera: ("a",), deg: (b: 0, c: 0, d: 2, e: 1, f: 2), cola: ("b", "c"), orden: ("a",), act: "a",
    nota: [Sale `a`: `b` y `c` llegan a 0.]),
  (fuera: ("a", "b"), deg: (c: 0, d: 1, e: 1, f: 2), cola: ("c",), orden: ("a", "b"), act: "b",
    nota: [Sale `b`: `d` baja a 1.]),
  (fuera: ("a", "b", "c"), deg: (d: 0, e: 0, f: 2), cola: ("d", "e"), orden: ("a", "b", "c"), act: "c",
    nota: [Sale `c`: `d` y `e` llegan a 0.]),
  (fuera: ("a", "b", "c", "d"), deg: (e: 0, f: 1), cola: ("e",), orden: ("a", "b", "c", "d"), act: "d",
    nota: [Sale `d`: `f` baja a 1.]),
  (fuera: ("a", "b", "c", "d", "e"), deg: (f: 0), cola: ("f",), orden: ("a", "b", "c", "d", "e"), act: "e",
    nota: [Sale `e`: `f` llega a 0.]),
  (fuera: ("a", "b", "c", "d", "e", "f"), deg: (:), cola: (), orden: ("a", "b", "c", "d", "e", "f"), act: "f",
    nota: [Sale `f`. ¡Listo! $n$ nodos en el orden.]),
)

#pasos(kahn.len(), p => {
  let s = kahn.at(p - 1)
  columnas(anchos: (1fr, 1fr))[
    #align(center, grafo(D-nodos, D-aristas, escala: 2.7cm,
      apagados: s.fuera.filter(x => x != s.act),
      resaltados: if s.act == none { () } else { (s.act,) },
      colores: if s.act == none { (:) } else { ((s.act): c-acento.lighten(50%)) },
      anotaciones: s.deg.pairs().map(((k, v)) => (k, ([indeg #v], top))).to-dict(),
    ))
  ][
    #v(0.5em)
    #cola(s.cola, titulo: [cola:])
    #v(0.6em)
    #cola(s.orden.map(x => (x, c-ejemplo.lighten(70%))), titulo: [orden:])
    #v(1em)
    #s.nota
  ]
})

== Kahn: código

#columnas(anchos: (2.1fr, 1fr))[
  #codigo(read("../codigo/toposort_kahn.cpp"), desde: "// Devuelve un orden")
][
  #complejidad[$O(n + m)$]: cada nodo entra una vez a la cola y cada arista se revisa una vez.

  #idea[
    Cambiando la `queue` por una `priority_queue` se obtiene el orden topológico
    *lexicográficamente menor* en $O((n + m) log n)$.
  ]
]

== Orden topológico con DFS

#lema[
  En un DAG, si existe la arista $u -> v$, entonces $v$ *termina* (sale de la DFS) antes que $u$:
  $"tout"[v] < "tout"[u]$.
]
#demostracion[
  Al revisar $u -> v$ desde $u$: si $v$ no estaba visitado, se visita completo dentro de $u$ y termina antes.
  Si ya estaba visitado, ya terminó: si estuviera "en curso", habría un camino $v arrow.squiggly u$ y con
  $u -> v$ un ciclo.
]

#v(0.3em)
#idea[Ordenar por tiempo de salida *decreciente* da un orden topológico: basta guardar cada nodo al salir e invertir la lista.]

== DFS paso a paso

#let dfs-topo = (
  (col: pintar((("a", "b", "d", "f"), gris)), an: (a: "1/", b: "2/", d: "3/", f: "4/"), sal: (), arb: ("a-b", "b-d", "d-f"),
    nota: [Bajamos por `a → b → d → f`.]),
  (col: pintar((("a",), gris), (("b", "d", "f"), negro)), an: (a: "1/", b: "2/7", d: "3/6", f: "4/5"), sal: ("f", "d", "b"), arb: ("a-b", "b-d", "d-f"),
    nota: [`f`, `d` y `b` terminan.]),
  (col: pintar((("a", "c"), gris), (("b", "d", "f", "e"), negro)), an: (a: "1/", b: "2/7", d: "3/6", f: "4/5", c: "8/", e: "9/10"), sal: ("f", "d", "b", "e"), arb: ("a-b", "b-d", "d-f", "a-c", "c-e"),
    nota: [Desde `c`: `d` ya terminó (negro, no hay ciclo); visitamos `e`.]),
  (col: pintar((("a", "b", "c", "d", "e", "f"), negro)), an: (a: "1/12", b: "2/7", d: "3/6", f: "4/5", c: "8/11", e: "9/10"), sal: ("f", "d", "b", "e", "c", "a"), arb: ("a-b", "b-d", "d-f", "a-c", "c-e"),
    nota: [Invirtiendo la salida: *a, c, e, b, d, f*.]),
)

#pasos(dfs-topo.len(), p => {
  let s = dfs-topo.at(p - 1)
  columnas(anchos: (1fr, 1fr))[
    #align(center, grafo(D-nodos, con-estilos(D-aristas, s.arb.map(e => (e, arbol)).to-dict()), escala: 2.7cm,
      colores: s.col, anotaciones: s.an))
    #align(center, suave[anotación: `tin/tout`])
  ][
    #v(0.5em)
    #cola(s.sal, titulo: [salida:])
    #v(1em)
    #s.nota
    #v(1fr)
    #leyenda((arbol, [arista del árbol DFS]))
    #v(0.3em)
    #box(circle(radius: 6pt, fill: gris)) en curso (gris) #h(1em)
    #box(circle(radius: 6pt, fill: negro)) terminado (negro)
  ]
})

== Detectar ciclos con colores

#columnas(anchos: (1fr, 1fr))[
  Cada nodo tiene un color:
  - *blanco*: no visitado
  - *gris*: en la pila de recursión (entró, no ha salido)
  - *negro*: terminado

  #v(0.4em)
  Si desde $u$ vemos una arista hacia un nodo *gris*, ese nodo es un ancestro de $u$ en la recursión: *hay un ciclo*.
  #v(0.4em)
  #nota[Esa arista se llama *arista de retroceso*. Las veremos con detalle en la parte 5.]
][
  #align(center, grafo(
    (a: (0, 1.6), b: (1.2, 1.6), c: (1.2, 0.2), d: (0, 0.2), e: (2.4, 0.9)),
    ("a-b", "b-c", "c-d", ("d", "b", retroceso + (curva: 0)), "b-e"),
    colores: pintar((("a", "b", "c", "d"), gris)),
    resaltados: ("d",),
    anotaciones: (a: "1/", b: "2/", c: "3/", d: "4/"),
  ))
  #align(center, suave[Desde `d` vemos a `b`, que es gris: ciclo `b → c → d → b`.])
]

== DFS: código

#columnas(anchos: (2.1fr, 1fr))[
  #codigo(read("../codigo/toposort_dfs.cpp"), desde: "vector<int> color", hasta: "return orden;", mas: 1)
][
  #complejidad[$O(n + m)$]

  #idea[Un solo recorrido: detecta ciclos y entrega el orden.]
  #cuidado[Recursión de profundidad hasta $n$.]
]

== Problemas: orden topológico

#problema("Course Schedule", juez: "CSES", url: "https://cses.fi/problemset/task/1679")[
  Directo: imprimir un orden topológico o `IMPOSSIBLE`.
]
#problema("Longest Flight Route", juez: "CSES", url: "https://cses.fi/problemset/task/1680")[
  Camino más largo en un DAG: DP en orden topológico.
]
#problema("Game Routes", juez: "CSES", url: "https://cses.fi/problemset/task/1681")[
  Contar caminos en un DAG: DP en orden topológico.
]
#problema("Round Trip II", juez: "CSES", url: "https://cses.fi/problemset/task/1678")[
  Encontrar y reconstruir un ciclo dirigido (colores + padres).
]
