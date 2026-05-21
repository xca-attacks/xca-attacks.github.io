#let bg = rgb("#f9f5ed")
#let fg = rgb("#3c3836")
#set text(size: 14pt, fill: fg)

#set page(width: 14cm, height: 10cm, fill: bg)
#set align(horizon + center)

#import "boot-sequence.typ": sequence
#set par(leading: 0pt, spacing: 5pt)
#align(center + horizon, sequence(fg, bg))
