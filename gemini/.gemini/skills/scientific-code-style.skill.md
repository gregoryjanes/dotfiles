---
name: scientific-code-style
description: Patterns for clean, correct, fast numerical code in Python, Julia, and Fortran. Use this skill whenever writing or refactoring numerical/scientific code in any of these languages — solvers, time integrators, linear algebra, array kernels — and whenever the user asks to speed code up, reduce allocations, vectorize, profile, or wrap Fortran for Python. Also use when reviewing scientific code for quality.
---

# Scientific Code Style

Cross-language rules first, then per-language sections. Read the section for the
language(s) actually in play.

## Cross-language rules

1. **Correct, then clear, then fast — in that order.** Never optimize code that has no
   passing verification test (see `fluid-sim-verification` skill).
2. **ASCII identifiers, spelled-out Greek** (`gamma`, `omega`, `nu`...). Comment maps
   the name to the symbol and its units/nondimensionalization.
3. **Docstrings state the math**: the equation solved, the method, its order of
   accuracy, and a citation (book/paper + equation number) when one exists.
4. **Parameters travel together and explicitly**: a dataclass / struct / derived type
   (or a loaded `params.toml`), not loose globals or 12 positional arguments.
5. **Double precision by default.** Mixed or reduced precision only as a deliberate,
   flagged decision.
6. **Memory layout awareness**: NumPy defaults to row-major (C order); Julia and
   Fortran are column-major. Inner loops iterate the fast index. At interfaces,
   transposes/copies must be explicit and tested.
7. **Hot-loop hygiene** (all languages): hoist invariants out of loops, preallocate
   and reuse buffers, avoid temporaries in the inner loop, prefer BLAS-backed
   operations for dense linear algebra.

## Python

The main driver language. Default stack: NumPy + SciPy + matplotlib; xarray/h5py for
data; pytest for tests.

### Idioms
- Vectorize with whole-array operations, broadcasting, and `np.einsum`. A Python-level
  `for` over array elements in a hot path is a bug-in-waiting (~10–100x slowdown).
- Random numbers: `rng = np.random.default_rng(seed)`, pass `rng` down. Never the
  legacy global `np.random.seed`/`np.random.randn`.
- Type-hint public signatures (`np.ndarray`, shapes in the docstring:
  `omega : (ny, nx) ndarray`).
- `@dataclass(frozen=True)` for parameter sets; load from `params.toml` with `tomllib`.
- No mutable default arguments. No bare `except:`. Don't catch exceptions you can't
  handle — let numerical errors surface.
- SciPy before hand-rolling: `scipy.linalg` (prefer over `numpy.linalg` — more
  routines, e.g. `lu_factor`, `solve_banded`, `svdvals`), `scipy.sparse`,
  `scipy.integrate.solve_ivp`, `scipy.fft`.
- For `solve_ivp`, set `rtol`/`atol` deliberately and state why; defaults (1e-3) are
  far too loose for most research use.

### Performance path (in order)
1. Profile: `cProfile` + `snakeviz`, or `py-spy` for running processes;
   `line_profiler` for a known-hot function.
2. Better NumPy: remove Python loops, fuse with `einsum`, use in-place ops
   (`out=` arguments, `+=`), avoid fancy-indexing copies where views suffice.
3. If a loop is irreducible: Numba `@njit` (first choice for array kernels — minimal
   code change), or move the kernel to Fortran/f2py if it already exists there.
   Confirm with the user before adding a compiled dependency.
4. Check memory: `float64` arrays of (nt, ny, nx) snapshots get large fast; consider
   `np.memmap`/h5py chunked reads for snapshot matrices that exceed RAM.

### Testing
- pytest; numerical comparisons with `np.testing.assert_allclose(actual, expected,
  rtol=..., atol=...)` — choose tolerances from the method's expected error, and say
  so in a comment.
- Property checks are cheap and powerful: conservation, symmetry, known limits
  (`nu -> 0`, single-vortex case, etc.).

## Julia

