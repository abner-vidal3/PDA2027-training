// =============================================================================
// Plantilla de diapositivas para clases de programación competitiva.
// Sin dependencias externas.
//
// Uso (desde un archivo dentro de una carpeta de clase):
//
//   #import "/plantilla/clase.typ": *
//   #show: clase.with(
//     titulo: [Componentes fuertemente conexas],
//     curso: [Programación Competitiva],
//     autor: [Nombre],
//     fecha: datetime.today(),
//     numero: 1,
//   )
//
//   = Sección          -> diapositiva separadora de sección
//   == Título          -> nueva diapositiva con ese título
//
// Compilar (desde la carpeta raíz `clase/`):
//   typst compile --root . clase1-scc/main.typ
//   typst compile --root . --input handout=true clase1-scc/main.typ  (sin pasos)
// =============================================================================

// ---------------------------------------------------------------- Paleta -----
#let c-primario = rgb("#1f3a68")
#let c-acento = rgb("#e07a1f")
#let c-texto = rgb("#1d1f24")
#let c-suave = rgb("#6b7280")
#let c-fondo = rgb("#ffffff")
#let c-codigo = rgb("#f5f6f8")

#let c-def = rgb("#1f6feb")
#let c-teo = rgb("#8250df")
#let c-ejemplo = rgb("#1a7f37")
#let c-cuidado = rgb("#cf222e")
#let c-idea = rgb("#bf8700")
#let c-problema = c-acento

// Colores para pintar nodos de grafos (p. ej. una SCC por color).
#let paleta-grafo = (
  rgb("#4c8bf5"), rgb("#f2994a"), rgb("#27ae60"), rgb("#eb5757"),
  rgb("#9b51e0"), rgb("#56ccf2"), rgb("#f2c94c"), rgb("#bdbdbd"),
)

// ---------------------------------------------------------------- Fuentes ----
#let f-texto = ("Lato", "DejaVu Sans")
#let f-codigo = ("DejaVu Sans Mono", "Noto Sans Mono")
#let f-mate = "New Computer Modern Math"

// ---------------------------------------------------------------- Estado -----
#let _diapo = counter("diapo")
#let _seccion = counter("seccion")
#let _linea0 = state("linea0", 0)
#let _marcadores = (text(fill: c-acento)[●], text(fill: c-acento)[–])
#let _numeracion = n => text(fill: c-acento, weight: "bold")[#n.]
#let _handout = sys.inputs.at("handout", default: "false") == "true"

// Título de la diapositiva actual: el último encabezado de nivel 1 o 2 que
// aparece en esta página o antes. Si es de nivel 1 (sección) no hay título.
#let _titulo-actual() = {
  let aqui = here()
  let en-pagina = query(heading.where(level: 2).or(heading.where(level: 1)))
    .filter(h => h.location().page() == aqui.page())
  let previos = query(selector(heading.where(level: 2).or(heading.where(level: 1))).before(aqui))
  let h = if en-pagina.len() > 0 { en-pagina.first() } else if previos.len() > 0 { previos.last() } else { none }
  h
}

#let _es-portada-o-seccion() = {
  let p = here().page()
  if p == 1 { return true }
  query(heading.where(level: 1)).any(h => h.location().page() == p)
}

// Convierte contenido simple a string (para metadatos del PDF).
#let _plano(c) = {
  if type(c) == str { c }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(_plano).join() }
  else if c.has("body") { _plano(c.body) }
  else if c == [ ] { " " }
  else { "" }
}

