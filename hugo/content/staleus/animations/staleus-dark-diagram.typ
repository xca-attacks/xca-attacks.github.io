#import "@preview/kino:0.1.0": *

#set text(size: 14pt, font: ("Berkeley Mono"))

#let node_bg = rgb("#3c3836")
#let fg = rgb("#ebdbb2")
#let bg = rgb("#282828")

#let psp_bg = rgb("#416936")
#let dirty_bg = rgb("#8f3f3f")

// --- Kino Animation Logic ---
#set page(width: 17cm, height: 8cm, fill: bg)
#set text(fill: fg)

// 1. Initialize the animation show rule
#show: animation

// 2. Define the animation logic in a separate function that accepts the animation float
#init(progress: 0.0)

// 3. Animate "progress" to 1 over a fixed duration (e.g., 2 seconds)
#animate(duration: 5, progress: 1.0)

#import "staleus-diagram.typ": memory-diagram
// 4. Evaluate the context to render each frame
#context {
  // 'progress' will sweep from 0 to 1 over the duration.
  // We set toggle to `false` for the first half, and `true` for the second half.
  let p = a("progress")
  
      memory-diagram(
      fg: fg,
      bg: bg,
      node_bg: node_bg,
      psp_bg: psp_bg,
      cs_bg: node_bg,
      umc_bg: node_bg,
      dirty_bg: dirty_bg,
      progress: p,
    )
}
// 5. Signal the end of the animation
#finish()
