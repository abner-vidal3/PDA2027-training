#import "comun.typ": *

= 2-SAT

== El problema

#problema("Giant Pizza", juez: "CSES", url: "https://cses.fi/problemset/task/1684")[
  Hay $n$ ingredientes y $m$ amigos. Cada amigo pide *dos* deseos, como "con queso o sin piña",
  y queda feliz si se cumple *al menos uno*. ¿Se puede elegir la pizza para que todos queden felices?
]

#columnas(anchos: (1fr, 1fr))[
  - Variables booleanas $x_1, dots, x_n$ (¿lleva el ingrediente $i$?).
  - Un *literal* es $x_i$ o $not x_i$.
  - Cada deseo es una *cláusula* $(ell_1 or ell_2)$.
  - Queremos satisfacer la conjunción de todas:
  $ (x_1 or not x_2) and (not x_1 or x_3) and dots $
][
  #nota[
    *SAT* en general (cláusulas de cualquier largo) es NP-completo; con cláusulas de 3 literales también.
    Con cláusulas de *2 literales* se resuelve en #complejidad[$O(n + m)$] usando SCC.
  ]
]

== De cláusulas a implicaciones

#columnas(anchos: (1.2fr, 1fr))[
  La cláusula $(a or b)$ dice: "si uno es falso, el otro *tiene* que ser verdadero".
  $ (a or b) quad equiv quad (not a => b) and (not b => a) $

  #v(0.5em)
  #definicion(nombre: [Grafo de implicación])[
    - $2n$ nodos: uno por literal ($x_i$ y $not x_i$).
    - Por cada cláusula $(a or b)$: aristas $not a -> b$ y $not b -> a$.
  ]
][
  #align(center + horizon, grafo(
    (na: (0, 1.3), b: (2, 1.3), nb: (0, 0), a: (2, 0)),
    ("na-b", "nb-a"),
    etiquetas: (na: $not a$, b: $b$, nb: $not b$, a: $a$),
    radio: 0.55cm, escala: 2.3cm, tam-texto: 18pt,
  ))
  #align(center, suave[una cláusula $(a or b)$ $=$ dos aristas])
]

== Un ejemplo

#let L-nodos = (nx2: (0, 1.6), nx3: (0, 0), x1: (1.6, 1.6), nx1: (1.6, 0), x3: (3.2, 1.6), x2: (3.2, 0))
#let L-et = (x1: px(1), x2: px(2), x3: px(3), nx1: nx(1), nx2: nx(2), nx3: nx(3))
#let L-aristas = ("nx1-x2", "nx2-x1", "x1-x3", "nx3-nx1", "x2-x3", "nx3-nx2", "x3-x2", "nx2-nx3")
#let L-por-clausula = (
  ("nx1-x2", "nx2-x1"), ("x1-x3", "nx3-nx1"), ("x2-x3", "nx3-nx2"), ("x3-x2", "nx2-nx3"),
)
#let clausulas = (
  $(x_1 or x_2)$, $(not x_1 or x_3)$, $(not x_2 or x_3)$, $(not x_3 or x_2)$,
)

#pasos(4, p => columnas(anchos: (1fr, 1.3fr))[
  #for (i, c) in clausulas.enumerate() {
    let activa = i + 1 == p
    block(above: 0.5em, below: 0.5em, text(fill: if i < p { c-texto } else { c-suave.lighten(40%) },
      weight: if activa { "bold" } else { "regular" }, size: 22pt, c))
  }
  #v(1fr)
  #suave[Cada cláusula agrega 2 aristas (resaltadas las de la última).]
][
  #let vis = L-por-clausula.slice(0, p).flatten()
  #let nuevas = L-por-clausula.at(p - 1)
  #align(center + horizon, grafo(L-nodos,
    L-aristas.filter(e => e in vis).map(e => if e in nuevas { let (a, b) = e.split("-"); (a, b, resaltada) } else { e }),
    etiquetas: L-et, radio: 0.55cm, escala: 2.7cm, tam-texto: 17pt))
])

== Simetría del grafo

