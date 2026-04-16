#set text(size: 14pt)

#let bg = rgb("#282828")
#let fg = rgb("#ebdbb2")
#let node_bg = rgb("#3c3836")
#let df_col_neg = rgb("#ab3824")
#let df_col = rgb("#416936")

#set page(width: 15cm, height: 20cm, fill: bg)

#set text(fill: fg)

#import "./attack-overview.typ": attack-overview

#attack-overview(fg, df_col, df_col_neg, bg, node_bg)
