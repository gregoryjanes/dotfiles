# Computational Methods Knowledge Base

## Numerical Methods Used in OpenVortex

### Analytical Eigensolver (3×3 Matrices)
- **Eigenvalues:** Cardano's formula for the depressed cubic t³ + at + b = 0
- **Real eigenvector:** Cross-product null-space method — compute cross products of all row pairs of (A - λ_r I), select the one with largest norm
- **Performance:** 10–30× faster than LAPACK-based np.linalg.eig for batches of 3×3 matrices
- **Reference:** Nickalls (1993) for Cardano's formula

### Curvilinear Grid Metrics
- Forward finite differences for ∂(x,y,z)/∂(ξ,η,ζ)
- Analytical 3×3 inverse via cofactor matrix / determinant (Cramer's rule)
- Jacobian determinant = det(∂(x,y,z)/∂(ξ,η,ζ))
- VGT in physical space: ∇v = (∂v/∂ξ, ∂v/∂η, ∂v/∂ζ) · J⁻¹

### Interpolation
- **Trilinear:** RegularGridInterpolator for 3D field sampling
- **Bicubic spline:** RectBivariateSpline (k=3) for plane-resolved fields
- **Nearest-neighbor:** For binary mask fields (preserves sharp boundaries)

### Optimization
- **L-BFGS-B:** Bounded quasi-Newton method for sub-grid centerline refinement
- **Two-stage:** Global grid search → L-BFGS-B from best grid point
- **Mask constraint:** Soft barrier penalty for out-of-mask excursions

### Pathfinding
- **MCP_Geometric:** Dijkstra's algorithm with diagonal-aware distance weighting
- **Cost field:** PDEF (penalty distance from edge function) based on distance transform
- **Endpoint detection:** Double Euclidean distance transform maximization

### Signal Processing
- **Savitzky-Golay filter:** Post-refinement smoothing of centerline coordinates
- **Curl of normalized eigenvector:** Barrier field for vortex segmentation; normalized by 90th-percentile reference

## CFD Background

### PLOT3D Format
- Structured multi-block grids: `.x`/`.g` (grid), `.q` (solution)
- Conservative variables: ρ, ρu, ρv, ρw, ρE
- Binary format with Fortran record markers
- Grid shape: (ni, nj, nk) with k typically streamwise

### FDL3DI Solver
- Compressible Navier-Stokes equations
- Implicit approximately factored finite-difference algorithm
- 6th-order compact finite differencing
- 8th-order low-pass spatial filter
- Newton-like subiterations for temporal accuracy

### ILES (Implicit Large-Eddy Simulation)
- No explicit subgrid-scale model
- Numerical dissipation from spatial filter acts as implicit SGS model
- Resolves energy-containing scales; dissipates sub-filter scales

## Curve Fitting (Vortex Profiles)

### Levenberg-Marquardt / Trust Region Reflective
- `scipy.optimize.curve_fit` with bounds
- Initial guess strategy: estimate from data percentiles
- Bounds: physical constraints (r_c > 0, |Γ| bounded by observed velocity)

### Radial Binning
- Azimuthally average velocity data into radial bins
- Weight by number of samples per bin
- Reject outliers via IQR-based filtering
