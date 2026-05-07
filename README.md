# ENGR7008 — F1 2025→2026 Suspension Kinematic Rescaling

MATLAB implementation supporting the Vehicle Dynamics section of the
ENGR7008 Laptime Simulation and Race Engineering coursework.
MSc Motorsport Engineering, Oxford Brookes University, Group 3, 2026.

## Overview

This repository contains the MATLAB scripts used to (i) extract the static
kinematic properties of the 2025 baseline F1 suspension geometry, (ii) rescale
the hardpoint set to the 2026 FIA Technical Regulations, and (iii) generate
3D overlay visualisations comparing both configurations.

## Repository contents

| File | Lines | Purpose |
|------|-------|---------|
| `extract_kinematics_2025.m` | 591 | Reads 2025 hardpoints and computes camber, caster, KPI, FVIC, SVIC, roll centre height, anti-dive, anti-squat, mechanical trail, scrub radius, and motion ratio. |
| `rescale_to_2026.m` | 492 | Applies axis-specific scale factors to the 2025 hardpoints (X by wheelbase ratio, Y by track ratio per axle, Z unchanged) and writes the 2026 hardpoint set with enforced left-right symmetry. |
| `plot_suspension_comparison.m` | [N] | Generates 3D overlay plots of 2025 vs 2026 wishbone geometry. |
| `Cinematica_Suspension.xlsx` | — | Input file: 2025 baseline suspension hardpoints (Front 2025 / Rear 2025 sheets). |

## Coordinate system

Following the AVL VSM convention: **X** positive forward, **Y** positive left,
**Z** positive upward, origin at the front axle.

## How to run

Requirements: MATLAB R2023a or later. No additional toolboxes required beyond
base MATLAB and Statistics Toolbox.

```matlab
% From the repository root:
extract_kinematics_2025          % computes 2025 baseline kinematics
rescale_to_2026                  % generates Cinematica_Suspension_2026.xlsx
plot_suspension_comparison       % 3D overlay plot
```

## Key regulatory parameters (2025 → 2026)

| Parameter | 2025 | 2026 | Source |
|-----------|------|------|--------|
| Wheelbase | 3600 mm | 3400 mm | FIA (2026), Art. 3 |
| Overall width | 2000 mm | 1900 mm | FIA (2026), Art. 3 |
| Front tyre width | 305 mm | 280 mm | Pirelli (2025) |
| Rear tyre width | 405 mm | 375 mm | Pirelli (2025) |
| Front tyre diameter | 720 mm | 705 mm | Pirelli (2025) |
| Rear tyre diameter | 720 mm | 710 mm | Pirelli (2025) |
