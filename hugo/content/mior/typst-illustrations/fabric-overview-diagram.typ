// Schematic routing view, adapted from the site's Fabricked overview.
#let illustration(fg, bg, node-bg, fabric-bg, good, bad) = {
  set text(font: "DejaVu Sans", size: 10pt, fill: fg)
  let box-at(x, y, w, h, body, fill: node-bg, color: fg) = place(top + left, dx: x, dy: y, rect(
    width: w,
    height: h,
    radius: 5pt,
    fill: fill,
    stroke: color + .8pt,
    align(center + horizon, text(size: 9pt, body)),
  ))
  let label-at(x, y, w, body, color: fg) = place(top + left, dx: x, dy: y, block(width: w, align(center, text(
    fill: color,
    body,
  ))))
  let wire(x, y, dx, dy, color: fg) = place(top + left, dx: x, dy: y, line(end: (dx, dy), stroke: color + 1.4pt))
  let wire-dashed(x, y, dx, dy, color: fg) = place(top + left, dx: x, dy: y, line(
    end: (dx, dy),
    stroke: (paint: color, thickness: 1.5pt, dash: "dashed"),
  ))
  block(width: 13cm, height: 7.5cm)[
    #box-at(2.7cm, .8cm, 7.6cm, 3.6cm, [], fill: fabric-bg)
    #label-at(3cm, 1cm, 5.5cm, [*Infinity Fabric*\ *Data Fabric*])
    #box-at(2.55cm, 5cm, 3.0cm, .7cm, [DRAM], color: good)
    // #wire(4cm, 2.3cm, 0cm, -.4cm, color: good)
    // #wire(4cm, 1.9cm, 5cm, 0cm, color: good)
    // #wire(9cm, 1.9cm, 0cm, -1.2cm, color: good)
    // #wire(2.3cm, 2.8cm, 1cm, 0cm, color: good)
    #wire(2.3cm, 3cm, 1cm, 0cm, color: bad)
    #wire(4.8cm, 3cm, 3.1cm, 0cm, color: bad)
    #wire(9.7cm, 3cm, 1cm, 0cm, color: bad)
    #wire-dashed(4.05cm, 3cm, 0cm, 2cm, color: good)
    // #box-at(0cm, 2.3cm, 2.3cm, 1cm, [CPU cores])
    // #box-at(3.3cm, 2.3cm, 1.5cm, 1cm, [CPU entry])
    #box-at(0cm, 2.4cm, 2.3cm, 1.2cm, [PSP])
    #box-at(3.3cm, 2.4cm, 1.5cm, 1.2cm, [IOMS\ `0x22`], color: bad)
    #box-at(7.9cm, 2.4cm, 1.8cm, 1.2cm, [IOMS\ `0x20`])
    #box-at(10.7cm, 2.4cm, 2.3cm, 1.2cm, [GPU memory], color: bad)
    // #label-at(5cm, 2.3cm, 4.6cm, [Same address → DRAM], color: good)
    #label-at(4.9cm, 2.1cm, 2.9cm, [Redirected MMIO →], color: bad)
    #label-at(4.9cm, 3.4cm, 2.9cm, [← Read-back values], color: bad)
    #label-at(.1cm, 6.1cm, 12.8cm, [Mior changes the PSP’s routing view.])
  ]
}
