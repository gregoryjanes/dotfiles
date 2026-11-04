# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a scientific computing research codebase (PhD research): model reduction, fluid
simulations, and vortex dynamics. **Python is the main driver**; Julia and Fortran are
also used (Fortran typically for performance-critical kernels and legacy solvers).
Correctness of the numerics comes before everything else. Code here supports
publications — results must be reproducible months later, and code must be readable by
scientists first and programmers second.

When starting a task, identify which language applies from the files involved or ask.
Match the conventions of the language and of the surrounding code.

## Skills

Project skills live in `.claude/skills/`. Consult them whenever the task touches their domain:

| Skill | Use when the task involves... |
|---|---|
| `scientific-code-style` | Writing or refactoring numerical code in any language; performance tuning |
| `model-reduction` | POD, DMD, Galerkin projection, ROMs, snapshot data, basis truncation |
| `fluid-sim-verification` | New solvers/discretizations, convergence studies, validating simulation output |
| `vortex-dynamics` | Point vortices, Biot–Savart, vortex sheets/filaments, invariant checks |
| `scientific-ml` | CNNs on simulation data, PINNs, SINDy/system identification, neural ROMs/surrogates |
| `research-figures` | Any plot intended for a paper, talk, or thesis |

## Worktree & Branching Workflow (default)

Unless I say otherwise, follow this for every code-changing task. This is a solo repo with no CI/CD; pushes to the remote are just backups. All review and merging happens locally.

### 1. Start in a new worktree on a new branch

- Never edit directly on `main`. Check with `git branch --show-current` first.
- Create a worktree inside `.worktrees/` with a new branch:
```
git worktree add .worktrees/<short-desc> -b claude/<short-desc> main
```
- `cd` into it and work there. One task = one worktree = one branch.
- After creating the worktree, print its path so I can find it in the VS Code explorer under `.worktrees/`.

### 2. Work and self-review

- Commit in small, focused chunks with clear messages.
- Before declaring done, run the project's tests/linters (e.g. `pytest`, `julia --project -e 'using Pkg; Pkg.test()'`, or the project's `make test`). If unclear what those are, ask.
- Then summarize for me: branch name, worktree path, `git log main..HEAD --oneline`, and `git diff main --stat`. Wait for my approval before merging.

### 3. Merge locally, then push for backup

- From the main repo directory (not the worktree):
```
git checkout main
git merge --no-ff claude/<short-desc>
git push origin main
```
- Then clean up:
```
git worktree remove .worktrees/<short-desc>
git branch -d claude/<short-desc>
```
- No PRs, no tags, no other remote actions.

### 4. Parallel tasks

If I start a second task while another worktree is still open, create a fresh worktree for it rather than reusing one.

### 5. Escape hatches

- If I say "stay on this branch", "work in place", or "quick fix", skip the worktree step.
- If the workflow is blocked (dirty `main`, worktree path exists, branch name taken), stop and tell me before improvising.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- For numerical work specifically: state the governing equations, discretization, and
  boundary/initial conditions you're assuming before writing the solver. A wrong
  assumption here costs days, not minutes.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
- Research code corollary: a plain script that's obviously correct beats a framework.
  Don't build a "general solver interface" when the task is one solver. Generalize on
  the second or third concrete use, never the first.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently. (Especially in Fortran: match
  the existing standard/dialect and fixed/free form; never modernize legacy code unasked.)
- If you notice unrelated dead code, mention it — don't delete it.
- Never silently change numerical parameters (tolerances, timesteps, grid sizes,
  truncation ranks, seeds) while doing something else. If a parameter must change,
  say so and why.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"
- "Implement the integrator" → "Reproduce a known analytical solution to expected order"
- "Build the ROM" → "Report reconstruction/prediction error against the full-order model"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Numerical Correctness

**A simulation that runs is not a simulation that's right.**

- New numerical code is untrusted until checked against something independent:
  an analytical solution, a manufactured solution, a conserved quantity, a published
  benchmark, or a convergence study. Pick the cheapest one that applies and run it.
  The `fluid-sim-verification` skill has the standard procedures and test problems.
- Never compare floats with `==`. Choose tolerances deliberately: discretization-error
  tolerances scale with method order and resolution; round-off tolerances scale with
  machine epsilon and conditioning. Say which regime a tolerance lives in.