// ============================================================ Plantilla =====
#let clase(
  titulo: [Título de la clase],
  subtitulo: none,
  curso: [Programación Competitiva],
  autor: none,
  fecha: none,
  numero: none,
  body,
) = {
  set document(title: titulo, author: if autor == none { () } else { _plano(autor) })
  set text(font: f-texto, size: 20pt, fill: c-texto, lang: "es")
  set par(justify: false, leading: 0.6em, spacing: 0.75em)
  show math.equation: set text(font: f-mate)
  set list(marker: _marcadores, indent: 0.3em, body-indent: 0.5em, spacing: 0.75em)
  set enum(numbering: _numeracion, indent: 0.3em, spacing: 0.75em)
  set terms(separator: [: ])
  show strong: set text(fill: c-primario)
  show link: it => underline(stroke: 0.6pt + c-acento.lighten(30%), offset: 2pt, it)

  // ------------------------------------------------------------ Código ----
  show raw: set text(font: f-codigo)
  show raw.where(block: false): it => box(
    fill: c-codigo, inset: (x: 3pt), outset: (y: 3pt), radius: 2pt,
    text(size: 0.9em, it),
  )
  show raw.where(block: true): set text(size: 11pt)
  show raw.where(block: true): it => {
    set par(justify: false)
    block(
      width: 100%, fill: c-codigo, radius: 4pt, inset: (x: 10pt, y: 9pt),
      stroke: 0.5pt + c-codigo.darken(8%),
      if it.lines.len() > 1 {
        grid(
          columns: (auto, 1fr), column-gutter: 0.9em, row-gutter: 0.42em,
          ..it.lines.map(l => (text(fill: c-suave.lighten(30%), context str(_linea0.get() + l.number)), l)).flatten(),
        )
      } else { it },
    )
  }

  // ------------------------------------------------------------ Página ----
  set page(
    paper: "presentation-16-9",
    fill: c-fondo,
    margin: (x: 1.6cm, top: 2.5cm, bottom: 1.3cm),
    header-ascent: 0.6cm,
    footer-descent: 0.4cm,
    header: context {
      if _es-portada-o-seccion() { return }
      let h = _titulo-actual()
      if h != none and h.level == 2 {
        set text(size: 28pt, weight: "bold", fill: c-primario)
        h.body
        v(-0.35em)
        line(length: 2.5cm, stroke: 2.5pt + c-acento)
      }
    },
    footer: context {
      if _es-portada-o-seccion() { return }
      let n = _diapo.get().first()
      let total = calc.max(_diapo.final().first(), 1)
      set text(size: 11pt, fill: c-suave)
      grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),
        [#curso #h(0.4em) · #h(0.4em) #titulo],
        [#n / #total],
      )
      v(-0.4em)
      box(width: 100%, height: 2pt, fill: c-suave.lighten(80%),
        place(box(width: 100% * n / total, height: 2pt, fill: c-acento)))
    },
  )

  // ------------------------------------------------------- Encabezados ----
  // `= Sección`: diapositiva separadora.
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1fr)
    block(width: 100%, {
      set text(fill: c-primario)
      _seccion.step()
      text(size: 18pt, fill: c-acento, weight: "bold", tracking: 0.08em)[PARTE #context _seccion.get().first()]
      v(-0.2em)
      text(size: 40pt, weight: "bold", it.body)
      v(-0.4em)
      line(length: 4cm, stroke: 3pt + c-acento)
    })
    v(1.2fr)
    pagebreak(weak: true)
  }
  // `== Título`: nueva diapositiva (el título se dibuja en el header).
  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    _diapo.step()
  }
  // `=== Subtítulo` dentro de una diapositiva.
  show heading.where(level: 3): it => block(above: 0.9em, below: 0.6em,
    text(size: 22pt, weight: "bold", fill: c-primario, it.body))

  // ------------------------------------------------------------ Portada ---
  page(header: none, footer: none, margin: 0pt, {
    place(top + left, box(width: 100%, height: 100%, fill: c-primario))
    place(left + bottom, dx: 0pt, dy: 0pt, box(width: 100%, height: 0.35cm, fill: c-acento))
    pad(x: 2cm, y: 1.8cm, {
      set text(fill: white)
      v(1fr)
      if numero != none {
        text(size: 18pt, fill: c-acento.lighten(20%), weight: "bold", tracking: 0.08em)[CLASE #numero]
        v(-0.1em)
      }
      text(size: 44pt, weight: "bold", titulo)
      if subtitulo != none {
        v(-0.3em)
        text(size: 24pt, fill: white.darken(15%), subtitulo)
      }
      v(1fr)
      set text(size: 16pt, fill: white.darken(10%))
      let partes = (curso, autor, if type(fecha) == datetime { fecha.display("[day]/[month]/[year]") } else { fecha })
        .filter(x => x != none)
      partes.join([#h(0.6em)·#h(0.6em)])
    })
  })

  body
}

// =============================================================== Pasos ======
// Muestra contenido de forma incremental, una página por paso, conservando
// el espacio de lo que aún no aparece.
//
//   #pasos(3, p => [
//     - Siempre visible
//     #desde(2, p)[- Aparece en el paso 2]
//     #desde(3, p)[- Aparece en el paso 3]
//   ])
//
// Con `--input handout=true` solo se imprime el último paso.
#let pasos(n, cuerpo) = {
  if _handout { cuerpo(n) } else {
    for i in range(1, n + 1) {
      cuerpo(i)
      if i < n { pagebreak() }
    }
  }
}
//
// Ojo con listas numeradas: un ítem dentro de `desde` forma su propia lista,
// así que escribe el número explícito: `#desde(2, p)[2. Texto]`.
#let _mostrar(visible, cuerpo) = {
  // Las reglas `set` se aplican siempre (visible o no) para que la
  // diagramación sea idéntica en todos los pasos.
  set list(marker: if visible { _marcadores } else { _marcadores.map(hide) })
  set enum(numbering: if visible { _numeracion } else { n => hide(_numeracion(n)) })
  if visible { cuerpo } else { hide(cuerpo) }
}
#let desde(i, p, cuerpo) = _mostrar(p >= i, cuerpo)
#let solo(i, p, cuerpo) = _mostrar(p == i, cuerpo)
#let hasta(i, p, cuerpo) = _mostrar(p <= i, cuerpo)
// Valor según el paso (útil para colores):
//   en-paso(p, (1, white), (3, red))  -> white en pasos 1-2, red desde el 3.
#let en-paso(p, default: none, ..pares) = {
  let v = default
  for (k, x) in pares.pos().sorted(key: q => q.at(0)) { if p >= k { v = x } }
  v
}

