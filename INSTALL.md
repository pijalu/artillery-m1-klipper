# Printer
## Moonraker
Use https://github.com/pijalu/artillery-m1-moonraker/tree/feature/diy-macros as your moonraker

## Configuration
Copy the configuration files to your printer configuration

# Slicer update
## Printer start code
```
_SLICER_START_PRINT BED_TEMPERATURE_INITIAL_LAYER_SINGLE=[bed_temperature_initial_layer_single] CHAMBER_TEMPERATURE={chamber_temperature[0]} FIRST_LAYER_TEMPERATURE_EXTRUDER={first_layer_temperature[initial_extruder]} INITIAL_EXTRUDER=[initial_extruder] FIRST_LAYER_PRINT_MIN_0={first_layer_print_min[0]} FIRST_LAYER_PRINT_MIN_1={first_layer_print_min[1]} X_P_MIN={adaptive_bed_mesh_min[0]} Y_P_MIN={adaptive_bed_mesh_min[1]} X_P_MAX={adaptive_bed_mesh_max[0]} Y_P_MAX={adaptive_bed_mesh_max[1]} ALGORITHM=[bed_mesh_algo]  XPROBE_COUNT={bed_mesh_probe_count[0]} YPROBE_COUNT={bed_mesh_probe_count[1]} NOZZLE_TEMPERATURE_0={nozzle_temperature[0]} NOZZLE_TEMPERATURE_1={nozzle_temperature[1]} NOZZLE_TEMPERATURE_2={nozzle_temperature[2]} NOZZLE_TEMPERATURE_3={nozzle_temperature[3]} NOZZLE_TEMPERATURE_4={nozzle_temperature[4]} NOZZLE_TEMPERATURE_5={nozzle_temperature[5]} NOZZLE_TEMPERATURE_6={nozzle_temperature[6]} NOZZLE_TEMPERATURE_7={nozzle_temperature[7]}
```
## Orca Profile
You can import Orca Profile at https://github.com/pijalu/artillery-m1-orca/releases 