- Watch for silent failure modes: catastrophic cancellation, matrices that should be
  symmetric but aren't (symmetrize explicitly), unnormalized bases, drift in long time
  integrations, single/double precision mismatches at language boundaries
  (NumPy `float64` ↔ Fortran `real64` ↔ Julia `Float64` — verify kinds match in interfaces).
- When a result looks surprising (too good, too clean, suspiciously stable), treat it
  as a bug until shown otherwise.

## 6. Reproducibility

**Every figure and result must be regenerable from the repo.**

- Pin environments and commit the pins:
  - Python: work in the project venv/conda env; record exact versions
    (`requirements.txt` with pins, `environment.yml`, or `uv.lock`/lockfile). Never
    `pip install` something without recording it.
  - Julia: always `julia --project`; commit `Project.toml` **and** `Manifest.toml`.
  - Fortran: record compiler, version, and flags (in the Makefile/CMake and the README).
    Flags like `-O3 -ffast-math` change results — they are part of the experiment.
- Seed all randomness explicitly and surface the seed as a named parameter, not a
  buried literal: `numpy.random.default_rng(seed)` (never the legacy global
  `np.random.seed`), `Random.seed!(seed)` in Julia.
- Simulation outputs get saved with their provenance: parameters, grid/resolution,
  solver settings, git commit hash, and date — as attributes in the same file
  (HDF5/NetCDF/JLD2) or an adjacent `params.toml`/`params.json`. A data file with no
  metadata is a future archaeology project.
- Separate the stages: scripts that *run* simulations write data; scripts that *plot*
  read data. Regenerating a figure must never require rerunning a 6-hour simulation.
- Suggested layout for new projects (adapt to what exists — don't reorganize existing
  projects unasked):
```
src/        reusable, tested library code (Python package / Julia module / Fortran sources)
scripts/    runnable entry points (parameter studies, paper figures)
test/       unit + verification tests
data/       simulation outputs (gitignored; small reference data may be committed)
figures/    generated figures (regenerable from scripts/ + data/)
```

## 7. Clean Scientific Code

**Optimize for the reader who knows the math.**

- Mirror the derivation's notation in spelled-out form: if the paper calls it Γ, the
  variable is `gamma`, with a comment naming the symbol, meaning, and units or
  nondimensionalization (`# gamma: circulation Γ [m^2/s]`).
- Docstrings for nontrivial routines state the math: what equation is solved or
  approximated, the discretization/algorithm, and a reference (paper, book, equation
  number) when one exists.
- Comments explain *why* (the numerical or physical reason), not *what* the line does.
  "Subtract mean before SVD so modes are fluctuations about the base flow" is a good
  comment; "compute SVD" is not.
- State the nondimensionalization once, prominently (module docstring or README):
  characteristic length/velocity/time scales and the resulting dimensionless groups.
  All code in that module then works in those units.
- Functions take and return plain, well-named data (arrays, dataclasses/named tuples,
  small structs, derived types). Avoid deep object hierarchies; this is numerical
  code, not enterprise software.

## 8. ASCII-Only Variable Names

**Never use Unicode characters in code identifiers. Write every variable in full English text.**

- `gamma1` not `Γ` or `γ1`
- `delta1` not `δ1`
- `epsilon` not `ε`
- `pi` not `π` (Python: `math.pi`/`np.pi`; Julia: the built-in `pi` constant; Fortran: a named `real64` parameter)
- `nu` not `ν`, `omega` not `ω`, `tau` not `τ`, `kappa` not `κ`
- `alpha`, `beta`, `theta`, etc. — always spelled out

This applies to **every** variable, constant, function argument, struct/derived-type
field, and loop index, in **all** languages used in this project (Python and Julia both
permit Unicode identifiers — do not use them; Fortran forbids them anyway). Unicode is
permitted in comments and docstrings but never in identifiers.

## 9. Performance, Last

**Correct first, fast second, and only when it matters.**

- Don't hand-optimize before a verification test passes and a profile shows the
  hotspot (Python: `cProfile`/`line_profiler`/`py-spy`; Julia: `@profview`,
  `BenchmarkTools.@benchmark`; Fortran: `gprof`/`perf`).
- The standard per-language optimization checklists (vectorization, type stability,
  allocations, array ordering, contiguity) live in the `scientific-code-style` skill.