// =============================================================== Cajas ======
#let caja(titulo, cuerpo, color: c-primario) = block(
  width: 100%, breakable: false,
  fill: color.lighten(92%), radius: (right: 4pt),
  stroke: (left: 3pt + color),
  inset: (x: 12pt, y: 10pt),
  above: 0.9em, below: 0.9em,
  {
    if titulo != none {
      text(weight: "bold", fill: color.darken(15%), titulo)
      parbreak()
    }
    cuerpo
  },
)

#let _titulado(etiqueta, nombre) = if nombre == none { etiqueta } else { [#etiqueta (#nombre)] }

#let definicion(nombre: none, cuerpo) = caja(_titulado([Definición], nombre), cuerpo, color: c-def)
#let teorema(nombre: none, cuerpo) = caja(_titulado([Teorema], nombre), cuerpo, color: c-teo)
#let lema(nombre: none, cuerpo) = caja(_titulado([Lema], nombre), cuerpo, color: c-teo)
#let demostracion(cuerpo) = block(width: 100%, inset: (left: 12pt), above: 0.6em, {
  text(style: "italic", fill: c-suave)[Demostración. ]
  cuerpo
  h(1fr)
  text(fill: c-suave)[$square$]
})
#let ejemplo(titulo: [Ejemplo], cuerpo) = caja(titulo, cuerpo, color: c-ejemplo)
#let idea(titulo: [Idea], cuerpo) = caja(titulo, cuerpo, color: c-idea)
#let cuidado(titulo: [Cuidado], cuerpo) = caja(titulo, cuerpo, color: c-cuidado)
#let nota(cuerpo) = caja(none, cuerpo, color: c-suave)

// Problema de algún juez:
//   #problema("Planets and Kingdoms", juez: "CSES", url: "https://cses.fi/problemset/task/1683")[...]
#let problema(nombre, juez: none, url: none, cuerpo) = {
  let cab = {
    if juez != none { box(fill: c-problema, radius: 2pt, inset: (x: 4pt, y: 1pt), outset: (y: 2pt),
      text(size: 0.75em, fill: white, weight: "bold", juez)) + h(0.4em) }
    if url != none { link(url, nombre) } else { nombre }
  }
  caja(cab, cuerpo, color: c-problema)
}

// ============================================================ Utilidades ====
// Chip de complejidad: #complejidad[$O(n + m)$]
#let complejidad(cuerpo) = box(
  fill: c-primario.lighten(88%), stroke: 0.6pt + c-primario.lighten(40%),
  radius: 10pt, inset: (x: 7pt, y: 2pt), outset: (y: 2pt),
  text(size: 0.85em, fill: c-primario, cuerpo),
)

#let resaltar(cuerpo) = highlight(fill: c-acento.lighten(70%), extent: 1pt, cuerpo)
#let suave(cuerpo) = text(fill: c-suave, cuerpo)
#let acento(cuerpo) = text(fill: c-acento, weight: "bold", cuerpo)

