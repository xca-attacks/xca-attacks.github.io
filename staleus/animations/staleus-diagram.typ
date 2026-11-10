#import "@preview/fletcher:0.5.8": *
#import "@preview/kino:0.1.0": *

#let memory-diagram(
  fg: black,
  bg: white,
  node_bg: white,
  psp_bg: rgb("#bbdefb"),
  cs_bg: rgb("#c8e6c9"),
  umc_bg: rgb("#e1bee7"),
  dirty_bg: rgb("#ffcdd2"),
  progress: 0.0, // Now cleanly accepts the animation float
) = {
  // --- Opacity Timings (Based on Visual Research) ---
  // Fade-out State 1: 100ms duration (0.45 to 0.50)
  let opacity1 = if progress <= 0.45 { 1.0 } 
    else if progress < 0.50 { 1.0 - ((progress - 0.45) / 0.05) } 
    else { 0.0 }
    
  // Fade-in State 2: 150ms duration (0.50 to 0.575)
  let opacity2 = if progress <= 0.50 { 0.0 } 
    else if progress < 0.575 { (progress - 0.50) / 0.075 } 
    else { 1.0 }

  // Helper function to safely apply dynamic alpha transparency to any Typst color
  let apply-alpha(c, alpha) = {
    let rgb_color = c.rgb()
    let comps = rgb_color.components()
    rgb(comps.at(0), comps.at(1), comps.at(2), alpha * 100%)
  }

  // Generate the transparent color states
  let fg1 = apply-alpha(fg, opacity1)
  let psp_bg1 = apply-alpha(psp_bg, opacity1)
  
  let fg2 = apply-alpha(fg, opacity2)
  let dirty_bg2 = apply-alpha(dirty_bg, opacity2)

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
      node((rel: (-3.2cm, 2.6cm), to: <SoC>), name: <cacheVal>, stroke: fg, fill: dirty_bg, width: 1.6cm, height: 0.8cm, corner-radius: 0.2cm, `0xFA1B`)

      // PSP, CS, UMC
      node((rel: (3.2cm, -2.4cm), to: <SoC>), name: <psp>, stroke: fg, fill: node_bg, width: 1.4cm, height: 0.8cm, `PSP`)
      node((rel: (3.2cm, 0cm), to: <SoC>), name: <cs>, stroke: fg, fill: cs_bg, width: 3.2cm, height: 1cm, `Coherence Controller`)
      node((rel: (3.2cm, 1.8cm), to: <SoC>), name: <umc>, stroke: fg, fill: umc_bg, width: 3.2cm, height: 1cm, `Memory Controller`)
      
      // DRAM
      node((rel: (8.5cm, 1.8cm), to: <SoC>), name: <dram>, stroke: fg, fill: node_bg, width: 1.6cm, height: 1cm, `DRAM`)

      // Edges
      edge(<umc>, <dram>, "-|>", stroke: fg + 1.2pt)

      node((8.5cm, -2cm), stroke: none, fill: none, [
        #align(center)[
          #stack(
            dir: ttb, 
            spacing: 0.15cm,
            image("./staleus.svg", width: 3cm),
          )
        ]
      ])

      // === State 1: Disappears smoothly at progress > 0.45 ===
      if opacity1 > 0.0 {
        edge(
          <psp>, <cs>, "-|>", stroke: fg1 + 1.2pt, 
          label: align(center, text(fill: fg1, size: 10pt)[1\. PSP writes \ 0xAFFE to DRAM]), 
          label-side: left, label-pos: 0.4
        )
        node(
          (rel: (8.5cm, 2.8cm), to: <SoC>), name: <dramVal1>, 
          stroke: fg1, fill: psp_bg1, width: 1.6cm, height: 1cm, corner-radius: 0.2cm, 
          text(fill: fg1)[`0xAFFE`]
        )
        edge(<cs>, <umc>, "-|>", stroke: fg1 + 1.2pt)
      } 
      
      // === State 2: Appears smoothly at progress > 0.50 ===
      if opacity2 > 0.0 {
        node(
          (rel: (8.5cm, 2.8cm), to: <SoC>), name: <dramVal2>, 
          stroke: fg2, fill: dirty_bg2, width: 1.6cm, height: 1cm, corner-radius: 0.2cm, 
          text(fill: fg2)[`0xFA1B`]
        )
        edge(
          <cache3.east>, <umc.west>, "-|>", stroke: fg2 + 1.2pt, 
          label: align(center, move(dy: -17pt, text(fill: fg2, size: 10pt)[2\. Core flushes \ dirty cache line])), 
          label-side: center, label-pos: 0.5, label-fill: none
        )
        edge(<cs>, <umc>, "-", stroke: fg2 + 1.2pt)
      }
    }),
  )
}