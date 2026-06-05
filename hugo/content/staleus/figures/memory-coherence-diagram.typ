#import "@preview/fletcher:0.5.8": *



#let memory-diagram(
  fg: black,
  bg: white,
  node_bg: white,
  psp_bg: rgb("#bbdefb"),
  cs_bg: rgb("#c8e6c9"),
  umc_bg: rgb("#e1bee7"),
  dirty_bg: rgb("#ffcdd2"),
) = {
  // Ensure all text inside the diagram uses the provided foreground color

  set text(fill: fg)


  align(
    center + horizon,

    diagram({
      // Background SoC Box
      node((0cm, 0cm), stroke: fg + 1.5pt, width: 14cm, height: 7.5cm, corner-radius: .5cm, "", name: <SoC>, layer: 0)
      node((rel: (0cm, -3.2cm), to: <SoC>), text(size: 16pt, weight: "bold")[AMD EPYC System on Chip])
      // Cores & Caches
      node((rel: (-5.2cm, -1.8cm), to: <SoC>), name: <core1>, stroke: fg, fill: node_bg, width: 2.5cm, height: 0.8cm, `x86 core`)
      node((rel: (-3.2cm, -1.8cm), to: <SoC>), name: <cache1>, stroke: fg, fill: node_bg, width: 1.6cm, height: 0.8cm, `cache`)
      node((rel: (-5.2cm, 0cm), to: <SoC>), name: <core2>, stroke: fg, fill: node_bg, width: 2.5cm, height: 0.8cm, `x86 core`)
      node((rel: (-3.2cm, 0cm), to: <SoC>), name: <cache2>, stroke: fg, fill: node_bg, width: 1.6cm, height: 0.8cm, `cache`)
      node((rel: (-5.2cm, 1.8cm), to: <SoC>), name: <core3>, stroke: fg, fill: node_bg, width: 2.5cm, height: 0.8cm, `x86 core`)
      node((rel: (-3.2cm, 1.8cm), to: <SoC>), name: <cache3>, stroke: fg, fill: dirty_bg, width: 1.6cm, height: 0.8cm, `cache`)
      node(
        (rel: (-3.2cm, 2.6cm), to: <SoC>),
        name: <cacheVal>,
        stroke: fg,
        fill: dirty_bg,
        width: 1.6cm,
        height: 0.8cm,
        corner-radius: 0.2cm,
        `0xFA1B`,
      )

      // PSP, CS, UMC
      node((rel: (3.2cm, -2.4cm), to: <SoC>), name: <psp>, stroke: fg, fill: psp_bg, width: 1.4cm, height: 0.8cm, `PSP`)
      node((rel: (3.2cm, 0cm), to: <SoC>), name: <cs>, stroke: fg, fill: cs_bg, width: 3.2cm, height: 1cm, `Coherence Controller`)
      node((rel: (3.2cm, 1.8cm), to: <SoC>), name: <umc>, stroke: fg, fill: umc_bg, width: 3.2cm, height: 1cm, `Memory Controller`)
      // DRAM
      node((rel: (8.5cm, 1.8cm), to: <SoC>), name: <dram>, stroke: fg, fill: node_bg, width: 1.6cm, height: 1cm, `DRAM`)
      node(
        (rel: (8.5cm, 2.8cm), to: <SoC>),
        name: <dramVal>,
        stroke: fg,
        fill: node_bg,
        width: 1.6cm,
        height: 1cm,
        corner-radius: 0.2cm,
        `0x0000`,
      )

      // Edges
      edge(<cs>, <umc>, "-", stroke: fg + 1.2pt)
      edge(<umc>, <dram>, "-", stroke: fg + 1.2pt)
      edge(
        <psp>,
        <cs>,
        "-|>",
        stroke: fg + 1.2pt,
        label: align(center,text(size: 10pt)[1\. memory \ write 0xAFFE]),
        label-side: left,
        label-pos: 0.4,
      )
      edge(<cs>, <cache1.east>, "-|>", stroke: fg + 1.2pt)
      edge(<cs>, <cache3.east>, "-|>", stroke: fg + 1.2pt)
      edge(
        <cs>,
        <cache2.east>,
        "-|>",
        stroke: fg + 1.2pt,
        label: align(center, text(size: 10pt)[2\. cache \ snoop]),
        label-side: center,
        label-pos: 0.55,
        label-fill: none,
      )
      edge(
        <cache3.east>,
        <umc.west>,
        "-|>",
        stroke: fg + 1.2pt,
        label: align(center, move(dy: -10pt, text(size: 10pt)[3\. respond with \ dirty data])),
        label-side: center,
        label-pos: 0.5,
        label-fill: none,
      )
    }),
  )
}
