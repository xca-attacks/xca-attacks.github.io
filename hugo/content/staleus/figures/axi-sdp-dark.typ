#set text(size: 14pt, font: ("Berkeley Mono"))

#let node_bg = rgb("#3c3836")
#let fg = rgb("#ebdbb2")
#let bg = rgb("#282828")

#let df_col = rgb("#416936")

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