// Columnas: #columnas[izq][der]  o  #columnas(anchos: (2fr, 1fr))[...][...]
#let columnas(anchos: auto, espacio: 1.2em, ..cols) = {
  let cs = cols.pos()
  grid(columns: if anchos == auto { (1fr,) * cs.len() } else { anchos }, column-gutter: espacio, ..cs)
}

// Centrar vertical y horizontalmente lo que queda de diapositiva.
#let centrado(cuerpo) = { v(1fr); align(center, cuerpo); v(1fr) }

// ================================================================ Código ====
// Muestra un fragmento de un archivo, conservando su numeración.
//   #codigo(read("codigo/kosaraju.cpp"), lineas: (5, 20))
//   #codigo(read("codigo/kosaraju.cpp"), desde: "int kosaraju()")
// Con `desde` (texto de la primera línea) el fragmento termina en la primera
// línea `}` con la misma indentación, o en la línea que contiene `hasta`
// (más `mas` líneas extra). Así el fragmento sobrevive a cambios del archivo.
#let codigo(src, lineas: none, desde: none, hasta: none, mas: 0, lang: "cpp", tam: none) = {
  let ls = src.trim(at: end).split("\n")
  let (a, b) = if lineas != none { lineas } else {
    let i = ls.position(l => l.contains(desde))
    assert(i != none, message: "codigo: no se encontró «" + desde + "»")
    let ind = ls.at(i).len() - ls.at(i).trim(at: start).len()
    let pref = " " * ind + "}"
    let rel = if hasta == none {
      ls.slice(i + 1).position(l => l.starts-with(pref))
    } else {
      let k = ls.slice(i).position(l => l.contains(hasta))
      if k == none { none } else { k - 1 }
    }
    assert(rel != none, message: "codigo: no se encontró el fin del fragmento «" + desde + "»")
    (i + 1, i + 2 + rel + mas)
  }
  let trozo = ls.slice(a - 1, calc.min(b, ls.len())).join("\n")
  _linea0.update(a - 1)
  if tam == none { raw(trozo, lang: lang, block: true) } else {
    show raw.where(block: true): set text(size: tam)
    raw(trozo, lang: lang, block: true)
  }
  _linea0.update(0)
}

// ================================================================ Grafos ====
// Estilos de arista (tercer elemento de una arista; se pueden sumar:
// `retroceso + (curva: -0.4)`).
#let arbol = (grosor: 2.6pt, color: c-texto)
#let retroceso = (color: c-cuidado, punteada: true, curva: 0.35)
#let avance = (color: c-ejemplo, curva: -0.35, grosor: 1.6pt)
#let cruce = (color: c-teo, punteada: true)
#let puente = (color: c-cuidado, grosor: 3pt)
#let resaltada = (color: c-acento, grosor: 2.6pt)

#let _c-apagado = luma(205)
#let _oscuro(c) = {
  let (r, g, b, ..) = rgb(c).components()
  0.299 * r / 100% + 0.587 * g / 100% + 0.114 * b / 100% < 0.5
}
// Colores para trazas de DFS.
#let gris = rgb("#c9ced6")
#let negro = rgb("#4b5563")

#let _trazo(op, grosor) = {
  let st = (paint: op.at("color", default: c-texto.lighten(20%)),
    thickness: op.at("grosor", default: grosor), cap: "round")
  if op.at("punteada", default: false) { st.insert("dash", (3pt, 3pt)) }
  stroke(st)
}

