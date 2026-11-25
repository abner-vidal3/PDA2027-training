#let dir = sys.inputs.at("dir")
#let n = int(sys.inputs.at("n"))
#let desde = int(sys.inputs.at("desde", default: "1"))
#let hasta = calc.min(n, desde + 11)
#set page(width: 36cm, height: auto, margin: 3mm)
#grid(columns: 3, gutter: 3mm, ..range(desde, hasta + 1).map(i => {
  let w = str(n).len()
  let f = dir + "/" + "0" * (w - str(i).len()) + str(i) + ".png"
  box(stroke: 0.5pt + gray, image(f, width: 100%)) + place(top + left, box(fill: yellow, inset: 2pt, text(10pt)[#i]))
}))
