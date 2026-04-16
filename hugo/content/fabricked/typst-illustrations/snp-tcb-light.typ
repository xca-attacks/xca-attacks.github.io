#set text(size: 14pt)

#let bg = rgb("#f9f5ed")
#let fg = rgb("#3c3836")

#let signed-col = rgb(180, 230, 130)

#let unsigned-col = rgb("#db7854")

#set page(width: 17cm, height: 9cm, fill: bg)

#set text(fill: fg)

#import "./snp-tcb.typ": tcb-diagram

#align(center + horizon, tcb-diagram(fg, bg, signed-col, unsigned-col))

