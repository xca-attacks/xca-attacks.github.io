#import "@preview/fletcher:0.5.8": *

#let sequence(fg, bg) = diagram({
  node(width: 3.2cm, height: 1cm, stroke: 1pt + fg, `x86 Core`, name: <core>)
  node(width: 3.2cm, height: 1cm, stroke: 1pt + fg, (rel: (5cm, 0cm)), `Data Fabric`, name: <df>)
  node(width: 3.2cm, height: 1cm, stroke: 1pt + fg, (rel: (5cm, 0cm)), `PSP`, name: <psp>)

  edge(<core.south>, (rel: (0cm, -8cm)), stroke: 1pt + fg, dash: "dashed", "-|>")
  edge(<df.south>, (rel: (0cm, -8cm)), stroke: 1pt + fg, dash: "dashed", "-|>")
  edge(<psp.south>, (rel: (0cm, -8cm)), stroke: 1pt + fg, dash: "dashed", "-|>")

  edge(
    stroke: 1pt + fg,
    (rel: (-.15cm, -1.5cm), to: <psp.south>),
    (rel: (.15cm, -1.5cm), to: <df.south>),
    label: [`1. configure DRAM`

      `   routing`],
    "-|>",
  )

  edge(
    stroke: 1pt + fg,
    (rel: (-.15cm, -2.5cm), to: <psp.south>),
    (rel: (.15cm, -2.5cm), to: <core.south>),
    label: [`2. wake x86 CPU` ],
    "-|>",
    label-pos: .75
  )

edge(
    stroke: 1pt + fg,
    (rel: (-.15cm, -3.0cm), to: <core.south>),
    (rel: (-1.15cm, -3.0cm), to: <core.south>),
    (rel: (-1.15cm, -4.0cm), to: <core.south>),
    (rel: (-.15cm, -4.0cm), to: <core.south>),
    label: [`3. wake x86 CPU` ],
    "-|>",
    label-side: left,
    label-sep: 1.3cm
  )

edge(
    stroke: 1pt + fg,
    (rel: (.15cm, -5.5cm), to: <core.south>),
    (rel: (-.15cm, -5.5cm), to: <df.south>),
    label: [`4. Configure MMIO`

    `   routing`],
    "-|>",
    label-side: left,
  )

  edge(
    stroke: 1pt + fg,
    (rel: (-.15cm, -7.0cm), to: <psp.south>),
    (rel: (.15cm, -7.0cm), to: <core.south>),
    label: [`5. Notiy about UEFI`

    `   completion` ],
    "<|-",
    label-pos: .25
  )

})