// Dibuja un grafo sin paquetes externos.
//
//   #grafo(
//     (a: (0, 0), b: (1, 1), c: (2, 0)),            // nodo: (x, y), y hacia arriba
//     ("a-b", "b-c", ("c", "a", retroceso)),        // "u-v" o (u, v) o (u, v, opciones)
//     colores: (a: 0, b: 0, c: 1),                  // índice en paleta-grafo o color
//     anotaciones: (a: [1/6], b: ([2/5], top)),     // texto chico junto al nodo
//     resaltados: ("b",), apagados: ("c",),
//   )
//
// Opciones de arista: color, grosor, punteada, curva, etiqueta, apagada.
// Si existen a→b y b→a, ambas aristas se curvan automáticamente.
#let grafo(
  nodos,
  aristas,
  dirigido: true,
  escala: 2.2cm,
  radio: 0.45cm,
  colores: (:),
  etiquetas: (:),
  anotaciones: (:),
  lado-anotacion: bottom,
  resaltados: (),
  apagados: (),
  grosor: 1.3pt,
  tam-texto: 16pt,
) = {
  let r = radio / 1pt
  let s = escala / 1pt
  let xs = nodos.values().map(p => p.at(0))
  let ys = nodos.values().map(p => p.at(1))
  let (x0, x1) = (calc.min(..xs), calc.max(..xs))
  let (y0, y1) = (calc.min(..ys), calc.max(..ys))
  let hay-anot = anotaciones.len() > 0
  let pad = r + 6
  let lateral = anotaciones.values().any(a => type(a) == array and a.at(1) in (left, right)) or (hay-anot and lado-anotacion in (left, right))
  let pad-x = pad + if lateral { 52 } else if hay-anot { 14 } else { 0 }
  let pad-y = pad + if hay-anot { 16 } else { 0 }
  let pos(n) = {
    let (x, y) = nodos.at(n)
    ((x - x0) * s + pad-x, (y1 - y) * s + pad-y)
  }
  let color-de(n) = {
    let c = colores.at(n, default: none)
    if c == none { white } else if type(c) == int { paleta-grafo.at(calc.rem(c, paleta-grafo.len())) } else { c }
  }
  let norm(e) = if type(e) == str { let (a, b) = e.split("-"); (a, b, (:)) } else if e.len() == 2 { (e.at(0), e.at(1), (:)) } else { e }
  let aristas = aristas.map(norm)
  let pares = aristas.map(e => (e.at(0), e.at(1)))
  let pt(p) = (p.at(0) * 1pt, p.at(1) * 1pt)

  box(width: ((x1 - x0) * s + 2 * pad-x) * 1pt, height: ((y1 - y0) * s + 2 * pad-y) * 1pt, {
    for (a, b, op) in aristas {
      let apagada = op.at("apagada", default: false) or a in apagados or b in apagados
      if apagada { op.insert("color", _c-apagado) }
      let col = op.at("color", default: c-texto.lighten(20%))
      let st = _trazo(op, grosor)
      let (ax, ay) = pos(a)
      let (bx, by) = pos(b)
      let (dx, dy) = (bx - ax, by - ay)
      let d = calc.sqrt(dx * dx + dy * dy)
      if d == 0 { continue }
      let (ux, uy) = (dx / d, dy / d)
      let (nx, ny) = (-uy, ux)
      let k = op.at("curva", default: if dirigido and (b, a) in pares { 0.18 } else { 0 })
      // punto de control de la curva (cuadrática)
      let (cx, cy) = ((ax + bx) / 2 + nx * k * d, (ay + by) / 2 + ny * k * d)
      let dir(px, py, qx, qy) = { let l = calc.sqrt((qx - px) * (qx - px) + (qy - py) * (qy - py)); ((qx - px) / l, (qy - py) / l) }
      let (sx, sy) = dir(ax, ay, cx, cy)
      let (ex, ey) = dir(cx, cy, bx, by)
      let p1 = (ax + sx * r, ay + sy * r)
      let tip = (bx - ex * r, by - ey * r)
      let L = 9.0 + st.thickness / 1pt
      let W = 4.0 + st.thickness / 1pt
      let fin = if dirigido { (tip.at(0) - ex * L * 0.7, tip.at(1) - ey * L * 0.7) } else { tip }
      if k == 0 {
        place(line(start: pt(p1), end: pt(fin), stroke: st))
      } else {
        place(curve(stroke: st, curve.move(pt(p1)), curve.quad(pt((cx, cy)), pt(fin))))
      }
      if dirigido {
        let base = (tip.at(0) - ex * L, tip.at(1) - ey * L)
        place(polygon(fill: col, stroke: none,
          pt(tip),
          pt((base.at(0) + ey * W, base.at(1) - ex * W)),
          pt((base.at(0) - ey * W, base.at(1) + ex * W)),
        ))
      }
      let et = op.at("etiqueta", default: none)
      if et != none {
        let (mx, my) = (0.25 * ax + 0.5 * cx + 0.25 * bx, 0.25 * ay + 0.5 * cy + 0.25 * by)
        let lado = if k >= 0 { 1 } else { -1 }
        place(dx: (mx + nx * 12 * lado) * 1pt, dy: (my + ny * 12 * lado) * 1pt,
          place(center + horizon, text(size: tam-texto * 0.8, fill: col, weight: "bold", et)))
      }
    }
    for (n, _) in nodos {
      let (x, y) = pos(n)
      let apagado = n in apagados
      let fill = if apagado { luma(245) } else { color-de(n) }
      let borde = if apagado { 1.2pt + _c-apagado }
        else if n in resaltados { 3.2pt + c-acento }
        else { 1.3pt + if fill == white { c-texto } else { fill.darken(35%) } }
      place(dx: (x - r) * 1pt, dy: (y - r) * 1pt,
        circle(radius: radio, fill: fill, stroke: borde,
          align(center + horizon, text(size: tam-texto, weight: "bold",
            fill: if apagado { _c-apagado.darken(10%) } else if _oscuro(fill) { white } else { c-texto },
            etiquetas.at(n, default: n)))))
      let an = anotaciones.at(n, default: none)
      if an != none {
        let (txt, lado) = if type(an) == array { an } else { (an, lado-anotacion) }
        let off = r + 9
        let (ox, oy) = if lado == bottom { (0, off) } else if lado == top { (0, -off) }
          else if lado == left { (-r - 4, 0) } else { (r + 4, 0) }
        let anc = if lado == left { right + horizon } else if lado == right { left + horizon } else { center + horizon }
        place(dx: (x + ox) * 1pt, dy: (y + oy) * 1pt, place(anc,
          box(fill: c-fondo.transparentize(15%), inset: (x: 2pt, y: 1.5pt), radius: 2pt,
            text(size: tam-texto * 0.72, fill: if apagado { _c-apagado.darken(10%) } else { c-primario },
              weight: "bold", txt))))
      }
    }
  })
}

