#let bg = rgb("#282828")
#let fg = rgb("#ebdbb2")
#set text(size: 14pt, fill: fg)

#set page(width: 14cm, height: 10cm, fill: bg)
#set align(horizon + center)

#import "boot-sequence.typ": sequence
#set par(leading: 0pt, spacing: 5pt)
#align(center + horizon, sequence(fg, bg))
