---
name: model-reduction
description: Build, validate, and debug reduced-order models (ROMs) of fluid and dynamical systems. Use this skill whenever the task involves POD/PCA of simulation data, DMD and its variants, Galerkin or Petrov-Galerkin projection, balanced truncation, operator inference, snapshot matrices, modal energy spectra, basis truncation choices, or evaluating ROM accuracy against a full-order model — even if the user just says "reduce this model", "find the dominant modes", or "compress this simulation data".
---

# Model Reduction

Workflow, conventions, and pitfalls for projection-based and data-driven ROMs.
Language-agnostic; apply `scientific-code-style` for the implementation language.

## Conventions (state them, then stick to them)

- **Snapshot matrix**: `X` of shape `(n_dof, n_snapshots)` — columns are snapshots.
  Many Python codebases use rows-as-samples (scikit-learn convention); say explicitly
  which one the code uses and keep it uniform per project.
- **Mean handling**: subtract the temporal mean (or a base flow) before POD unless the
  user says otherwise, and store the mean with the basis — reconstruction needs it.
  Say which choice was made; mode 1 of un-centered data is mostly the mean flow.
- **Inner product**: POD optimality is defined w.r.t. an inner product. On non-uniform
  grids or for energy-based truncation, use the mass/quadrature-weighted inner product
  `<u, v> = u' W v` (Cholesky trick: POD of `L' X` where `W = L L'`), not the plain
  Euclidean one. On uniform grids, plain works but say so.
- Always work from saved snapshot data on disk (HDF5 etc.), not by rerunning the
  simulation inside the ROM script.

## POD

- Compute via thin SVD of the (centered, weighted) snapshot matrix: `U, S, Vt = svd(X)`.
  Don't form the covariance `X X'` (squares the condition number). For `n_dof >>
  n_snapshots`, the method of snapshots (eigendecomposition of the small `X' X`
  Gramian) is fine — but randomized SVD is usually simpler and just as fast.
- For `n_dof` too big for memory: randomized SVD (`sklearn.utils.extmath.randomized_svd`
  or hand-rolled with oversampling + power iterations) on memmapped/chunked data.
- **Truncation rank `r`**: report the singular value spectrum and cumulative energy
  `sum(S[1:r].^2) / sum(S.^2)`. Common thresholds: 99%, 99.9% — but plot the spectrum;
  a slow decay (transport/advection-dominated problems) is a warning that linear
  subspaces will struggle. Surface that warning to the user rather than silently
  picking a huge `r`.
- Sanity checks after computing a basis:
  - Orthonormality: `norm(Phi' W Phi - I)` at round-off level.
  - Reconstruction error vs. `r` on the training snapshots (relative, in the chosen norm).
  - Visualize the first few modes — they should look physical, not like noise.

## DMD

- Standard (exact) DMD: split snapshots into `X1 = X[:, 1:end-1]`, `X2 = X[:, 2:end]`;
  thin SVD of `X1`; build the reduced operator `Atilde = U' X2 V inv(S)`; eigendecompose;
  lift eigenvectors (exact modes use `X2 V inv(S) W_eig`).
- **Uniform sampling interval `dt` is required**; convert discrete eigenvalues to
  continuous rates via `log(lambda)/dt`. Plot eigenvalues against the unit circle —
  spurious strongly-damped or unstable modes usually mean rank truncation or noise
  issues.
- Truncate the SVD before building `Atilde` — full-rank DMD on noisy data overfits.
- Know the variants and when to suggest them: total-least-squares DMD (sensor noise on
  both X1 and X2), optimized DMD (BOPDMD, robust to noise + non-uniform sampling),
  DMDc (with control inputs), mrDMD (multiresolution/transients). For Python, PyDMD
  implements most of these — prefer it over reimplementation unless the point is
  pedagogy or the case is simple.
- Verify on synthetic data first: a sum of 2–3 known damped oscillators; recovered
  eigenvalues must match to tight tolerance before touching real flow data.

## Galerkin projection ROMs

- Project the FOM operators, not the equations-by-hand when avoidable: for a system
  `du/dt = A u + H (u ⊗ u) + f`, the ROM operators are `Ar = Phi' A Phi`,
  `Hr = Phi' H (Phi ⊗ Phi)` (precompute these once, offline), `fr = Phi' f`.
- Cost discipline: ROM online cost must be independent of `n_dof`. If evaluating the
  ROM RHS touches a full-order array, the offline/online split is broken — fix it
  (precompute projected tensors, or hyper-reduction: DEIM/gappy POD for general
  nonlinearities).
- Include the mean-flow contribution terms when the basis is built from centered data
  (they generate constant and linear terms in the ROM — a classic missed-term bug).
- Stability: Galerkin ROMs of advection-dominated flows often blow up at modest `r`.
  Standard responses, in escalating order: include more modes, add eddy-viscosity-style
  closure, use an energy-stable inner product, or move to Petrov-Galerkin (LSPG).
  Don't band-aid with artificial damping without flagging it.

## Operator inference / data-driven alternatives

When FOM operators aren't accessible (black-box or legacy Fortran solver), suggest
operator inference: least-squares fit of reduced operators to projected snapshot time
derivatives. Regularize (Tikhonov) and report the residual; check the recovered
operators reproduce training trajectories before trusting prediction.

## Evaluating any ROM (the non-negotiables)

1. **Train/test split in time or parameters.** Reconstruction error on training data
   is not evidence of a good ROM. Report:
   - Projection error (best possible with this basis) — the floor.
   - ROM error (actual time-integration of the ROM) — the achieved.
   The gap between them is the ROM's fault; the floor is the basis's fault.
2. Relative error in the proper norm: `norm(u_rom - u_fom) / norm(u_fom)` over time;
   plot error growth vs. time, not just one number.
3. Compare ROM-predicted invariants/physics (energy, dominant frequency, vortex
   trajectories) against the FOM — these reveal failure modes that L2 error hides.
4. Report wall-clock speedup honestly: online ROM time vs. FOM time, excluding
   offline cost, and state the offline cost separately.
