#set text(size: 14pt)

#let node_bg = rgb("#fbf1c7")
#let bg = rgb("#f9f5ed")
#let fg = rgb("#3c3836")
#let attack_col = rgb("#b87d83")

#let df_col = rgb(180, 230, 130)

#set page(width: 14cm, height: 10cm, fill: bg)

#set text(fill: fg)

#import "./fabric-routing-diagram.typ": fabric-diagram

#fabric-diagram(fg, df_col, bg, node_bg, attack_col)
