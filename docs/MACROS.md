# Artillery M1 - Macro Reference

## State Trace Identifiers

All key operations emit `RESPOND TYPE=command MSG='[AM1P] State: <KEY>'` for external monitoring.
Use these identifiers to track printer state in dashboards or logging tools.

| State Key          | Phase                              | Emitted By              | Config File          |
|--------------------|------------------------------------|-------------------------|----------------------|
| `INIT_START`       | Print initialization begun         | `_init_start`           | diy_start_print.cfg  |
| `HEAT_CHAMBER`     | Chamber heating                    | `_heat_chamber`         | diy_start_print.cfg  |
| `HEAT_BED`         | Bed heating                        | `SLICER_START_PRINT`, `_heat_chamber`, `MANUAL_LEVEL` | slicer-macro.cfg, diy_start_print.cfg |
| `HOMING`           | G28 homing cycle                   | `SLICER_START_PRINT`, `MANUAL_LEVEL` | slicer-macro.cfg, diy_start_print.cfg |
| `HOMING_PREPRINT`  | Pre-print homing                   | `SLICER_START_PRINT`    | slicer-macro.cfg     |
| `NOZZLE_CLEAN`     | Nozzle cleaning cycle              | `nozzle_clean`, `MANUAL_LEVEL` | diy_start_print.cfg |
| `MESH`             | Adaptive bed mesh calibration      | `SLICER_START_PRINT`, `MANUAL_LEVEL` | slicer-macro.cfg, diy_start_print.cfg |
| `MESH_VALIDATE`    | Bed mesh validation                | `SLICER_START_PRINT`    | slicer-macro.cfg     |
| `SHAPER`           | Input shaper calibration           | `SLICER_START_PRINT`    | slicer-macro.cfg     |
| `HEAT_NOZZLE`      | Nozzle heating to print temp       | `SLICER_START_PRINT`    | slicer-macro.cfg     |
| `PRIME`            | Prime line extrusion               | `_prime_line`           | diy_start_print.cfg  |
| `READY`            | Print start complete               | `SLICER_START_PRINT`    | slicer-macro.cfg     |
| `LEVEL`            | Manual bed leveling started        | `MANUAL_LEVEL`          | diy_start_print.cfg  |
| `LEVEL_DONE`       | Manual bed leveling complete       | `MANUAL_LEVEL`          | diy_start_print.cfg  |
| `FILAMENT_UNLOAD`  | Filament unload started            | `unload_filament`      | diy_start_print.cfg  |
| `FILAMENT_LOAD`    | Filament load started              | `load_filament`        | diy_start_print.cfg  |
| `PAUSE`            | Print paused                       | `PAUSE`                 | manual_change.cfg    |
| `RESUME`           | Print resumed                      | `RESUME`                | manual_change.cfg    |
| `CANCEL`           | Print cancelled                    | `CANCEL_PRINT`          | manual_change.cfg    |
| `PRINT_END`        | Print finished                     | `PRINT_END`, `SLICER_END_PRINT` | macros.cfg, slicer-macro.cfg |
| `PRINT_END_DONE`   | Print end sequence complete        | `SLICER_END_PRINT`      | slicer-macro.cfg     |

**Config Messages:**
- `[AM1P] Config: bed=...` — Emitted by `SLICER_START_PRINT` to log initial configuration

---

## Slicer Macros (`slicer-macro.cfg`)

### `SLICER_START_PRINT`
Main print start entry point. Called by the slicer's start G-code.

**Parameters:**
| Param          | Type  | Default | Description                                    |
|----------------|-------|---------|------------------------------------------------|
| `BED_TEMP`     | float | 60      | Bed target temperature (0 = skip)              |
| `CHAMBER_TEMP` | float | 0       | Chamber target temperature (0 = skip)          |
| `EXTRUDER_TEMP`| float | 230     | Nozzle temperature for cleaning & first layer  |
| `AUTOLEVEL`    | int   | 1       | 0 = skip, 1 = adaptive mesh, 2 = validate mesh |
| `SHAPER`       | int   | 0       | 0 = skip, 1 = run SHAPER_CALIBRATE             |

**Flow:** Init → Heat Chamber → Heat Bed → Clean Nozzle → Home → Bed Level (optional) → Shaper (optional) → Heat Nozzle → Prime Line → Ready

**Slicer G-code example:**
```
SLICER_START_PRINT BED_TEMP=[bed_temperature_initial_layer_single] CHAMBER_TEMP=[chamber_temperature] EXTRUDER_TEMP=[first_layer_temperature[initial_extruder]] AUTOLEVEL=1 SHAPER=0
```

### `SLICER_END_PRINT`
Standard print end sequence. Handles retraction, parking, cooling, and shutdown.

**Flow:** Retract → Raise Z → Park → Timelapse (if available) → Cool Down → Fans Off → Reset Limits → Heaters Off → Disable Steppers

**Slicer G-code example:**
```
SLICER_END_PRINT
```

**States emitted:**
- `PRINT_END` — Print end sequence started
- `PRINT_END_DONE` — Print end sequence complete

---

## Print & Utility Macros (`diy_start_print.cfg`)

