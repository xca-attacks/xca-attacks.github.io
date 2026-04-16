#import "@preview/fletcher:0.5.8": *

#let fabric-diagram(fg, df_col, bg, node_bg) = {
  align(center + horizon, diagram({
    node(width: 12cm, height: 6cm, corner-radius: .7cm, "", name: <SoC>, layer: 0)
    //node((rel: (-4.0cm, 2cm), to: <SoC>), `SoC`)

    node(
      (rel: (0cm, 0cm), to: <SoC>),
      name: <DF>,
      stroke: fg,
      fill: df_col,
      width: 6cm,
      height: 3cm,
      corner-radius: .7cm,
      `Data Fabric`,
    )

    let coords = (
      ("CS1", -1.25cm, 1.1cm),
      ("CS2", 1.25cm, 1.1cm),
      ("IOMS1", -1.25cm, -1.1cm),
      ("CCM1", -2.6cm, 0cm),
      ("CCM2", 2.6cm, 0cm),
    )

    for (name, x, y) in coords {
      node(
        (rel: (x, y), to: <DF>),
        stroke: fg,
        width: .8cm,
        height: .8cm,
        fill: node_bg,
        "",
        name: label(name),
        layer: 5,
      )
    }

    /* ("IOMS2", 1.25cm, -1.1cm), */
    node(
      (rel: (1.25cm, -1.1cm), to: <DF>),
      stroke: fg,
      width: .8cm,
      height: .8cm,
      fill: node_bg,
      "",
      name: <IOMS2>,
      layer: 5,
    )


    node(
      (rel: (0cm, -.75cm), to: <DF.south>),
      stroke: fg,
      width: 4cm,
      height: .8cm,
      fill: node_bg,
      `I/O Crossbar`,
      layer: 3,
      name: <Crossbar>,
    )

    node(
      (rel: (0cm, .75cm), to: <DF.north>),
      stroke: fg,
      width: 4cm,
      height: .8cm,
      fill: node_bg,
      `Mem Controllers`,
      layer: 3,
      name: <UMC>,
    )

    node(
      (rel: (-1.5cm, 0cm), to: <DF.west>),
      stroke: fg,
      width: 2cm,
      height: 1.5cm,
      fill: node_bg,
      `CPU Cores`,
      layer: 3,
      name: <CPU1>,
    )

    node(
      (rel: (1.5cm, 0cm), to: <DF.east>),
      stroke: fg,
      width: 2cm,
      height: 1.5cm,
      fill: node_bg,
      `CPU Cores`,
      layer: 3,
      name: <CPU2>,
    )

    node(
      (rel: (0cm, 2.7cm), to: <CS1>),
      width: 1.5cm,
      height: .8cm,
      stroke: fg,
      fill: node_bg,
      `DRAM`,
      name: <dram1>,
      layer: 4,
    )

    node(
      (rel: (0cm, 2.7cm), to: <CS2>),
      width: 1.5cm,
      height: .8cm,
      stroke: fg,
      fill: node_bg,
      `DRAM`,
      name: <dram2>,
    )

    node(
      (rel: (0cm, -2.7cm), to: <IOMS1>),
      width: 1.5cm,
      height: .8cm,
      stroke: fg,
      fill: node_bg,
      `PCIe`,
      name: <PCI1>,
    )

    node(
      (rel: (3.5cm, -.75cm), to: <DF.south>),
      width: 1.5cm,
      height: .8cm,
      stroke: fg,
      fill: node_bg,
      `PSP`,
      name: <PCI2>,
    )


    edge(stroke: fg, <IOMS1.south>, (rel: (0cm, -1cm), to: <IOMS1.south>))
    edge(stroke: fg, <IOMS2.south>, (rel: (0cm, -1cm), to: <IOMS2.south>))

    edge(stroke: fg, <CS1.north>, (rel: (0cm, 1cm), to: <CS1.north>))
    edge(stroke: fg, <CS2.north>, (rel: (0cm, 1cm), to: <CS2.north>))

    edge(stroke: fg + 1pt, <CCM1.west>, (rel: (-1cm, 0cm), to: <CCM1.west>))
    edge(stroke: fg + 1pt, <CCM2.east>, (rel: (1cm, 0cm), to: <CCM2.east>))

    edge(
      stroke: fg + 1pt,
      <UMC.north>,
      (rel: (0cm, -1cm), to: <dram1.south>),
      (rel: (0cm, 0cm), to: <dram1.south>),
      layer: 2,
    )

    edge(stroke: fg, <UMC.north>, (rel: (0cm, -1cm), to: <dram2.south>), (rel: (0cm, 0cm), to: <dram2.south>), layer: 2)

    edge(
      stroke: fg,
      <Crossbar.south>,
      (rel: (0cm, 1cm), to: <PCI1.north>),
      (rel: (0cm, 0cm), to: <PCI1.north>),
      layer: 2,
    )
    edge(
      stroke: fg + 1pt,
      <Crossbar.east>,
      <PCI2.west>,
      layer: 2,
    )

    // SMN Side-band Network (Strictly Orthogonal & Clean)
    let smn_stroke = (paint: red, thickness: 1.2pt)

    // SMN Label with background to avoid overlap
    node(
      (-0.95cm, 1cm),
      fill: bg,
      text(red, size: 15pt, font: "Adwaita Sans", weight: "bold", "Control Fabric"),
      layer: 7,
      name: <SMN>,
    )

    edge(
      stroke: smn_stroke,
      <SMN.east>,
      (rel: (0.0cm, -1.25cm), to: <CPU1.south>),
      <CPU1.south>,
      layer: 2,
    )

    edge(
      stroke: smn_stroke,
      <SMN.east>,
      (rel: (0.0cm, -1.25cm), to: <CPU1.south>),
      (rel: (-2.5cm, 0cm), to: <Crossbar.west>),
      <Crossbar.west>,
      layer: 2,
    )
    edge(
      stroke: smn_stroke,
      <SMN.east>,
      (rel: (0.0cm, -1.25cm), to: <CPU1.south>),
      (rel: (-8cm, -0.3cm), to: <PCI2.south>),
      (rel: (0cm, -0.3cm), to: <PCI2.south>),
      <PCI2.south>,
      layer: 2,
    )

    edge(
      stroke: smn_stroke,
      <SMN.east>,
      (rel: (0.0cm, -1.25cm), to: <CPU1.south>),
      (rel: (-9cm, -2.2cm), to: <CPU2.south>),
      (rel: (0cm, -2.2cm), to: <CPU2.south>),
      <CPU2.south>,
      layer: 2,
    )

    edge(
      stroke: smn_stroke,
      <SMN.east>,
      (rel: (0.0cm, -1.25cm), to: <CPU1.south>),
      (rel: (0.0cm, -0.50cm), to: <CPU1.south>),
      (rel: (-1.25cm, -3.5cm), to: <UMC.west>),
      (rel: (-1.25cm, 0cm), to: <UMC.west>),
      <UMC.west>,
      layer: 2,
    )

    edge(
      stroke: smn_stroke,
      <SMN.east>,
      (rel: (0.0cm, -1.25cm), to: <CPU1.south>),
      (rel: (0.0cm, -0.90cm), to: <CPU1.south>),
      (rel: (1.5cm, -0.90cm), to: <CPU1.south>),
      <DF.south-west>,
      layer: 2,
    )
  }))
}
