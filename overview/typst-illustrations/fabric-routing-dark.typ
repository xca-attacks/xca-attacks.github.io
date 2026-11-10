#set text(size: 14pt)

#let bg = rgb("#282828")
#let fg = rgb("#ebdbb2")
#let node_bg = rgb("#3c3836")
#let attack_col = rgb("#8e484f")

#let df_col = rgb(180, 230, 170)

#let df_col = rgb("#416936")

#set page(width: 14cm, height: 10cm, fill: bg)

#set text(fill: fg)

#import "./fabric-routing-diagram.typ": fabric-diagram

#fabric-diagram(fg, df_col, bg, node_bg, attack_col)