#columnas(anchos: (1.2fr, 1fr))[
  #align(center + horizon, grafo(L-nodos, L-aristas, etiquetas: L-et, radio: 0.55cm, escala: 2.7cm, tam-texto: 17pt,
    colores: (x1: c-def.lighten(70%), x2: c-def.lighten(70%), x3: c-def.lighten(70%))))
][
  #lema[
    Si existe un camino $u arrow.squiggly v$, también existe $not v arrow.squiggly not u$.
  ]
  Cada cláusula agrega una arista y su *contrapositiva*: $not a -> b$ junto con $not b -> a$.

  #v(0.5em)
  #idea[El grafo es su propio "espejo": negar todos los nodos e invertir las aristas da el mismo grafo.]
]

== ¿Cuándo es imposible?

#columnas(anchos: (1fr, 1.2fr))[
  #align(center + horizon, grafo(
    (x: (0, 1.5), y: (1.7, 1.5), nx: (1.7, 0), ny: (0, 0)),
    (("x", "y", resaltada), "y-x", ("y", "nx", resaltada), "nx-y", ("nx", "ny", resaltada), "ny-nx", ("ny", "x", resaltada), "x-ny"),
    etiquetas: (x: $x$, y: $y$, nx: $not x$, ny: $not y$),
    colores: (x: 0, y: 0, nx: 0, ny: 0),
    radio: 0.55cm, escala: 2.6cm, tam-texto: 18pt,
  ))
  #align(center, text(size: 17pt)[$(x or y)(x or not y)(not x or y)(not x or not y)$])
][
  #teorema[
    La fórmula es insatisfacible $<==>$ para algún $i$, $x_i$ y $not x_i$ están en la *misma SCC*.
  ]
  #demostracion[($<==$) Hay caminos $x arrow.squiggly not x$ y $not x arrow.squiggly x$.
    Si $x = V$, el primero obliga $not x = V$. Si $x = F$, entonces $not x = V$ y el segundo obliga $x = V$.]
  #v(0.3em)
  #suave[En el ejemplo: $x -> y -> not x -> not y -> x$.]
]

== Construir la asignación

#columnas(anchos: (1fr, 1fr))[
  Si $x_i$ y $not x_i$ están en SCC distintas, numeramos las SCC en *orden topológico* (como Kosaraju) y definimos:
  $ x_i = V quad <==> quad "comp"[x_i] > "comp"[not x_i] $
  Es decir: elegimos el literal que está *más abajo* (más cerca de los sumideros).
  #v(0.3em)
  #idea[Si existiera $x arrow.squiggly not x$, entonces $x$ viene *antes* en el orden, y elegimos $not x$: no hay contradicción.]
][
  #demostracion[
    Supongamos que una arista $a -> b$ falla: $a = V$, $b = F$. Entonces
    $"comp"[a] > "comp"[not a]$ y $"comp"[not b] > "comp"[b]$.
    Por $a -> b$ y por su contrapositiva $not b -> not a$:
    $ "comp"[a] &<= "comp"[b] < "comp"[not b] \ &<= "comp"[not a] < "comp"[a] $
    Contradicción.
  ]
]

== Asignación en el ejemplo

#let L-comp = (nx2: 0, nx3: 0, nx1: 1, x1: 2, x2: 3, x3: 3)
#pasos(2, p => columnas(anchos: (1.3fr, 1fr))[
  #align(center + horizon, grafo(L-nodos, L-aristas, etiquetas: L-et, radio: 0.55cm, escala: 2.7cm, tam-texto: 17pt,
    colores: if p == 1 { L-comp } else { (x1: c-ejemplo.lighten(45%), x2: c-ejemplo.lighten(45%), x3: c-ejemplo.lighten(45%)) },
    apagados: if p == 2 { ("nx1", "nx2", "nx3") } else { () },
    anotaciones: L-comp.pairs().map(((k, v)) => (k, ("comp " + str(v), if k.starts-with("nx") and k != "nx1" { left } else if k == "nx1" or k == "x2" { bottom } else { top }))).to-dict()))
][
  #if p == 1 [
    SCC en orden topológico:
    - comp 0 $= {not x_2, not x_3}$
    - comp 1 $= {not x_1}$
    - comp 2 $= {x_1}$
    - comp 3 $= {x_2, x_3}$
  ] else [
    #set text(size: 22pt)
    $x_1$: $2 > 1$ $=>$ *V* \
    $x_2$: $3 > 0$ $=>$ *V* \
    $x_3$: $3 > 0$ $=>$ *V*
    #v(0.5em)
    #ejemplo(titulo: [Verificación])[
      #set text(size: 18pt)
      $(V or V)(F or V)(F or V)(F or V)$ ✓
    ]
  ]
])