- Never trade verifiable correctness for speed silently. If an optimization changes
  results beyond round-off (`-ffast-math`, `@fastmath`, lower precision, looser solver
  tolerances), flag it and quantify the difference.

## 10. Language Conventions: Good vs. Bad

Short reference examples. The `scientific-code-style` skill has the full versions.

### Python (main driver)

**Bad** — element-wise loops over NumPy arrays, hidden global RNG, magic numbers, no provenance:
```python
def step(w):
    out = []
    for i in range(len(w)):                 # Python-level loop over array: ~100x slower
        out.append(w[i] + 0.01 * rhs(w[i])) # 0.01 = unnamed timestep buried in code
    np.random.seed(0)                        # legacy global seed, hidden side effect
    return np.array(out) + np.random.randn(len(w)) * 1e-6
```

**Good** — vectorized, parameters explicit, RNG passed in, documented math:
```python
def step_euler(omega: np.ndarray, dt: float, nu: float) -> np.ndarray:
    """Advance vorticity one explicit-Euler step of d(omega)/dt = rhs(omega; nu).

    First-order accurate in time; stable for dt below the diffusive limit
    dt < dx^2 / (4 nu) on a uniform grid.
    """
    return omega + dt * rhs(omega, nu)      # whole-array op, no Python loop

rng = np.random.default_rng(seed=cfg.seed)  # seeded generator passed explicitly
```

Also: type-hint public function signatures; use `dataclass` (or a dict loaded from
`params.toml`) for parameter sets instead of long positional argument lists; never
use mutable default arguments; prefer `np.einsum`/BLAS-backed ops over hand loops;
when a loop is unavoidable and hot, that's the cue for Numba/Cython/f2py — ask first.

### Julia

**Bad** — untyped globals, abstractly-typed containers, allocation inside hot loop:
```julia
dt = 0.01                          # untyped global: kills performance of any loop using it
state = []                         # Vector{Any}: type-unstable
for n in 1:nsteps
    state = state + dt * rhs(state)   # allocates a new array every step
end
```

**Good** — work happens inside a function, concrete types, in-place updates:
```julia
function integrate!(omega::Vector{Float64}, dt::Float64, nsteps::Int)
    domega = similar(omega)            # one scratch buffer, reused
    for n in 1:nsteps
        rhs!(domega, omega)            # in-place RHS, no per-step allocation
        @. omega += dt * domega        # fused broadcast, updates in place
    end
    return omega
end
```

Also: pass parameters as function arguments or a struct, never via globals (or mark
`const`); check hot code with `@code_warntype` for type instabilities; use `@views`
for slices in hot loops; remember Julia is column-major — inner loop over the first
index.

### Fortran

**Bad** — implicit typing, no intents, default-real literals silently single precision:
```fortran
subroutine advect(w, n)
    dimension w(n)              ! implicit typing: w is REAL(4), i,j are INTEGER by accident
    dt = 1e-3                   ! single-precision literal
    do i = 1, n
        w(i) = w(i) + dt*f(w(i))
    end do
end
```

**Good** — `implicit none`, explicit kinds, intents, assumed-shape arrays:
```fortran
subroutine advect(omega, dt)
    use, intrinsic :: iso_fortran_env, only: dp => real64
    implicit none
    real(dp), intent(inout) :: omega(:)   ! assumed-shape: size travels with the array
    real(dp), intent(in)    :: dt
    integer :: i
    do i = 1, size(omega)
        omega(i) = omega(i) + dt * rhs(omega(i))
    end do
end subroutine advect
```

Also: every literal in `real(dp)` context gets a kind suffix (`1.0_dp`, not `1.0`);
`intent` on every dummy argument; modules instead of bare external subroutines and
COMMON blocks (in new code only — match legacy style when editing legacy files);
Fortran is column-major like Julia — inner loop over the first index; when wrapping
for Python, define the interface with `iso_c_binding` or f2py and verify kind/dtype
agreement with an explicit round-trip test.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, clarifying questions come before implementation rather than after mistakes, and no result ever has to be retracted because it couldn't be reproduced or verified.

## This Project

<!-- Per-project notes go here: governing equations, nondimensionalization, key
     entry points in scripts/, how to run the test suite, compiler/cluster notes, etc. -->