### `_init_start`
Internal initialization. Resets feed/flow rates, velocity limits, positioning, and prepares filament sensor.

### `_heat_chamber`
Heats the chamber to the target temperature. Uses PTC and chamber fans. Waits for 47°C baseline if target ≥ 47°C.

**Parameters:** `CHAMBER_TEMP` (int)

### `nozzle_clean`
Full nozzle cleaning cycle: heat, extrude, scrape at discharge port, brush, seal, and cool.

**Parameters:** `TEMP` (int, default 230) — peak cleaning temperature

### `_prime_line`
Extrudes a prime line along the front edge of the bed (X20→X240 at Y2).

### `MANUAL_LEVEL`
Triggers adaptive bed leveling with heating. Heats bed to the given temperature (or uses current target), heats nozzle to 140°C for cleaning, homes, then runs **adaptive** bed mesh (`BED_MESH_CALIBRATE ADAPTIVE=1`).

**NOTE:** This creates a **partial** mesh over the detected print area, not a full bed mesh.

**Parameters:**
| Param       | Type  | Default        | Description                      |
|-------------|-------|----------------|----------------------------------|
| `BED_TEMP`  | float | heater_bed.target | Bed temperature for leveling |
| `NOZZLE_TEMP`| int  | 140            | Nozzle temperature for cleaning  |

### `unload_filament`
Moves to collection box, retracts filament. Requires extruder temperature.

**Parameters:** `TEMP` (int, required) — nozzle temperature

### `load_filament`
Moves to collection box, loads filament with purge. Requires extruder temperature.

**Parameters:** `TEMP` (int, required) — nozzle temperature

### `_CHOICE_VALIDATE_MESH`
Fluidd UI prompt to set mesh validation deviation tolerance.

---

## General Macros (`macros.cfg`)

| Macro              | Description                                        |
|--------------------|----------------------------------------------------|
| `m300`             | Audible beep. `M300 [P<ms>] [S<Hz>]`              |
| `M141`             | Set chamber temp (no wait)                         |
| `M191`             | Set chamber temp (wait)                            |
| `M106`             | Fan control: P0=part_fan, P1=auxiliary, P2=filter, P3=secondary |
| `M107`             | All fans off                                       |
| `M190`             | Bed temp wait (rename of existing)                 |
| `M203`             | Max velocity setter (capped at 500)                |
| `M205`             | Square corner velocity setter (capped at 30)       |
| `G29`              | Bed leveling via `MANUAL_LEVEL` with adaptive mesh |
| `G30`              | Single Z probe / probe calibration                 |
| `_PRINT_START_HOOK`| Virtual SD card hook (internal, not user-facing)   |
| `PRINT_END`        | Called on print completion                         |
| `da_tilt`          | Home + screws tilt calculate                       |
| `M17`              | Enable steppers                                    |
| `_move_to_collection_box` | Move to filament collection area with homing |
| `_move_to_collection_box_no_g28` | Same without homing                  |
| `EMERGENCY_RETRACT`| Emergency filament retraction (hot end > 280°C)    |
| `STEPPER_MONITOR`  | Dump TMC stepper status                            |

---

## Manual Change & Pause/Resume (`manual_change.cfg`)

### `PAUSE`
Standard Klipper pause. Parks nozzle at collection box, saves state, cools extruder.

**Parameters:**
| Param | Type | Default | Description           |
|-------|------|---------|-----------------------|
| `Z`   | int  | 2       | Z lift amount         |
| `E`   | float| 2       | Retraction on park    |
| `X`   | int  | 200     | Park X position       |
| `Y`   | int  | 275     | Park Y position       |
| `R`   | float| current | Resume nozzle temp    |

### `RESUME`
Restores saved state, reheats, returns to print position, resumes.

### `CANCEL_PRINT`
Standard cancel: retract, cool, park, reset.

### `FILAMENT_CHANGE`
Full filament change procedure: heat, move to cutter, cut, retract, move to collection box.

### `FILAMENT_UNLOAD`
Dedicated unload: moves to collection box, retracts filament. Requires temperature.

**Parameters:** `TEMP` (int, required)

### `FILAMENT_LOAD`
Dedicated load: moves to collection box, extrudes filament, purges, cleans nozzle. Requires temperature.

**Parameters:** `TEMP` (int, required)

### `M109` (overridden)
During pause with no `F` flag, triggers `FILAMENT_CHANGE` instead of simple wait.

---

## File Layout

```
config/
├── printer.cfg           # Main printer config (includes all below)
├── macros.cfg            # General macros (M-codes, homing, G29, G30)
├── slicer-macro.cfg      # SLICER_START_PRINT entry point
├── diy_start_print.cfg   # Internal helpers, MANUAL_LEVEL, load/unload
├── manual_change.cfg     # PAUSE, RESUME, CANCEL, FILAMENT_* macros
├── variables.cfg         # Persistent variables (saved at runtime)
├── macros_ellis3d.cfg    # Ellis3D debugging utilities
├── timelapse.cfg         # Moonraker timelapse macros
├── save-zoffset.cfg      # Z-offset persistence
└── moonraker_obico_*.cfg # Obico integration
```
