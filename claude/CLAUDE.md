# CLAUDE.md — Project Context for Claude Code

## Research Focus

PhD research in **computational vortex dynamics**, **fluid dynamics analysis methods**, **data-driven model reduction**, and **building analytical models from data using sparse identification**, specifically:

- **Vortex centerline identification** in high-fidelity CFD data (implicit large-eddy simulation)
- **Vortex core analysis**: axial stretching, pressure distribution, circulation, velocity profiles
- **Counter-rotating vortex pair instabilities**: Crow instability, elliptic instability, cavitation inception
- **Liutex-based vortex identification**: third-generation methods using the real eigenvector of the velocity gradient tensor as a shear-free rotational axis
- **Open-source scientific software development** for the vortex dynamics and model reduction community
- **Data-driven model reduction** using data to build computational methods for cheap and accurate parametric predictions
- **Spare identification** of data to help build upon governing equations and filament equations to develop more accurate analytical equations

## Active Projects

### 1. OpenVortex (`openvortex/`)
An open-source Python package implementing the **Adaptive Centerline Interpolation (ACI)** method for physics-informed vortex centerline identification and core analysis. Key modules:

| Module | Purpose |
|--------|---------|
| `core.py` | `Plot3DData` data container and pipeline orchestrator |
| `aci.py` | Four-stage ACI algorithm (segmentation → guide path → planes → refinement) |
| `liutex.py` | Analytical eigensolver (Cardano's formula + cross-product null-space) for Liutex computation |
| `grid_metrics.py` | Curvilinear grid metrics, Jacobian, and VGT computation |
| `vortex_fitting.py` | Analytical vortex model fitting (Lamb-Oseen, Batchelor, Moore-Saffman) |
| `io_plot3d.py` | PLOT3D binary file readers |
| `memory.py` | Adaptive memory management (SLURM-aware chunking) |
| `visualization.py` | HPC/headless PyVista rendering |
| `interactive.py` | Interactive threshold pickers |
| `serialization.py` | JSON/HDF5 export |

### 2. ACI Method Paper (`Janes_ACI_v3.tex`)
Describes the mathematical foundations and algorithmic implementation of ACI. Targets archival journal publication.

### 3. OpenVortex Software Paper (`Janes_openvortex_26.tex`)
SoftwareX paper describing the openvortex package architecture, functionalities, and illustrative examples.

### 4. Comparison Notebooks
- `aci_comparison.ipynb` — Compares ACI against Banks & Singer predictor-corrector and Z-plane methods
- `vortex_profile_fitting.ipynb` — Fits analytical vortex models to ACI cross-sectional data

## Technical Stack

- **Language:** Python 3.10+
- **Core dependencies:** NumPy, SciPy, scikit-image, h5py, psutil
- **Visualization:** PyVista, Matplotlib
- **CFD solver:** FDL3DI (AFRL), PLOT3D format structured grids
- **HPC:** DoD Narwhal, SLURM scheduling
- **License:** GPLv3

## Key Mathematical Concepts

### Velocity Gradient Tensor (VGT)
The 3×3 tensor ∇v whose eigenstructure determines local flow topology. When the discriminant Δ > 0, one real eigenvalue λ_r and a complex conjugate pair λ_cr ± iλ_ci exist, indicating local swirling.

### Liutex Framework
Decomposes vorticity into purely rotational (Liutex) and purely shearing components. The Liutex vector R = R·r̂ where r̂ is the real eigenvector of the VGT (the shear-free rotational axis).

### Modified Omega-Liutex (Ω̃_R)
Normalized vortex identification criterion with pseudo-threshold-insensitivity (0.52–0.60 range). Used for segmentation in the ACI pipeline.

### ACI Algorithm Pipeline
1. **Discriminant masking** — O(1)-per-point filter skipping irrotational regions
2. **Isosurface segmentation** — Liutex magnitude thresholding + curl-based eigenvector barrier separation
3. **Guide path extraction** — CEASAR-adapted Dijkstra with criterion-weighted cost
4. **Plane construction** — Normal to local rotational axis with adaptive ray-cast windowing
5. **Sub-grid refinement** — Bicubic spline + L-BFGS-B optimization

### Vortex Profile Models
- **Lamb-Oseen:** u_θ(r) = Γ/(2πr) · [1 - exp(-αr²/r_c²)], α = 1.255
- **Batchelor q-vortex:** Adds axial velocity deficit w(r) = W₀·exp(-r²/r_c²)
- **Moore-Saffman:** u_θ(r) = Γ/(2πr) · [1 - exp(-αr^(2n)/r_c^(2n))], generalized profile with shape parameter n

## Code Style & Standards

- **Docstrings:** NumPy-style with Parameters, Returns, and Notes sections
- **Type hints:** Use for function signatures
- **Naming:** Descriptive, snake_case for functions/variables, CamelCase for classes
- **Performance:** Prefer vectorized NumPy/SciPy over Python loops; use analytical solvers over iterative
- **Memory:** Always consider memory footprint; use chunking for large arrays
- **Testing:** Validate against known analytical solutions where possible
- **Imports:** Group as stdlib → third-party → local; avoid star imports

## Writing Style (Papers)

- **Tone:** Formal academic, precise but accessible
- **Voice:** Third person, passive where appropriate ("The method is validated..." not "We validate...")
- **Citations:** Use `\cite{}` liberally; always cite foundational work
- **Equations:** Number all significant equations; use `\cref` for cross-references
- **Figures:** Publication-quality with descriptive captions

## Repository Structure

```
openvortex/           # Python package source
├── __init__.py
├── core.py           # Plot3DData class
├── aci.py            # ACI algorithm
├── liutex.py         # Liutex computation
├── grid_metrics.py   # Grid metrics and VGT
├── vortex_fitting.py # Vortex profile fitting
├── io_plot3d.py      # PLOT3D I/O
├── memory.py         # Memory management
├── visualization.py  # Visualization
├── interactive.py    # Interactive tools
└── serialization.py  # Export utilities
Janes_ACI_v3.tex      # ACI method paper
Janes_openvortex_26.tex # Software paper
aci_comparison.ipynb  # Method comparison notebook
vortex_profile_fitting.ipynb # Fitting notebook
```

## Common Tasks

- **Adding a new centerline criterion:** Add to `SUPPORTED_CRITERIA` in `aci.py`, add interpolator in `adaptive_centerline_interpolation()`, add case in `_process_single_plane()`
- **Adding a new vortex model:** Add model function and fit function in `vortex_fitting.py`, register in `SUPPORTED_MODELS`
- **Running ACI:** `data = Plot3DData(); data.import_grid(...); data.import_solution(...); results = data.run_aci(...)`
- **Fitting vortex profiles:** `data.fit_vortex('lamb_oseen')` after running ACI with `collect_planes=True` and `save_plane_fields=True`
