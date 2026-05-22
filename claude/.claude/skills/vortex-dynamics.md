# Vortex Dynamics Knowledge Base

## Core Concepts

### Velocity Gradient Tensor (VGT)
The VGT ∇v is a 3×3 tensor whose eigenstructure classifies local flow topology:
- **Δ > 0:** One real eigenvalue λ_r, complex conjugate pair λ_cr ± iλ_ci → swirling/rotational flow
- **Δ ≤ 0:** Three real eigenvalues → pure strain/irrotational flow
- The real eigenvector r̂ defines the local swirl axis (shear-free)

### Liutex (Third-Generation Vortex ID)
- **Liutex vector:** R = [ω·r̂ - √((ω·r̂)² - 4λ_ci²)] · r̂
- **Properties:** Galilean invariant, unique, local, shear-free
- **Advantages over Q/λ_2/λ_ci:** Explicit rotational/shear decomposition; vector quantity gives direction
- **Key papers:** Liu et al. (2018), Gao et al. (2018, 2019), Wang et al. (2019)

### Modified Omega-Liutex (Ω̃_R)
- Normalized ratio: rotation dominance over total motion
- Range [0, 1]; Ω̃_R > 0.52 identifies vortex regions
- Pseudo-threshold-insensitive: 0.52–0.60 gives similar structures
- Key paper: J. Liu and C. Liu (2019)

### Analytical Vortex Models
- **Lamb-Oseen:** u_θ = Γ/(2πr)[1 - exp(-1.255r²/r_c²)]; self-similar viscous vortex
- **Batchelor q-vortex:** Lamb-Oseen tangential + Gaussian axial deficit; canonical trailing vortex model
- **Moore-Saffman:** Generalized profile with shape parameter n; captures non-Gaussian cores
- **Rankine vortex:** Solid-body rotation (r < r_c), potential flow (r > r_c); idealized limit

### Vortex Instabilities
- **Crow instability:** Long-wavelength symmetric/antisymmetric instability of counter-rotating vortex pairs
- **Elliptic instability:** Short-wavelength instability driven by elliptic streamlines in the core
- **Widnall instability:** Short-wave instability of vortex rings
- **Cavitation inception:** Occurs when local pressure drops below vapor pressure; driven by axial stretching

### Key Quantities Along Vortex Axis
- **Axial velocity:** u_ax = v · r̂
- **Axial vorticity:** ω_ax = ω · r̂
- **Axial strain rate:** S_ax = (r̂ · S) · r̂
- **Axial stretching:** φ_ax = (ω · S) · r̂
- **Circulation:** Γ = ∮ v · dl (line integral around vortex core)

## Existing Methods (for comparison)

### Banks & Singer Predictor-Corrector (1994/1995)
- Follows vorticity direction; corrects to pressure minimum on normal plane
- Cross-section described by 5-term Fourier coefficients
- Feeder elimination via forward-backward validation
- Limitations: vorticity-based axis (shear-contaminated); local method (can diverge)

### Sujudi-Haimes (1995)
- Parallel-vectors condition: v ∥ r̂ (velocity parallel to real eigenvector)
- Cell-by-cell extraction; limited to grid resolution

### Fixed Z-Plane Method
- Slice at constant streamwise positions; find centroid/minimum on each plane
- Fails when filament is not aligned with streamwise direction (tangential intersection artifact)

## References for Literature Review

### Foundational
- Helmholtz (1858) — Vortex theorems
- Saffman (1992) — Classical vortex definition
- Crow (1970) — Long-wavelength instability theory
- Widnall et al. (1974) — Short-wavelength instability

### Vortex Identification
- Hunt et al. (1988) — Q-criterion
- Jeong & Hussain (1995) — λ_2 criterion
- Zhou et al. (1999) — Swirling strength
- Chong et al. (1990) — Critical point theory
- Liu et al. (2016) — Omega method
- Liu et al. (2018, 2019) — Liutex framework
- Dong et al. (2019) — Omega-Liutex

### Centerline Extraction
- Banks & Singer (1994, 1995) — Predictor-corrector
- Sujudi & Haimes (1995) — Parallel vectors
- Roth & Peikert (1998) — Higher-order extraction
- Bitter et al. (2000) — CEASAR skeletonization
- Gao et al. (2019) — Liutex core lines

### Vortex Models
- Lamb (1932) — Lamb-Oseen vortex
- Batchelor (1964) — q-vortex model
- Moore & Saffman (1973) — Generalized vortex profile
- Burnham & Hallock (1982) — Burnham-Hallock vortex model
