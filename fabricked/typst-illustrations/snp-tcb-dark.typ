#set text(size: 14pt)

#let bg = rgb("#282828")
#let fg = rgb("#ebdbb2")

#let signed-col = rgb("#416936")

#let unsigned-col = rgb("#ab3824")


#set page(width: 17cm, height: 9cm, fill: bg)

#set text(fill: fg)

#import "./snp-tcb.typ": tcb-diagram

#align(center + horizon, tcb-diagram(fg, bg, signed-col, unsigned-col))
