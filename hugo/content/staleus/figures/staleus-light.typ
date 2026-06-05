#set text(size: 14pt, font: "Berkeley Mono")

#let node_bg = rgb("#fbf1c7")
#let bg = rgb("#f9f5ed")
#let fg = rgb("#3c3836")

// Original light pastel colors
#let psp_bg = rgb(180, 230, 130)
#let dirty_bg = rgb("#ffcdd2")

#set page(width: 17cm, height: 8cm, fill: bg)

#set text(fill: fg)

#import "staleus-diagram.typ": memory-diagram

  #stack(
    spacing: 2cm, // Adjust this value to increase or decrease the gap between the two diagrams
    memory-diagram(
      fg: fg,
      bg: bg,
      node_bg: node_bg,
      psp_bg: psp_bg,
      cs_bg: node_bg,
      umc_bg: node_bg,
      dirty_bg: dirty_bg,
      toggle: true,
    ),
    memory-diagram(
      fg: fg,
      bg: bg,
      node_bg: node_bg,
      psp_bg: psp_bg,
      cs_bg: node_bg,
      umc_bg: node_bg,
      dirty_bg: dirty_bg,
      toggle: false,
    ),
  )
