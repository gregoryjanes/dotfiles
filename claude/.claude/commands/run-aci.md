# Run ACI Pipeline

Execute the complete ACI pipeline on PLOT3D data.

## Usage
```
/run-aci <grid_file> <solution_file> [options]
```

## Typical workflow:
```python
from openvortex import Plot3DData, find_bounds_from_scalar
from pathlib import Path

data = Plot3DData()
data.import_grid(Path("grid.x"))
data.import_solution(Path("solution.q"))
data.calculate_primitives()
data.calculate_pressure()

# Optional: truncate to region of interest
bounds = find_bounds_from_scalar(data.pressure, threshold=-0.5, padding=15)
if bounds:
    data.truncate_all(bounds)

# Run ACI
thresholds = {
    "liutex_magnitude": 0.52,
    "liutex_vector_gradient": 0.8,
}
results = data.run_aci(
    thresholds=thresholds,
    aci_step_size=0.05,
    centerline_method="pressure_minimum",
    collect_planes=True,
    plane_grid_points=51,
    min_vortex_volume=0.05,
)

# Save results
data.save_aci_results("aci_output/")
```
