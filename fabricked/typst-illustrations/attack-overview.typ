#import "@preview/fletcher:0.5.8": *

#let label-res(label-name, side, postfix: "") = {
  let suffix = if side == -1 {
    "_b"
  } else {
    "_a"
  }
  let post = if postfix == "" {
    ""
  } else {
    "." + postfix
  }
  label(label-name + suffix + post)
}

#let part(fg, df_col, bg, node_bg, side: 1) = {
  node(
    (rel: (4.7cm, side * 5.5cm), to: <left>),
    stroke: 1pt + fg,
    fill: node_bg,
    `Linux Kernel`,
    name: label-res("kernel", side),
    height: 1cm,
    width: 5cm,
  )
  node(
    (rel: (0cm, -1.5cm), to: label-res("kernel", side)),
    stroke: 1pt + fg,
    `init_sev_snp()`,
    name: label-res("kernel_code", side),
    height: 2cm,
    width: 5cm,
  )

  node(
    (rel: (6.5cm, 3.5cm), to: label-res("kernel", side)),
    fill: node_bg,
    stroke: 1pt + fg,
    `PSP`,
    name: label-res("psp", side),
    height: 1cm,
    width: 5cm,
  )
  node(
    (rel: (0cm, -1.5cm), to: label-res("psp", side)),
    stroke: 1pt + fg,
    `write_rmp()`,
    name: label-res("psp_code", side),
    height: 2cm,
    width: 5cm,
  )

  edge(
    label-res("kernel_code", side, postfix: "east"),
    (rel: (.75cm, 0cm), to: label-res("kernel_code", side, postfix: "east")),
    (rel: (-.75cm, 0cm), to: label-res("psp_code", side, postfix: "west")),
    label-res("psp_code", side, postfix: "west"),
    "-|>",
    stroke: 1pt + fg,
  )

  node(
    name: label-res("df", side),
    (rel: (0cm, -3.5cm), to: label-res("psp_code", side)),
    height: 3cm,
    width: 5.5cm,
    stroke: 1pt + fg,
    corner-radius: 10pt,
    fill: df_col.transparentize(70%),
    "",
  )
  edge(label-res("psp_code", side), label-res("df", side), stroke: 2pt + df_col)


  node(
    name: label-res("ioms1", side),
    (rel: (0cm, -.5cm), to: label-res("df", side, postfix: "north")),
    height: 1.0cm,
    width: 1.6cm,
    stroke: 1pt + fg,
    corner-radius: 7pt,
    fill: node_bg,
    ``,
  )
  node(
    name: label-res("ioms2", side),
    (rel: (1.5cm, .5cm), to: label-res("df", side, postfix: "south")),
    height: 1.0cm,
    width: 1.6cm,
    stroke: 1pt + fg,
    corner-radius: 7pt,
    fill: node_bg,
    ``,
  )

  node(
    name: label-res("cs", side),
    (rel: (-1.5cm, .5cm), to: label-res("df", side, postfix: "south")),
    height: 1.0cm,
    width: 1.6cm,
    stroke: 1pt + fg,
    corner-radius: 7pt,
    fill: node_bg,
    ``,
  )

  node(
    (rel: (-1cm, -1.25cm), to: label-res("df", side, postfix: "south")),
    name: label-res("dram", side),
    stroke: 1pt + fg,
    width: 9cm,
    height: 1cm,
  )

  node(
    (rel: (.7cm, 0cm), to: label-res("dram", side, postfix: "west")),
    `DRAM`,
  )

  node(
    (rel: (1.5cm, 0cm), to: label-res("dram", side)),
    name: label-res("rmp", side),
    `RMP`,
    stroke: 1pt + fg,
    width: 5cm,
    height: 1cm,
    fill: df_col.transparentize(70%),
  )

  if side != -1 {
    edge(
      label-res("cs", side, postfix: "south"),
      (rel: (0cm, -.275cm), to: label-res("cs", side, postfix: "south")),
      (rel: (0cm, .475cm), to: label-res("rmp", side, postfix: "north")),
      (rel: (0cm, .2cm), to: label-res("rmp", side, postfix: "north")),
      stroke: 2pt + df_col,
      mark-scale: 50%,
    )

    edge(
      (rel: (0cm, .2cm), to: label-res("rmp", side, postfix: "north")),
      (rel: (0cm, .0cm), to: label-res("rmp", side, postfix: "north")),
      stroke: 1pt + df_col,
      "-|>",
    )
    edge(
      label-res("ioms1", side, postfix: "south"),
      (rel: (0cm, -.5cm), to: label-res("ioms1", side, postfix: "south")),
      (rel: (0cm, .5cm), to: label-res("cs", side, postfix: "north")),
      label-res("cs", side, postfix: "north"),
      stroke: 2pt + df_col,
      dash: "loosely-dashed",
    )
  } else {
    // edge(
    //   label-res("ioms2", side, postfix: "south"),
    //   (rel: (0cm, -.375cm), to: label-res("ioms2", side, postfix: "south")),
    //   stroke: 2pt + df_col,
    // )
    //
    // edge(
    //   label-res("ioms2", side, postfix: "south"),
    //   (rel: (0cm, -.375cm), to: label-res("ioms2", side, postfix: "south")),
    //   stroke: 1pt + df_col,
    //   "-X",
    // )
    //
    edge(
      label-res("ioms1", side, postfix: "south"),
      (rel: (0cm, -.5cm), to: label-res("ioms1", side, postfix: "south")),
      (rel: (0cm, .5cm), to: label-res("ioms2", side, postfix: "north")),
      label-res("ioms2", side, postfix: "north"),
      stroke: 2pt + df_col,
      dash: "loosely-dashed",
    )
  }
}

#let attack-overview(fg, df_col, neg_col, bg, node_bg) = {
  align(center + horizon, diagram({
    node(name: <left>, "")
    node((rel: (16cm, 0cm), to: <left>), name: <right>, "")
    edge(<left>, <right>, dash: "loosely-dotted", stroke: fg + 2pt)

    node((rel: (1cm, 4cm), to: <left>), rotate(
      -90deg,
      `Normal
Initialization`,
    ))
    node((rel: (1cm, -7cm), to: <left>), rotate(
      -90deg,
      `Malicious
Initialization`,
    ))

    part(fg, df_col, bg, node_bg)
    part(fg, neg_col, bg, node_bg, side: -1)
  }))
}
