# Polestar VC150SDD Insulation Model 🧊

**Group 3**

A MATLAB thermal model for testing different insulation materials in the Polestar Cooling VC150SDD solar-powered vaccine refrigerator. Built for our Sustainability in Engineering coursework (Option 4: Insulation & Heat Transfer).

---

## What Does This Model Do?

In plain English: it calculates **how much heat leaks into the fridge** through its walls for different insulation materials, and tells you whether the compressor can handle it.

It can do two things:

1. **Single Wall Mode** — Analyse one wall of the fridge. Useful for understanding how heat moves through each layer (steel → insulation → aluminium).
2. **Full Fridge Mode** — Analyse all 6 walls together (front, back, left, right, bottom, lid) and get the total heat leaking in. This is what matters for checking if the fridge actually works.

The model compares **7 insulation materials** against the current PU foam baseline and checks each one against the BD35K compressor's cooling capacity (64W).

---

## Files — What's What

| File | What It Does |
|------|-------------|
| `run_model.m` | **START HERE.** This is the main script you actually run. |
| `material_library.m` | Database of all material properties (thermal conductivity, density, etc.) |
| `wall_thermal_resistance.m` | Calculates thermal resistance for a composite wall |
| `simulate_single_wall.m` | Runs the analysis for one wall |
| `simulate_fridge.m` | Runs the analysis for the whole fridge (6 walls) |
| `display_results.m` | Formats and prints results nicely in the console |

You only ever need to run **`run_model.m`** — it calls all the other files automatically.

---

## How to Run It

### Step 1: Download all 6 `.m` files

Put them **all in the same folder**. This is important — MATLAB won't find the functions if they're in different places.

### Step 2: Open MATLAB

Open `run_model.m` in MATLAB.

### Step 3: Press the green Run button (or type `run_model` in the Command Window)

That's it. You'll get:
- A printed summary in the Command Window with all the numbers
- Two bar chart figures comparing the materials
- Two saved images (`material_comparison.png` and `u_value_comparison.png`)

---

## How to Change Things

### Change the ambient or internal temperature

In `run_model.m`, find these lines near the top:

```matlab
T_ambient  = 43;        % [°C] - WHO hot zone test condition
T_internal = 5;         % [°C] - Mid-range vaccine safe temperature
```

Change the numbers. For example, to test at 32°C ambient:

```matlab
T_ambient  = 32;
```

### Change the insulation thickness

Find this line in `run_model.m`:

```matlab
insul_thick = 0.055;    % [m] - 55 mm insulation
```

Change the number. **Remember it's in metres**, so 40mm = 0.040, 60mm = 0.060, etc.

### Change the fridge dimensions

Find these lines:

```matlab
internal_L = 0.75;      % [m]
internal_W = 0.50;      % [m]
internal_H = 0.40;      % [m]
```

These are the internal cavity dimensions in metres.

### Add a new insulation material

Open `material_library.m` and copy one of the existing blocks. For example:

```matlab
materials.myNewMaterial.k       = 0.030;      % Thermal conductivity [W/(m*K)]
materials.myNewMaterial.rho     = 50;         % Density [kg/m^3]
materials.myNewMaterial.cp      = 1200;       % Specific heat [J/(kg*K)]
materials.myNewMaterial.name    = 'My New Material';
materials.myNewMaterial.type    = 'insulation';
```

Then add `'myNewMaterial'` to the `insul_names` list in `run_model.m`.

### Test two insulation layers (e.g. VIP + PU foam sandwich)

There's already an example of this in Part B of `run_model.m`. To change the materials or thicknesses, find:

```matlab
wall_dual.insul1_material = mat.VIP;
wall_dual.insul1_thick    = 0.020;      % 20mm VIP
wall_dual.insul2_material = mat.PU_foam;
wall_dual.insul2_thick    = 0.035;      % 35mm PU foam
```

---

## What the Results Mean

### Key numbers to look at

| Term | What It Means | Good If... |
|------|--------------|------------|
| **Q_total [W]** | Total heat leaking into the fridge per second | **Lower is better.** Must be under 64W (compressor limit). |
| **U-value [W/(m²·K)]** | How easily heat passes through the walls | **Lower is better.** Think of it like an energy rating. |
| **Compressor Check** | Can the BD35K keep up with the heat leak? | Says **PASS** or **FAIL**. |
| **Margin %** | How much spare cooling capacity is left | Higher margin = more headroom for hot days, door openings, etc. |

### Temperature profile

For single wall results, you get the temperature at every layer boundary. This shows you where most of the temperature drop happens — spoiler: it's almost entirely across the insulation layer, which is the whole point.

---

## Materials Included

| Material | Thermal Conductivity | Notes |
|----------|---------------------|-------|
| PU Foam (Baseline) | 0.024 W/(m·K) | Current industry standard |
| Vacuum Insulation Panel | 0.005 W/(m·K) | Best performer, but expensive and fragile |
| Silica Aerogel | 0.015 W/(m·K) | Excellent performance, high cost |
| Expanded Polystyrene (EPS) | 0.036 W/(m·K) | Cheap but worse than PU |
| Cork | 0.042 W/(m·K) | Renewable, carbon-negative growth |
| Hemp Fibre | 0.040 W/(m·K) | Sustainable, low embodied carbon |
| Sheep's Wool | 0.038 W/(m·K) | Sustainable, good moisture handling |

Lower thermal conductivity = better insulator = less heat gets through.

---

## Key Assumptions

These are engineering estimates — if Polestar provides actual specs, update them in `run_model.m`:

- **Internal volume:** 150L (0.75 × 0.50 × 0.40 m cavity)
- **Outer casing:** 0.8 mm galvanised steel
- **Inner liner:** 0.5 mm aluminium
- **Insulation thickness:** 55 mm (baseline, adjustable)
- **Outer convection:** h = 10 W/(m²·K) (natural convection in still air)
- **Inner convection:** h = 5 W/(m²·K) (enclosed cavity, low air movement)
- **Compressor:** BD35K at 2000 rpm, −5°C evaporating = 64W cooling (from SECOP data sheet)
- **Operating conditions:** 43°C ambient, 5°C internal (WHO PQS hot zone test)

---

## Method

The model uses a **thermal resistance network** (same idea as resistors in series in an electrical circuit). Each layer of the wall adds resistance to heat flow:

```
[Hot outside air] → convection → [Steel] → conduction → [Insulation] → conduction → [Aluminium] → convection → [Cold inside air]
```

Total resistance R_total = R_conv_outer + R_steel + R_insulation + R_aluminium + R_conv_inner

Heat flow: **Q = ΔT / R_total** (where ΔT = T_ambient − T_internal)

For the full fridge, the 6 walls are in **parallel** (heat leaks through all of them simultaneously), so we sum the heat flows.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Undefined function 'material_library'" | All `.m` files must be in the same folder. Check they're all there. |
| "Not enough input arguments" | You're probably trying to run one of the function files directly. Only run `run_model.m`. |
| No figures appearing | Make sure you have `close all` at the top (it's there by default). Try typing `figure` in the Command Window to check MATLAB can open windows. |
| Numbers look wrong | Double-check units. Thicknesses are in **metres** (0.055 = 55mm), temperatures in **°C**. |
