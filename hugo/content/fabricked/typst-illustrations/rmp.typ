#import "@preview/fletcher:0.5.8": *

#let rmp(fg, bg, normal, self, selfprotect) = stack(
  dir: ttb,
  spacing: 15%,
  align(center + horizon, scale(125%, diagram(
    node((0, 0), name: <origin>),
    let col(bg) = (
      node((rel: (1cm, 2cm)), stroke: 1pt + fg, width: 1cm, height: 1cm, fill: bg, ""),
      range(2).map(_ => node((rel: (0cm, -1cm)), stroke: 1pt + fg, width: 1cm, height: 1cm, fill: bg, "")),
    ).flatten(),


    range(3).map(_ => col(normal)),
    range(5).map(_ => col(self)),
    range(3).map(_ => col(normal)),

    node(
      (rel: (6cm, 1cm), to: <origin>),
      stroke: 1pt + fg,
      width: 1cm,
      height: 1cm,
      fill: selfprotect,
      "",
      layer: 2,
      name: <selfprotect>,
    ),

    edge(
      (rel: (4cm, 2.5cm), to: <origin>),
      (rel: (4cm, 3.5cm), to: <origin>),
      (rel: (1cm, 3.5cm), to: <origin>),
      (rel: (1cm, 2.5cm), to: <origin>),
      stroke: 1pt + fg,
      "-|>",
    ),

    edge(
      (rel: (8cm, 0.5cm), to: <origin>),
      (rel: (8cm, -1.5cm), to: <origin>),
      (rel: (11cm, -1.5cm), to: <origin>),
      (rel: (11cm, 0.5cm), to: <origin>),
      stroke: 1pt + fg,
      "-|>",
    ),

    edge(
      (rel: (0cm, 0cm), to: <selfprotect.south>),
      (rel: (0cm, -.5cm), to: <selfprotect.south>),
      (rel: (1cm, -.5cm), to: <selfprotect.south>),
      (rel: (1cm, 2.0cm), to: <selfprotect.north>),
      (rel: (0cm, 2.0cm), to: <selfprotect.north>),
      (rel: (0cm, 0cm), to: <selfprotect.north>),
      stroke: 1pt + fg,
      layer: 3,
      "-|>",
    ),
  ))),
  align(center + horizon, stack(
    dir: ltr,
    spacing: 2%,
    rect(
      width: .7cm,
      height: .7cm,
      radius: .1cm,
      stroke: 1pt + fg,
      fill: normal,
    ),
    `Protects DRAM`,
    v(5%),
    rect(
      width: .7cm,
      height: .7cm,
      radius: .1cm,
      stroke: 1pt + fg,
      fill: self,
    ),
    `Protects RMP`,
    v(5%),
    rect(
      width: .7cm,
      height: .7cm,
      radius: .1cm,
      stroke: 1pt + fg,
      fill: selfprotect,
    ),
    `"self protect entry"`,
  )),
)


