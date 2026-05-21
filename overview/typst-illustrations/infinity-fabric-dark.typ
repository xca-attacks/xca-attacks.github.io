#set text(size: 14pt)

#let bg = rgb("#282828")
#let fg = rgb("#ebdbb2")
#let node_bg = rgb("#3c3836")
#let df_col = rgb("#416936")

#set page(width: 16cm, height: 10cm, fill: bg)

#set text(fill: fg)

#import "./infinity-fabric-diagram.typ": fabric-diagram

#fabric-diagram(fg, df_col, bg, node_bg)
