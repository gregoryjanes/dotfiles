# Open-Source Development Rules

## Design Philosophy
- Code should be usable by researchers who are not the author
- API should be intuitive: `data.run_aci(...)`, `data.fit_vortex('lamb_oseen')`
- Minimize required parameters; use sensible defaults
- Document all parameters with units and physical meaning
- Provide illustrative examples in docstrings

## Compatibility
- Support PLOT3D structured grid format (primary)
- Plan for future: CGNS, VTK, unstructured meshes, experimental 3D-3C data
- HPC-aware: SLURM environment detection, memory-adaptive chunking
- Work headless (no display required) for batch processing

## Licensing
- GPLv3 — all contributions must be compatible
- Do not include proprietary code or data
- Attribute third-party algorithms (CEASAR, Banks & Singer, etc.) with citations

## Documentation
- Every public function has a complete docstring
- Module-level docstrings describe purpose and key design decisions
- README with installation, quick start, and citation info
- Version history in module docstrings