// Leyenda de estilos de arista: #leyenda((arbol, [Árbol]), (retroceso, [Retroceso]))
#let leyenda(..items, dirigido: true) = {
  set text(size: 15pt)
  grid(columns: 2, column-gutter: 0.6em, row-gutter: 0.55em, align: horizon,
    ..items.pos().map(((op, et)) => {
      let col = op.at("color", default: c-texto.lighten(20%))
      (box(width: 1.4cm, height: 0.5em, {
        place(horizon, line(length: if dirigido { 1.1cm } else { 1.4cm }, stroke: _trazo(op, 1.3pt)))
        if dirigido { place(horizon + right, polygon(fill: col, (0pt, -4pt), (9pt, 0pt), (0pt, 4pt))) }
      }), et)
    }).flatten())
}

// ========================================================= Pila y cola ======
// Elementos: contenido, o (contenido, color) para pintarlo.
#let _celda(e, ancho) = {
  let (c, col) = if type(e) == array { e } else { (e, none) }
  let fill = if col == none { white } else if type(col) == int { paleta-grafo.at(col) } else { col }
  box(width: ancho, height: 0.95cm, fill: fill, stroke: 1.2pt + c-texto.lighten(30%), radius: 2pt,
    align(center + horizon, text(size: 15pt, weight: "bold", c)))
}

// Pila vertical; el tope es el último elemento y se dibuja arriba.
#let pila(elems, titulo: [pila], ancho: 1.3cm) = {
  set align(center)
  block(breakable: false, {
    text(size: 13pt, fill: c-suave, titulo)
    v(-0.5em)
    if elems.len() == 0 { box(width: ancho, height: 0.95cm, stroke: (bottom: 2pt + c-texto)) }
    else {
      stack(dir: ttb, spacing: -1.2pt, ..elems.rev().map(e => _celda(e, ancho)))
      v(-0.85em)
      line(length: ancho + 0.4cm, stroke: 2pt + c-texto)
    }
  })
}

// Cola / lista horizontal; el frente es el primer elemento (izquierda).
#let cola(elems, titulo: none, ancho: 1cm) = box({
  if titulo != none { box(baseline: -0.3em, text(size: 14pt, fill: c-suave, titulo)) + h(0.5em) }
  if elems.len() == 0 { box(width: ancho, height: 0.95cm, stroke: (paint: c-suave, dash: "dashed")) }
  else { stack(dir: ltr, spacing: -1.2pt, ..elems.map(e => _celda(e, ancho))) }
})
