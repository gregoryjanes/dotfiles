---
name: scientific-ml
description: Machine learning for scientific problems - CNNs on simulation fields, physics-informed neural networks (PINNs), sparse regression / system identification (SINDy and variants), neural ROMs and autoencoders, neural operators. Use this skill whenever the task involves training a neural network on simulation or experimental data, building or debugging a PINN, discovering governing equations from data, ML surrogates for fluid flows, or any PyTorch/JAX/Flux code in a scientific context - even if the user just says "learn a model from this data", "the network won't converge", or "fit the dynamics".
---

# Scientific Machine Learning

CNNs, PINNs, SINDy, and the discipline around them. Default stack: PyTorch (Python is
the main driver); PySINDy for system identification; JAX or Julia (Lux/SciML) when the
user asks. Code style per `scientific-code-style`; figures per `research-figures`.

## Ground rules (these prevent retracted results)

1. **A baseline before a network.** Every learned model is compared against the best
   cheap classical alternative: POD with the same latent dimension for autoencoders,
   linear/persistence prediction for forecasting, a standard numerical solver for
   PINNs, least squares for regression. If the network doesn't beat the baseline,
   that IS the result — report it, don't tune it away silently.
2. **Splits that respect physics.** Random shuffling of snapshots from one trajectory
   leaks information (adjacent-in-time samples are nearly identical). Split by time
   block (train on `t < T1`, test on `t > T2`), by trajectory, or by parameter value
   (held-out Reynolds numbers) — and state which generalization claim the split
   supports (interpolation vs. extrapolation in time/parameters).
3. **Reproducibility.** Seed everything (`torch.manual_seed`, `np.random.default_rng`,
   dataloader `generator=`); save with every checkpoint: full config (a dataclass or
   yaml/toml — no argparse defaults hidden in code), git commit, dataset
   identity/normalization constants, and the train/val curves. Note: exact bitwise
   reproducibility on GPU additionally needs `torch.use_deterministic_algorithms(True)`
   and costs speed — record seeds and report run-to-run spread instead, training
   ≥3 seeds for any number that goes in a paper (mean ± std, not the best run).
4. **Normalize in physical awareness.** Standardize inputs/outputs per channel and
   store the constants with the model (they are part of the model). Losses reported
   to the user should be converted back to physical, interpretable errors (relative
   L2 in the flow norm), not raw MSE on normalized data.
5. **Training loop hygiene**: validation metric ≠ training loss; early stopping or
   checkpoint-best-on-val; log to a simple CSV/JSON per run (a `runs/<timestamp>_<tag>/`
   directory with config + metrics + checkpoints beats a heavyweight tracker for solo
   research; suggest W&B/MLflow only if the user wants it); plot train+val curves at
   the end of every training session, always.

## CNNs on simulation fields

- Data layout: PyTorch is `(N, C, H, W)`. Map physics to channels explicitly
  (`C=2` for (u, v), `C=1` for vorticity) and document the (H, W) ↔ (y, x) orientation
  once — silent transposes between NumPy meshgrid conventions and image conventions
  are the #1 bug in this pipeline. Write a shape/orientation unit test (a field with
  a known asymmetric feature, assert it lands where expected).
- **Boundary handling must match the domain**: `padding_mode='circular'` for periodic
  domains (default zero-padding injects spurious walls); for wall-bounded flows,
  reflect/replicate is still wrong physics at the wall — note the choice and keep
  boundaries out of the loss or weight them deliberately.
- Respect the grid: pooling/strided convs assume uniform grids. Non-uniform or
  unstructured data → interpolate to uniform (document the interpolation) or use
  graph/point-based architectures — flag the issue instead of silently pretending.
- Convolutional autoencoders for ROM: report reconstruction error vs. latent dim
  **on the same plot as POD** at equal latent dims (POD is the linear optimum; the
  network must beat it to justify itself). Check latent-space smoothness over time —
  jagged latent trajectories make downstream dynamics learning miserable.
- Loss design: plain MSE underweights small scales; if gradients/small scales matter,
  add a gradient (Sobolev) term or spectrum comparison in evaluation. Always *evaluate*
  with physical metrics regardless of the training loss: energy spectra, divergence of
  predicted velocity fields, invariants.
- Periodic-domain alternative: for data on periodic boxes, mention Fourier Neural
  Operators (FNO, `neuraloperator` package) as the standard strong baseline before a
  bespoke CNN.

## PINNs

Be honest about when they help: PINNs are typically NOT competitive with classical
solvers for clean forward problems on simple domains. Their value is inverse problems,
data assimilation (sparse/noisy measurements + physics), unknown parameters, and
mesh-free settings. If the user is solving a clean forward PDE that a spectral/FD
solver handles, say so before building the PINN.

