#import "@preview/fletcher:0.5.8": *

// #let tcb-diagram(fg, bg, signed-col, unsigned-col) = {
//   align(center + horizon, diagram({
//     node(stroke: 1pt + fg, width: 8cm, height: 6cm, name: <frame>, "")
//
//     node(
//       (rel: (1cm, -1cm), to: <frame.north-east>),
//       width: 1cm,
//       height: 1cm,
//       stroke: 1pt + fg,
//       fill: signed-col,
//       corner-radius: .2cm,
//       "",
//       name: <signed>,
//     )
//
//     node(
//       (rel: (2.55cm, 0cm), to: <frame.west>),
//       width: 4.2cm,
//       height: 1cm,
//       stroke: 1pt + fg,
//       fill: unsigned-col,
//       "",
//     )
//
//     // node(
//     //   (rel: (2.55cm, 0cm), to: <frame.west>),
//     //   width: 4.7cm,
//     //   height: 1cm,
//     //   stroke: 1pt + fg,
//     //   fill: unsigned-col,
//     //   "",
//     // )
//
//     node((rel: (1.75cm, 0cm), to: <signed>), width: 2.5cm, align(left + horizon, `signed`))
//
//     node(
//       (rel: (0cm, -1.5cm), to: <signed>),
//       width: 1cm,
//       height: 1cm,
//       stroke: 1pt + fg,
//       fill: unsigned-col,
//       corner-radius: .2cm,
//       "",
//       name: <unsigned>,
//     )
//     node((rel: (1.75cm, 0cm), to: <unsigned>), width: 2.5cm, align(
//       left + horizon,
//       `unsigned`,
//     ))
//   }))
// }
#let tcb-diagram(fg, bg, signed-col, unsigned-col) = {
  set text(size: 18pt)
  align(center + horizon, rect(
    stack(
      dir: ltr,
      spacing: 3%,
      stack(
        dir: ttb,
        spacing: 1em,
        `Motherboard Vendor Firmware Image`,

        rect(stroke: 1pt + fg, height: 6cm, width: 10cm, stack(
          dir: ltr,
          spacing: 2%,
          rect(stroke: 1pt + fg, fill: unsigned-col, width: 59%, height: 99%, stack(
            dir: ttb,
            spacing: 5%,
            `UEFI`,
            rect(width: 99%, height: 40%, stroke: 1pt + fg, fill: bg.lighten(10%), `Vendor Code/Coreboot`),
            rect(width: 99%, height: 40%, stroke: 1pt + fg, fill: bg.lighten(10%), `AMD AGESA or openSIL`),
          )),
          stack(
            dir: ttb,
            spacing: 3%,
            rect(
              stroke: 1pt + fg,
              fill: signed-col,
              width: 39%,
              height: 48%,
              `PSP Firmware`
            ),
            rect(
              stroke: 1pt + fg,
              fill: signed-col,
              width: 39%,
              height: 48%,
              `MISC Firmware`
            ),
          ),
        )),
      ),

      align(top + left, rect(stroke: 0pt, stack(
        dir: ttb,
        spacing: 2%,
        v(10%),
        stack(
          dir: ltr,
          spacing: 1%,
          rect(width: 1cm, height: 1cm, stroke: 1pt + fg, radius: .1cm, fill: signed-col),
          align(
            horizon,
            `signed`,
          ),
        ),
        stack(
          dir: ltr,
          spacing: 1%,
          rect(width: 1cm, height: 1cm, stroke: 1pt + fg, radius: .1cm, fill: unsigned-col),
          align(
            horizon,
            `unsigned`,
          ),
        ),
      ))),
    ),
    stroke: 0pt,
  ))
}

