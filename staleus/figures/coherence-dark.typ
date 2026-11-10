#set text(size: 14pt, font: ("Berkeley Mono"))

#let node_bg = rgb("#3c3836")
#let fg = rgb("#ebdbb2")
#let bg = rgb("#282828")

#let psp_bg = rgb("#416936")
#let dirty_bg = rgb("#8f3f3f")

#set page(width: 17cm, height: 8cm, fill: bg)

#set text(fill: fg)

#import "memory-coherence-diagram.typ": memory-diagram

#memory-diagram(
  fg: fg, 
  bg: bg, 
  node_bg: node_bg,
  psp_bg: psp_bg,
  cs_bg: node_bg,
  umc_bg: node_bg,
  dirty_bg: dirty_bg
)