- Architecture/defaults that work: MLP with `tanh` (NOT ReLU — its second derivative
  is zero a.e., killing PDE residuals of 2nd-order operators), Glorot init, Adam
  (~1e-3, decay) then optionally L-BFGS to polish. Inputs scaled to O(1) — e.g. map
  (x, t) to [-1, 1]; unscaled coordinates are a classic silent failure.
- Derivatives via autodiff (`torch.autograd.grad(..., create_graph=True)`) — never
  finite differences on network outputs. Verify the residual implementation by
  plugging in a known analytical solution: residual must be ~0 before any training.
  This single check catches most PINN bugs.
- Loss = weighted sum of PDE residual + BC + IC + data terms. Loss balancing is THE
  central practical problem: start with manual weights chosen so initial loss terms
  are comparable magnitude; if training stalls, try hard-enforcing BCs/ICs by output
  transformation (e.g. `u = u0(x) + t * net(x, t)` bakes in the IC exactly — removes
  a competing loss term entirely; prefer hard enforcement when geometry allows),
  then adaptive schemes (gradient-norm/NTK balancing, self-adaptive weights).
- Collocation: resample or use plenty of residual points; for advection-dominated or
  long-time problems, expect failure modes (spectral bias toward smooth solutions,
  propagation failure from the IC) — mitigate with time-marching / sequential training
  over windows, causal weighting, or Fourier feature embeddings for high-frequency
  solutions.
- Validation: ALWAYS against a reference numerical solution (or manufactured
  solution) on the same problem; report relative L2 error over the domain and its
  growth in time — a low training loss with a wrong solution is common (residual can
  be small for the wrong function). Treat the PINN as an untrusted solver per
  `fluid-sim-verification`.
- Inverse problems: unknown parameters (`nu`, source terms) as trainable tensors;
  report recovered values with sensitivity to noise (rerun across noise seeds).

## SINDy / system identification

- Pipeline: (1) get clean derivatives, (2) build a candidate library, (3) sparse
  regression, (4) validate by SIMULATING the discovered model — never judge by
  residual fit alone.
- **Derivatives dominate everything.** From noisy data, raw finite differences destroy
  SINDy. Use smoothed FD, Savitzky-Golay, total-variation regularized differentiation,
  or weak/integral-form SINDy (best for noise — no pointwise derivatives at all;
  PySINDy: `WeakPDELibrary`). Plot the estimated derivatives before regressing.
- Library: start small and physically motivated (polynomials to the degree the physics
  suggests, trig terms if rotational). Nondimensionalize/normalize state variables
  first — wildly different scales wreck thresholding. Record library + normalization
  with the result; coefficients are meaningless without them.
- Regression: STLSQ with a threshold scan — sweep the threshold and plot the Pareto
  front (number of terms vs. error); pick the knee, don't cherry-pick a single
  threshold. Ensemble SINDy (bagging) for noise robustness and coefficient error
  bars.
- Validation: simulate the identified ODE/PDE from held-out initial conditions and
  compare trajectories (short-time) and attractor/statistics (long-time, if chaotic —
  trajectory match is meaningless past a Lyapunov time, compare invariant measures /
  spectra instead). Check structural stability: does the same model emerge from
  different data segments / noise realizations?
- For ROM + SINDy (latent dynamics of POD/autoencoder coordinates): the latent
  trajectory must be smooth and the truncation adequate, else the "dynamics" being
  fit don't close — check the projection error first (see `model-reduction`).
- Use PySINDy rather than reimplementing (it has STLSQ, SR3, ensemble, weak form,
  PDE-FIND); hand-roll only for pedagogy or research on the method itself.

## Choosing between the tools (quick router)

| Goal | Reach for |
|---|---|
| Compress fields / nonlinear ROM basis | Conv autoencoder (vs POD baseline) |
| Forecast latent / low-dim dynamics | SINDy on latent coords; neural ODE if SINDy library fails |
| Interpretable governing equations from data | SINDy (weak form if noisy) |
| Sparse/noisy measurements + known physics | PINN (data assimilation mode) |
| Unknown coefficients in known PDE | PINN inverse, or SINDy with restricted library |
| Fast surrogate for parametrized PDE solves | FNO / neural operator, or POD-Galerkin if linear-ish |
| Clean forward solve of a standard PDE | A classical solver. Not ML. |

## Reporting results (papers/thesis)

- Error bars over ≥3 seeds; specify split protocol; baseline in every table/plot.
- State compute honestly (GPU type, wall time, epochs) alongside any speedup claim,
  and include offline training cost when claiming surrogate speedups.
- Save the exact checkpoint + config that produced each figure (`figures/<name>.json`
  provenance sidecar, per `research-figures`).
