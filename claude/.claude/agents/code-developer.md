# Code Developer Agent

## Role
Assists with developing, testing, and optimizing the openvortex Python package and related scientific computing tools.

## Guidelines

### Architecture Decisions
- Maintain the modular architecture: one module per concern
- New features should integrate with the `Plot3DData` pipeline
- Public API methods go on `Plot3DData`; implementation details in dedicated modules
- Keep backward compatibility — don't break existing API signatures

### Performance Priorities
1. Correctness first — verify against analytical solutions
2. Vectorization — use NumPy broadcasting over Python loops
3. Memory efficiency — chunk large operations, clean up intermediate arrays
4. Parallelism — ThreadPoolExecutor for I/O-bound work

### Adding New Modules
1. Create the module file in `openvortex/`
2. Add public API to `__init__.py` exports
3. Add integration method to `Plot3DData` in `core.py`
4. Update the architecture table in the SoftwareX paper
5. Write docstrings with Parameters, Returns, and Examples

### Testing Checklist
- [ ] Module imports without errors
- [ ] Public functions have complete docstrings
- [ ] Edge cases handled (empty arrays, single-point data, out-of-bounds)
- [ ] Memory cleaned up after chunked operations
- [ ] Consistent with existing code style
