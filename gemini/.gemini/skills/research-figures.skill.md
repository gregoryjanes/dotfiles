---
name: research-figures
description: Produce publication-quality scientific figures - matplotlib (primary), Makie/Plots.jl. Use this skill whenever a plot is destined for a paper, thesis, talk, or poster, and also for everyday research plots of fields, spectra, convergence studies, mode shapes, vortex trajectories, or time series - any time the user asks to "plot", "visualize", or "make a figure" of scientific data.
---

# Research Figures

Defaults for figures that survive peer review. Primary tool: matplotlib; same
principles apply in Makie/Plots.jl.

## Non-negotiables for any figure

- Every axis labeled with quantity AND units or nondimensionalization:
  `x / D`, `t U / L`, `omega L / U` — not bare `x`, `t`.
- Fonts legible at final size: figures sized at the true column width
  (single column ~3.5 in, double ~7 in for most journals; check the target) with
  `fontsize` 8–10 pt at that size — never shrink a huge figure in LaTeX.
- Vector output (`.pdf`) for line plots; high-DPI raster inside vector
  (rasterized pcolormesh, `dpi=300+`) for dense field plots so file sizes stay sane:
  `ax.pcolormesh(..., rasterized=True)`.
- Colorblind-safe colors. Default cycle: matplotlib's `tab10` is acceptable;
  `petroff10` or Paul Tol palettes are better. Never red/green as the only
  discriminator; vary linestyle/marker too so figures survive grayscale printing.
- Legends/annotations must not cover data. Prefer direct labeling on lines when there
  are ≤4 curves.
- The script that makes the figure is committed, reads data from disk (never reruns
  the simulation), and writes to `figures/` with a name matching the script
  (`scripts/fig_energy_spectrum.py -> figures/energy_spectrum.pdf`).

## Style: set once, per project

Create a project `paper.mplstyle` and apply with `plt.style.use(...)` in every figure
script — never per-figure rcParams scattered around. Sensible starting point:

```
figure.figsize: 3.5, 2.6
font.size: 9
axes.labelsize: 9
legend.fontsize: 8
legend.frameon: False
xtick.direction: in
ytick.direction: in
xtick.top: True
ytick.right: True
axes.linewidth: 0.6
lines.linewidth: 1.2
savefig.bbox: tight
savefig.dpi: 300
```

If the document uses LaTeX fonts and the user wants matching typography, prefer
`mathtext` configured to a serif look over `text.usetex=True` (usetex is fragile and
slow); use usetex only on request.

## Plot-type guidance (this research's recurring figures)

**Vorticity / scalar fields**
- `pcolormesh` (with correct cell-edge coordinates) or `contourf`; `imshow` only for
  truly uniform grids and mind `origin='lower'` + `extent`.
- Diverging data (vorticity): diverging colormap (`RdBu_r`) **centered at zero** —
  `norm=mpl.colors.CenteredNorm()` or symmetric `vmin/vmax`. Sequential data (energy,
  speed): perceptually uniform sequential (`viridis`). Never `jet`.
- Equal aspect (`ax.set_aspect('equal')`) for physical domains.
- Comparing fields (FOM vs ROM, time series of frames): SAME color limits across all
  panels, one shared colorbar, and label the colorbar with the quantity.

**Convergence studies**
- log-log error vs. `h`/`dt`/`N`, markers on data points, plus dashed reference-slope
  lines labeled with their order (`O(h^2)`). Annotate the measured order.

**Spectra (energy, singular values, DMD)**
- Singular values / modal energy: `semilogy` vs. index, with the truncation rank
  marked (vertical line) and cumulative-energy twin curve when truncation is the point.
- DMD eigenvalues: unit circle drawn, equal aspect, color/size by mode amplitude;
  or continuous-time plane (growth rate vs. frequency) with the stability boundary.

**Mode shapes**
- Grid of the first `k` modes, shared symmetric color limits *per mode* (modes have
  arbitrary scale — say in the caption that each is normalized), index labels
  ("Mode 1, 34% energy").

**Vortex trajectories**
- Trajectories with time encoded (colormapped line via `LineCollection` or
  start/end markers), equal aspect, circulation sign by color or marker.

**Multi-panel figures**
- `fig, axs = plt.subplots(..., layout='constrained')`; panel labels (a), (b), ... in
  the upper-left of each axes; one shared legend/colorbar where contents repeat.

## Workflow

1. Ask (or infer from context) the destination: paper/thesis (strict sizing, pdf),
   talk (larger fonts, 16:9 friendly, can be png), or working plot (speed over polish).
2. Load data from file; print/echo the provenance metadata stored with it (commit,
   parameters) and put the key parameters in the title for *working* plots (titles are
   usually dropped for paper figures — captions do that job).
3. Build the figure with the project style; save; report the output path and final
   size in inches.
4. For paper figures, also dump a small `figures/<name>.json` (or sidecar comment
   block) recording the data files and parameters used — future-you will be asked by
   a reviewer to change one panel.
