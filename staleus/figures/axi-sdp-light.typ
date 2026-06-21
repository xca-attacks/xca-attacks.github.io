#set text(size: 14pt, font: ("Berkeley Mono"))

#let node_bg = rgb("#fbf1c7")
#let bg = rgb("#f9f5ed")
#let fg = rgb("#3c3836")
#let df_col = rgb(180, 230, 130)

// The margin is critical here so it doesn't overflow!
#set page(width: 18cm, height: 5cm, fill: bg, margin: 0.5cm) 

#set text(fill: fg)

#import "axi-sdp-diagram.typ": axi-sdp-diagram

#axi-sdp-diagram(
  fg: fg, 
  bg: bg, 
  node_bg: node_bg,
  df_bg: df_col,
)