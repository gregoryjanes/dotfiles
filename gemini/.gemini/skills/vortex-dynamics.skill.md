---
name: vortex-dynamics
description: Implement and verify vortex-system computations - point vortices, vortex patches, sheets, filaments, Biot-Savart velocity evaluation, vortex methods. Use this skill whenever the task involves vortex positions/circulations, induced velocities, vortex interactions (merging, leapfrogging, co-rotation), Hamiltonian/invariant checks for vortex systems, desingularization/regularization kernels, or time integration of vortex trajectories - even if the user just says "simulate N vortices" or "track the vortices in this flow".
---

# Vortex Dynamics

Conventions, equations, invariants, and verification cases for vortex-system code.
Implementation style per `scientific-code-style`; general V&V per `fluid-sim-verification`.

## Conventions to state up front (and never mix)

- Sign: positive circulation `gamma` = counter-clockwise (standard right-handed).
- 2D point vortex induced velocity at `z` from vortex at `z0` (complex form):
  `conj(w) = gamma / (2 pi i (z - z0))`, i.e. in components
  `u = -gamma/(2 pi) * dy / r^2`, `v = gamma/(2 pi) * dx / r^2`, with `dx = x - x0`,
  `r^2 = dx^2 + dy^2`. Off-by-`2 pi` and sign-flip bugs are the two most common
  vortex-code errors — write one induced-velocity function, test it in isolation
  against a hand-computed value, and call it everywhere.
- Self-induction excluded for point vortices (`i != j` in the double loop).
- State the domain: unbounded plane, periodic (use the proper periodic kernel —
  cotangent kernel in singly-periodic, Weierstrass/Ewald-type sums in doubly-periodic),
  or bounded (image vortices / boundary elements). Free-space kernels in a periodic
  box is a silent correctness bug.

## Invariants (2D point vortices, unbounded domain)

For circulations `gamma_i` at positions `(x_i, y_i)`:
- Hamiltonian (interaction energy):
  `H = -(1/(4 pi)) * sum_{i<j} gamma_i gamma_j log(r_ij^2)` — conserved.
- Linear impulse: `P = sum_i gamma_i (y_i, -x_i)` components `Q = sum gamma_i x_i`,
  `P = sum gamma_i y_i` — conserved.
- Angular impulse: `I = sum_i gamma_i (x_i^2 + y_i^2)` — conserved.
- Total circulation `sum gamma_i` — trivially conserved; in periodic domains it must
  be zero for a well-posed problem (check and error early).

**Every vortex simulation logs these invariants** and the test suite asserts their
drift over a reference run is below an integrator-appropriate bound. Invariant drift
is the single most sensitive bug detector for this class of code.

## Time integration

- Default: classic RK4 with fixed `dt` chosen so invariant drift over the run time is
  acceptable; verify 4th-order convergence of invariant drift and trajectory error
  with `dt`.
- For long-time statistics / near-integrable studies: the point-vortex system is
  Hamiltonian (but NOT in canonical (x_i, y_i) pairs unless rescaled by gamma_i —
  canonical coordinates are `(x_i * gamma_i, y_i)` up to convention). Adaptive
  high-order (e.g. DOP853 via `solve_ivp` with tight rtol/atol ~ 1e-10) is usually the
  pragmatic choice; true symplectic schemes need the canonical structure handled
  correctly — flag the subtlety rather than bolting on leapfrog (which is symplectic
  for separable Hamiltonians only; the vortex Hamiltonian is not separable).
- Close approaches: `dt` requirements explode as `r_ij -> 0`. Use adaptive stepping or
  detect-and-warn; for true collisions/merger physics, point vortices are the wrong
  model — say so.

## Regularized / desingularized models

- Vortex blobs: replace the singular kernel, e.g. Krasny-delta `r^2 -> r^2 + delta^2`
  (vortex sheets), or a Gaussian/Lamb–Oseen core
  `u_theta = gamma/(2 pi r) * (1 - exp(-r^2 / (2 sigma^2)))` (physical core model).
  Name the kernel and its parameter explicitly in code and outputs; results depend on
  it and reviewers will ask.
- Convergence in `delta` (or core size) is a separate study from convergence in `dt`
  and in number of elements `N` — three independent refinement axes for vortex-sheet /
  vortex-method computations. Don't conflate them.
- N-body cost: direct summation is `O(N^2)`. Fine to ~10^4 vortices in compiled code
  (NumPy-vectorized pairwise differences OK to a few thousand; beyond that Numba /
  Fortran kernel). Past that, treecode/FMM — suggest an existing library before
  writing one.

## Verification cases (exact solutions to test against)

| Case | Exact behavior |
|---|---|
| Single vortex + tracer | tracer circles at radius `r` with period `T = 4 pi^2 r^2 / gamma` |
| Equal co-rotating pair (`gamma, gamma`, separation `d`) | rigid rotation about midpoint, period `T = 2 pi^2 d^2 / gamma` |
| Counter-rotating pair (`gamma, -gamma`, separation `d`) | translates at speed `U = gamma/(2 pi d)`, fixed `d` |
| Three equal vortices, equilateral | rigid rotation, configuration preserved |
| Collinear configurations / known relative equilibria | rotate rigidly; eigen-perturbation growth matches linear theory |
| Leapfrogging pairs | periodic leapfrog for separation ratio within the known stability range |
| 4+ identical vortices | chaotic — use ONLY invariant drift, not trajectories, as the test metric |

Tests assert trajectory error vs. these solutions converges at the integrator's order,
plus invariant drift bounds. For chaotic regimes, trajectory comparison is meaningless
beyond a Lyapunov time — compare invariants and statistics instead, and say so in the
test comments.

## Vorticity-field interplay (grid <-> vortices)

When extracting "vortices" from simulation fields (the tracking use case):
- Detection: local extrema of vorticity above a stated threshold, or lambda2 / Q /
  swirling-strength criteria for ambiguous shear-dominated regions — name the
  criterion and threshold in code and figure captions.
- Vortex center: vorticity-weighted centroid over the core region beats the raw
  grid-point maximum (sub-grid accuracy); circulation by integrating vorticity over
  the core area (state the boundary definition: threshold contour vs. fixed radius).
- Track identity across frames by nearest-neighbor in position with a max-jump
  gate tied to expected advection per frame; log births/deaths/merges explicitly.
