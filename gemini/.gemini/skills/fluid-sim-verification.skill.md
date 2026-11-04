---
name: fluid-sim-verification
description: Verification and validation procedures for fluid/PDE solvers and numerical integrators. Use this skill whenever the task involves writing a new solver or discretization, checking that simulation code is correct, convergence/grid-refinement studies, the method of manufactured solutions, conservation checks, choosing test tolerances for numerics, debugging a simulation that blows up or drifts, or picking benchmark problems (Taylor-Green, Lamb-Oseen, lid-driven cavity, etc.). Trigger this even when the user only says "test my solver", "is this right?", or "why is my simulation unstable?".
---

# Fluid Simulation Verification & Validation

Verification = solving the equations right. Validation = solving the right equations.
This skill is mostly verification, which is what code work can settle.

## The cheapest-sufficient-check ladder

For any new numerical code, pick the *cheapest* check that applies and implement it as
a permanent test, not a one-off:

1. **Exact analytical solution** — best when available (see benchmark table below).
2. **Method of manufactured solutions (MMS)** — always available for PDE code:
   choose a smooth `u_exact(x, t)` (sines/cosines, nonzero in every term), substitute
   into the PDE to get a source term `s = L(u_exact)` (use sympy to derive it —
   hand-derived MMS sources are the #1 source of MMS bugs), run the solver with that
   source, and check convergence of the error to `u_exact`.
3. **Conserved quantities** — energy, circulation, mass/divergence, impulse;
   monitor drift over the run.
4. **Published benchmark** — compare to tabulated values (cavity centerline profiles,
   Strouhal numbers).
5. **Regression test** — last resort, catches changes but not original bugs: store a
   checksummed reference output at fixed resolution/seed.

## Convergence (order-of-accuracy) studies — the gold standard

Procedure:
1. Pick a problem with a known/manufactured solution.
2. Run at 4+ resolutions, halving `h` (or `dt`) each time. Refine ONE thing at a time:
   to test spatial order, make temporal error negligible (tiny `dt` or exact time
   dependence), and vice versa. For coupled refinement, scale `dt ~ h^(p_space/p_time)`.
3. Compute error norms against the exact solution (report L2 and Linf; they can
   disagree, and Linf catches localized bugs like boundary stencils).
4. Observed order `p = log2(e_h / e_{h/2})`. It must approach the theoretical order in
   the asymptotic range.
5. Plot log-log error vs. h with a reference slope line; save as a test artifact.

Interpreting failures:
- Order ≈ theoretical − 1: usually a boundary stencil or ghost-cell bug, or
  inconsistent treatment of one term.
- Order ≈ 1 regardless of scheme: a first-order error somewhere dominates (often time
  integration or an interpolation step).
- Error plateaus at fine resolution: round-off floor (expected; `~eps * conditioning`)
  or an iterative solver tolerance that's now larger than discretization error —
  tighten it.
- Order erratic / no clean slope: not in the asymptotic range (refine more) or the
  exact solution isn't smooth enough.

Automate it: the convergence study should be a script/test (`test/test_convergence_*`)
asserting `p > p_theory - 0.2` (tolerance on the order itself), not a notebook ritual.

## Standard benchmark problems

| Problem | Exact? | Tests | Notes |
|---|---|---|---|
| 1D/2D advection of a smooth pulse | Yes | advection schemes, dissipation/dispersion | period-exact return |
| 1D heat equation, sine IC | Yes | diffusion, time integrator | `u = exp(-nu k^2 t) sin(kx)` |
| 2D Taylor–Green vortex | Yes (2D, decaying) | full incompressible NS, pressure coupling | exact decay rate `exp(-2 nu k^2 t)` |
| Lamb–Oseen vortex | Yes | viscous vortex dynamics, far-field BCs | self-similar spreading core |
| Lamb dipole | Yes (steady, translating) | nonlinear advection + structure preservation | translates at constant speed |
| Lid-driven cavity (Re 100, 400, 1000) | Tabulated (Ghia et al. 1982) | steady NS, BCs, solver robustness | compare centerline u, v profiles |
| Cylinder wake (Re ~100) | Tabulated | unsteady NS | Strouhal ≈ 0.16–0.17, mean Cd ≈ 1.3–1.4 |
| Inviscid point-vortex configs | Yes | see `vortex-dynamics` skill | co-rotating pair, leapfrogging rings |

## Conservation & sanity monitors

Build these into the simulation loop (cheap, every-N-steps, logged with the output):
- Incompressible: max divergence of velocity (should sit at solver tolerance level).
- Kinetic energy: must decay monotonically for unforced viscous flow; for inviscid
  spectral/energy-conserving schemes, drift should be at round-off-accumulation level.
- Circulation / total vorticity in 2D periodic domains: conserved to round-off.
- CFL number each step (or adaptively set `dt` from it); log the max.
- NaN/Inf check: fail fast with the step number and location, don't write garbage data.

A run that violates its monitors should be treated as invalid even if it "looks fine".

## Debugging instability ("my simulation blows up")

Check in this order:
1. CFL: advective `|u| dt / dx` and diffusive `nu dt / dx^2` against the scheme's
   stability limits. The diffusive limit bites first on fine grids with explicit schemes.
2. Boundary conditions: most instabilities start at boundaries — plot the field near
   them just before blow-up; check ghost values and corner treatment.
3. Aliasing (spectral/pseudo-spectral): is dealiasing (2/3 rule or padding) applied to
   the nonlinear term?
4. Pressure–velocity coupling (incompressible): projection actually enforcing
   divergence-free? Checkerboard modes (collocated grids without Rhie–Chow)?
5. Reduce the problem: turn off terms one at a time (nonlinear term off → still
   unstable means diffusion/BC bug), drop to 1D, drop to linear.
6. Precision: confirm everything is double; check for a stray single-precision
   constant or array (esp. at Fortran/Python interfaces).

## Tolerances for tests

- Round-off-level checks (orthonormality, conservation per step, interface
  round-trips): `atol ~ 100 * eps * scale`, where scale reflects problem size/conditioning.
- Discretization-level checks (solution vs. exact): tolerance from the measured
  convergence curve at that resolution, with ~2x headroom — written in a comment next
  to the number.
- Never `assert error < 1e-6` with no justification; never compare floats with `==`.

## Validation (against physical reality)

When the user asks to compare with experiments/published DNS: plot overlays with the
reference data (digitized or tabulated), report quantitative metrics the community
uses for that flow (Strouhal, drag/lift coefficients, growth rates, spectra), and be
explicit about what differs between the setups (Re, domain size, BCs, 2D vs 3D) before
attributing discrepancies to the code.
