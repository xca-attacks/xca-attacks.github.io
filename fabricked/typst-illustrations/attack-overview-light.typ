#set text(size: 14pt)

#let node_bg = rgb("#fbf1c7")
#let bg = rgb("#f9f5ed")
#let fg = rgb("#3c3836")

#let df_col_neg = rgb("#db7854")
#let df_col = rgb(180, 230, 130)

#set page(width: 15cm, height: 20cm, fill: bg)

#set text(fill: fg)

#import "./attack-overview.typ": attack-overview

#attack-overview(fg, df_col, df_col_neg, bg, node_bg)
