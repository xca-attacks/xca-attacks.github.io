#import "@preview/fletcher:0.5.8": *

#let axi-sdp-diagram(
  fg: black,
  bg: white,
  node_bg: white,
  df_bg: rgb("#c8e6c9"),
) = {
  // Ensure all text inside the diagram uses the provided foreground color
  set text(fill: fg)

  align(
    center,
    diagram({
      // 1. PSP Node (Origin point)
      node(
        (0cm, 0cm),
        name: <psp>,
        stroke: fg + 1pt,
        fill: node_bg,
        width: 1.5cm,
        height: 1cm,
        [PSP],
      )
      node(
        (0cm, 1.5cm),
        name: <rand2>,
        stroke: fg + 1pt,
        fill: node_bg,
        width: 1.5cm,
        height: 1cm,
        [...],
      )

      node(
        (0cm, -1.5cm),
        name: <rand3>,
        stroke: fg + 1pt,
        fill: node_bg,
        width: 1.5cm,
        height: 1cm,
        [...],
      )

      // 2. SYSHUB Internal Components (Placed relative to PSP)
      node(
        (rel: (4cm, 0cm), to: <psp>),
        name: <crossbar>,
        stroke: fg + 1pt,
        fill: node_bg,
        width: 3cm,
        height: 1.9cm,
        [Crossbar],
      )
      node(
        (rel: (4.2cm, 0cm), to: <crossbar>),
        name: <axi_sdp>,
        stroke: fg + 1pt,
        fill: node_bg,
        width: 2cm,
        height: 1.9cm,
        align(center)[AXI \ to \ SDP],
      )

      // 3. SYSHUB Boundary Box (Enclosing the internal components)
      node(
        enclose: (<crossbar>, <axi_sdp>),
        name: <syshub>,
        stroke: (paint: fg, thickness: 1pt, dash: "dashed"),
        fill: none,
        inset: 25pt,
        align(center, move(dy: -40pt, text(size: 14pt)[*SYSHUB*])),
      )

      // 4. IOHUB (Placed relative to AXI to SDP)
      node(
        (rel: (3.8cm, 0cm), to: <axi_sdp>),
        name: <iohub>,
        stroke: fg + 1pt,
        fill: node_bg,
        width: 2cm,
        height: 1cm,
        [IOHUB],
      )

      // 5. Data Fabric (Placed relative to IOHUB)
      node(
        (rel: (2.5cm, 0cm), to: <iohub>),
        name: <df>,
        stroke: fg + 1pt,
        fill: df_bg,
        width: 2.2cm,
        height: 1.5cm,
        [Data Fabric],
      )

      // 6. Edges (Straight lines with floating text labels mapped from the XML)
/*       edge(
        <crossbar>,
        (rel: (0cm, -1.5cm), to: <psp.east>),
        "-",
        stroke: fg + 1.2pt,
      )
      edge(
        <crossbar>,
        (rel: (0cm, 1.5cm), to: <psp.east>),
        "-",
        stroke: fg + 1.2pt,
      ) */
      edge(<crossbar>,<rand2.east>,"-", stroke: fg + 1.2pt)
      edge(<crossbar>, <rand3.east>,"-",stroke: fg + 1.2pt)


      edge(
        <psp>,
        <crossbar>,
        "-",
        stroke: fg + 1.2pt,
        label: text(size: 10pt)[AXI],
        label-side: center,
        label-fill: bg,
      )

      edge(
        <crossbar>,
        <axi_sdp>,
        "-",
        stroke: fg + 1.2pt,
      )

      edge(
        <axi_sdp>,
        <iohub>,
        "-",
        stroke: fg + 1.2pt,
        label: text(size: 10pt)[SDP],
        label-side: center,
        label-fill: bg,
      )
      edge(
        <iohub>,
        <df>,
        "-",
        stroke: fg + 1.2pt,
      )
    }),
  )
}
