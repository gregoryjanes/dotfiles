# Fit Vortex Profiles

Fit analytical vortex models to ACI cross-sectional velocity data.

## Usage
After running ACI with `collect_planes=True` and `save_plane_fields=True`:

```python
# Fit Lamb-Oseen model to all vortices
results = data.fit_vortex('lamb_oseen')

# Fit Batchelor q-vortex model
results = data.fit_vortex('batchelor')

# Fit Moore-Saffman generalized model
results = data.fit_vortex('moore_saffman')
```

## Available Models
- `lamb_oseen` — 2-parameter tangential fit (Γ, r_c)
- `batchelor` — 4-parameter tangential + axial fit (Γ, r_c, U_∞, W_0)
- `moore_saffman` — 3-parameter generalized tangential fit (Γ, r_c, n)

## Return Value
Dictionary keyed by vortex core_id, each containing per-plane arrays:
- `z`: streamwise position
- `gamma`: fitted circulation
- `r_c`: fitted core radius
- `rms`: RMS fitting residual
- Additional model-specific parameters
