#set text(size: 14pt)

#let node_bg = rgb("#fbf1c7")
#let bg = rgb("#f9f5ed")
#let fg = rgb("#3c3836")
#let df_col = rgb(180, 230, 130)

#set page(width: 16cm, height: 10cm, fill: bg)

#set text(fill: fg)

#import "./infinity-fabric-diagram.typ": fabric-diagram

#fabric-diagram(fg, df_col, bg, node_bg)
