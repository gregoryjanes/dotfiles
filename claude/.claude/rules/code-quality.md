# Code Quality Rules

## Python Standards
- Target Python 3.10+ compatibility
- Use NumPy-style docstrings for all public functions and classes
- Type hints on all function signatures
- No star imports; group imports as stdlib → third-party → local
- Prefer vectorized NumPy/SciPy over Python loops for numerical code
- Use analytical solvers (Cardano's, cross-product null-space) over iterative LAPACK calls for 3×3 matrices
- All numerical arrays should use explicit dtypes (np.float32 preferred unless np.float64 is absolutly required)

## Performance
- Memory-conscious: estimate array sizes before allocation; chunk if needed
- Pre-build interpolators and share across iterations (don't reconstruct per-call)
- Use ThreadPoolExecutor for I/O-bound or GIL-releasing parallel work
- Profile before optimizing; document performance-critical sections

## Testing & Validation
- Validate numerical methods against known analytical solutions
- Include edge case handling (degenerate matrices, zero-length vectors, boundary cells)
- Use `np.errstate` to suppress expected floating-point warnings
- Clamp values before sqrt/cbrt operations to avoid NaN propagation

## Error Handling
- Print informative warnings rather than silently failing
- Use `raise ValueError` for user-facing parameter validation
- Graceful degradation: if a single plane/vortex fails, skip it and continue

## Git & Versioning
- Semantic versioning (MAJOR.MINOR.PATCH)
- Update `__version__` in `__init__.py` when making releases
- Keep changelog in version comments in module docstrings