### Idioms
- All real work inside functions — never in global scope. Untyped globals destroy
  performance; if a global is unavoidable, make it `const` or type-annotate it.
- Concrete container types: `Vector{Float64}`, `Matrix{ComplexF64}` — never `[]`
  (which is `Vector{Any}`) for numerical data.
- In-place convention: mutating functions end with `!` and take the output first
  (`rhs!(domega, omega, params)`). Provide in-place versions of hot kernels.
- Fused broadcasting `@.` for element-wise updates; `@views` (or `view(...)`) for
  slices in hot loops — bare slices copy.
- Column-major: inner loop over the first index; `eachindex`/`axes` over manual
  `1:length`.
- Multiple dispatch over `if`-type-checking; small structs for parameters
  (`Base.@kwdef struct Params ... end`).

### Performance path (in order)
1. `@code_warntype f(args...)` — fix every red `Any`/`Union` in hot code (type
   instability is the #1 Julia performance bug).
2. `BenchmarkTools.@benchmark` with interpolated arguments (`$x`); watch allocations —
   a hot inner loop should allocate zero bytes per iteration.
3. `@profview` (ProfileView/VS Code) to find hotspots.
4. Then consider: `@inbounds` (only after bounds are proven), `@simd`,
   `LoopVectorization.@turbo`, threading with `Threads.@threads`. `@fastmath` changes
   results — flag it.

### Testing
- `Test` stdlib: `@test isapprox(a, b; rtol=..., atol=...)` (or `a ≈ b` only with
  explicit tolerances). `Pkg.test()` runs `test/runtests.jl`.

## Fortran

Used for performance-critical kernels and legacy solvers. Two modes — know which one
you're in:

- **Editing legacy code**: match the existing dialect exactly (fixed-form F77, COMMON
  blocks, whatever is there). Do not modernize, reindent, or convert form unasked.
- **Writing new code**: modern free-form Fortran (≥ F2008), rules below.

### New-code rules
- `implicit none` in every program unit. `intent(in|out|inout)` on every dummy argument.
- Kinds via `use, intrinsic :: iso_fortran_env, only: dp => real64`; every real
  literal in `dp` context suffixed: `0.5_dp`, `1.0e-6_dp`. An unsuffixed `1e-3` is
  single precision and will silently poison a double-precision computation.
- Assumed-shape arrays `omega(:)` + explicit interfaces (put procedures in modules so
  interfaces are automatic). No COMMON, no `equivalence`, no `goto` in new code.
- `pure`/`elemental` where applicable — documents intent and enables optimization.
- Column-major: leftmost index varies fastest in inner loops. Whole-array operations
  and intrinsics (`matmul`, `sum`, `maxval`) where clear; explicit loops where faster
  or clearer.
- Parameters in a derived type or module of named `parameter` constants — no magic
  numbers in the physics.

### Build & interop
- Record compiler + flags in the Makefile/CMake and README. Separate "debug" flags
  (`-O0 -g -fcheck=all -ffpe-trap=invalid,zero,overflow -Wall` for gfortran) from
  "production" flags (`-O3 -march=native`). Run the verification tests under BOTH at
  least once — `-fcheck=all` and FPE traps catch real bugs.
- `-ffast-math` is a results-changing flag: never add it silently.
- Python interop: f2py for quick wraps of computational kernels; `iso_c_binding` +
  ctypes/cffi for stable long-term interfaces. Always add a round-trip test that
  passes a known array Python → Fortran → Python and checks dtype (`float64` ↔
  `real64`), shape, and memory order (`np.asfortranarray` where needed).

## Code review checklist (any language)

When asked to review scientific code, check in this order:
1. Is there any verification of the numerics? (If none: that's the top finding.)
2. Tolerances: deliberate or arbitrary? Float `==` anywhere?
3. Precision consistency, especially across language boundaries.
4. Hidden state: globals, global RNG, module-level mutability.
5. Magic numbers in the physics (unnamed dt, nu, grid sizes).
6. Hot-loop allocations / Python-level loops / type instabilities.
7. Readability for a scientist: does notation match the math? Are units stated?