== Modelar restricciones

#{
  set text(size: 19pt)
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none, inset: (x: 8pt, y: 8pt),
    fill: (_, y) => if y == 0 { c-primario } else if calc.odd(y) { c-codigo } else { none },
    table.header(..([Restricción], [Cláusulas], [Aristas]).map(t => text(fill: white, weight: "bold", t))),
    [$x$ es verdadero], [$(x or x)$], [$not x -> x$],
    [$x => y$], [$(not x or y)$], [$x -> y$, $not y -> not x$],
    [$x != y$ (XOR)], [$(x or y) and (not x or not y)$], [4 aristas],
    [$x = y$], [$(x or not y) and (not x or y)$], [4 aristas],
    [no ambos $x$ e $y$], [$(not x or not y)$], [$x -> not y$, $y -> not x$],
  )
}
#v(0.5em)
#cuidado[
  "Exactamente uno de $k$ literales" con $k > 2$ necesita $O(k^2)$ cláusulas $(not a or not b)$, o un truco con
  variables auxiliares de prefijo para dejarlo en $O(k)$.
]

== Representación de literales

#columnas(anchos: (1fr, 1fr))[
  #{
    set text(size: 19pt)
    table(
      columns: (auto, auto, auto),
      stroke: 0.5pt + c-suave.lighten(50%), inset: 7pt, align: center,
      table.header([*literal*], [*nodo*], [*binario*]),
      $x_0$, `0`, `000`, $not x_0$, `1`, `001`,
      $x_1$, `2`, `010`, $not x_1$, `3`, `011`,
      $x_2$, `4`, `100`, $not x_2$, `5`, `101`,
    )
  }
][
  - $x_i arrow.r.bar 2i$, #h(0.5em) $not x_i arrow.r.bar 2i + 1$.
  - Negar un literal es cambiar el último bit: `l ^ 1`.
  - La cláusula $(a or b)$ agrega `a^1 → b` y `b^1 → a`.

  #v(0.5em)
  #idea[Con este truco no hace falta tratar los literales negados como un caso especial.]
]

== 2-SAT: código (construcción)

#columnas(anchos: (2.6fr, 1fr))[
  #codigo(read("../codigo/two_sat.cpp"), desde: "// Literales", hasta: "implica(a ^ 1, b)", mas: 1)
  #v(0.3em)
  #codigo(read("../codigo/two_sat.cpp"), desde: "int lit(", hasta: "int lit(")
][
  - `TwoSat ts(n)` crea los $2n$ nodos.
  - `lit(i, true)` es $x_i$, `lit(i, false)` es $not x_i$.
  - Uso: `ts.clausula(lit(a, true), lit(b, false))` agrega $(x_a or not x_b)$.
  - `dfs1` y `dfs2` son las mismas de Kosaraju.
]

== 2-SAT: código (resolver)

#columnas(anchos: (2.4fr, 1fr))[
  #codigo(read("../codigo/two_sat.cpp"), desde: "bool resolver()")
][
  - Kosaraju sobre $2n$ nodos.
  - `comp` queda en orden topológico.
  - Mismo literal en ambos lados $=>$ imposible.
  - Si no, $x_i = V$ cuando `comp[2i] > comp[2i+1]`.

  #complejidad[$O(n + m)$]
]

== Problemas: 2-SAT

#problema("Giant Pizza", juez: "CSES", url: "https://cses.fi/problemset/task/1684")[
  2-SAT directo.
]
#problema("The Door Problem", juez: "CF 776D", url: "https://codeforces.com/problemset/problem/776/D")[
  Cada puerta depende de dos interruptores: restricciones $x = y$ o $x != y$.
]
#problema("The Road to Berland is Paved With Good Intentions", juez: "CF 228E", url: "https://codeforces.com/problemset/problem/228/E")[
  Elegir qué ciudades "activar" para que todas las calles queden asfaltadas: XOR por arista.
]
