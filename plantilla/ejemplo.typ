#import "/plantilla/clase.typ": *

#show: clase.with(
  titulo: [Componentes fuertemente conexas],
  subtitulo: [Kosaraju, Tarjan y el grafo condensado],
  curso: [Programación Competitiva],
  autor: [Equipo de entrenamiento],
  fecha: datetime.today(),
  numero: 1,
)

= Motivación

== ¿Qué vamos a ver?

- Qué es una *componente fuertemente conexa* (SCC).
- Dos algoritmos lineales: Kosaraju y Tarjan.
- El *grafo condensado* y para qué sirve.
- Problemas típicos: 2-SAT, alcanzabilidad, DP sobre DAG.

#v(1fr)
#nota[Todo lo de hoy corre en #complejidad[$O(n + m)$].]

== Definición

#definicion(nombre: [SCC])[
  En un grafo dirigido $G = (V, E)$, una componente fuertemente conexa es un
  conjunto maximal $C subset.eq V$ tal que para todo $u, v in C$ existe un
  camino $u arrow.squiggly v$ y un camino $v arrow.squiggly u$.
]

#columnas(anchos: (1fr, 1fr))[
  #teorema[
    Las SCC particionan $V$, y el grafo condensado $G^"SCC"$ es un DAG.
  ]
][
  #align(center, grafo(
    (a: (0, 1), b: (1, 1), c: (0.5, 0), d: (2.2, 1), e: (2.2, 0)),
    (("a", "b"), ("b", "c"), ("c", "a"), ("b", "d"), ("d", "e"), ("e", "d")),
    colores: (a: 0, b: 0, c: 0, d: 1, e: 1),
  ))
]

== Construcción incremental

#pasos(3, p => [
  #columnas(anchos: (1.2fr, 1fr))[
    + Corremos DFS y guardamos el orden de salida.
    #desde(2, p)[2. Invertimos todas las aristas.]
    #desde(3, p)[3. DFS en orden de salida decreciente: cada árbol es una SCC.]
  ][
    #align(center, grafo(
      (a: (0, 1), b: (1, 1), c: (0.5, 0), d: (2, 0.5)),
      if p >= 2 {
        (("b", "a"), ("c", "b"), ("a", "c"), ("d", "b"))
      } else {
        (("a", "b"), ("b", "c"), ("c", "a"), ("b", "d"))
      },
      colores: if p >= 3 { (a: 0, b: 0, c: 0, d: 1) } else { (:) },
    ))
  ]
])

= Algoritmos

== Kosaraju

#columnas(anchos: (1.4fr, 1fr))[
  ```cpp
  vector<int> g[N], gr[N], orden;
  int comp[N]; bool vis[N];

  void dfs1(int u) {
    vis[u] = true;
    for (int v : g[u]) if (!vis[v]) dfs1(v);
    orden.push_back(u);
  }
  void dfs2(int u, int c) {
    comp[u] = c;
    for (int v : gr[u]) if (comp[v] < 0) dfs2(v, c);
  }
  ```
][
  #idea[El último en terminar el primer DFS está en una SCC *fuente* de $G^"SCC"$.]
  #cuidado[En $n = 10^5$ la recursión puede reventar el stack: usar versión iterativa o subir el límite.]
]

== Tarjan

Mantiene `low[u]`: el menor `tin` alcanzable desde el subárbol de `u` usando
a lo más una arista de retroceso.

#lema[
  $u$ es raíz de una SCC si y solo si `low[u] == tin[u]`.
]
#demostracion[Ejercicio: usar que la pila contiene exactamente los nodos de SCCs aún abiertas.]

= Práctica

== Problemas

#problema("Planets and Kingdoms", juez: "CSES", url: "https://cses.fi/problemset/task/1683")[
  Etiquetar cada planeta con su reino (SCC). Directo.
]
#problema("Coin Collector", juez: "CSES", url: "https://cses.fi/problemset/task/1686")[
  Condensar y hacer DP de camino máximo sobre el DAG.
]
#ejemplo(titulo: [Pista])[Después de condensar, piensa el DAG en orden topológico.]
