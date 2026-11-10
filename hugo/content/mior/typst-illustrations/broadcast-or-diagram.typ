// Based on illustrations/or-shadow-2{,b}.tex in the MIOR paper.
// Address ranges are schematic, not drawn to scale; hex values are the paper's example.
#let illustration(fg, bg, node-bg, fabric-bg, good, bad) = {
  set text(font: "DejaVu Sans", size: 10pt, fill: fg)
  let range-row(label, malicious: false) = grid(
    columns: (2.1cm, 3.5cm),
    align: horizon,
    gutter: .1cm,
    text(size: 9pt, label),
    block(width: 3.5cm, height: .65cm, fill: node-bg, stroke: fg + .5pt)[
      #place(
        top + left,
        dx: if malicious { .3cm } else { 2.2cm },
        rect(
          width: if malicious { .7cm } else { .9cm },
          height: .65cm,
          fill: if malicious { bad.lighten(65%) } else { fabric-bg },
          stroke: (if malicious { bad } else { good }) + .8pt,
          align(center + horizon, text(
            fill: if malicious { rgb("282828") } else { fg },
            weight: "bold",
            if malicious { [RM] } else { [RB] },
          )),
        ),
      )
    ],
  )
  let panel(title, malicious: false) = block(width: 6.15cm, inset: .2cm, stroke: fg + .6pt, radius: 5pt)[
    #align(center, strong(title))
    #v(.25cm)
    #range-row([IOMS `0x20`])
    #v(.2cm)
    #range-row([IOMS `0x22`], malicious: malicious)
    #v(.2cm)
    #align(center)[↓ Broadcast read: bitwise OR]
    #v(.2cm)
    #range-row([PSP map])
    #v(.25cm)
    #text(size: 9pt, if malicious { [RM is absent from the PSP’s MMIO map.] } else {
      [Both entries describe the same MMIO range.]
    })
  ]
  block(width: 13cm)[
    #align(center, text(size: 13pt, weight: "bold", [How broadcast OR hides a routing rule]))
    #v(.35cm)
    #grid(
      columns: (1fr, 1fr),
      gutter: .35cm,
      panel([Benign configuration]), panel([Malicious configuration], malicious: true),
    )
    #v(.35cm)
  ]
}
