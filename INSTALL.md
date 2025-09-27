# Printer
## Moonraker
Use https://github.com/pijalu/artillery-m1-moonraker/tree/feature/diy-macros as your moonraker

## Configuration
Copy the configuration files to your printer configuration

# Slicer update
## Printer start code
```
SLICER_START_PRINT BED_TEMPERATURE_INITIAL_LAYER_SINGLE=[bed_temperature_initial_layer_single] CHAMBER_TEMPERATURE={chamber_temperature[0]} FIRST_LAYER_TEMPERATURE_EXTRUDER={first_layer_temperature[initial_extruder]} INITIAL_EXTRUDER=[initial_extruder] FIRST_LAYER_PRINT_MIN_0={first_layer_print_min[0]} FIRST_LAYER_PRINT_MIN_1={first_layer_print_min[1]} X_P_MIN={adaptive_bed_mesh_min[0]}Y_P_MIN={adaptive_bed_mesh_min[1]} X_P_MAX={adaptive_bed_mesh_max[0]} Y_P_MAX={adaptive_bed_mesh_max[1]}
```
Or
```
;#=====================Start_gcode ==========================================
;#Can only be used after installing the Klipper macros in the M1 PRO printer.
;#=========================================================================
    SET_DISPLAY_TEXT
    _DIY_INIT_START


;#===== Preheat Before Zeroing ===========================================

    SDCARD_DIY_STATUS STATE='STEP_HOTING_WAIT'
    M140 S[bed_temperature_initial_layer_single];


;#=================Heating  Chamber========================================


    _DIY_HEATING_CHAMBER CHAMBER_TEMP={chamber_temperature[0]}

;#===================Heating BED===========================================
{if (bed_temperature_initial_layer_single >0)}
   M190 S[bed_temperature_initial_layer_single];
{else}
   M140 S[bed_temperature_initial_layer_single];
{endif}


;#===============CLEAN NOZZLE==============================================

     _DIY_CLEAN_NOZZLE TEMP={first_layer_temperature[initial_extruder]}


;#===============test autolevel and shaper=================================


     _DIY_AUTOTEST X_P_MIN={adaptive_bed_mesh_min[0]} Y_P_MIN={adaptive_bed_mesh_min[1]} X_P_MAX={adaptive_bed_mesh_max[0]} Y_P_MAX={adaptive_bed_mesh_max[1]}


;#======================= Wait heating =========================================
  G28
  G1 X20 Y5.8 Z0.2 F18000
;===== Set Print Temperature ==========================================
  M106 S120;
  G4 P500

M104 S[first_layer_temperature];
{if (bed_temperature_initial_layer_single >0)}
   M190 S[bed_temperature_initial_layer_single];
{else}
   M140 S[bed_temperature_initial_layer_single];
{endif}


    M109 S[first_layer_temperature];

    M106 S0;

    G4 P500


;#===== Wipe Nozzle Extrude Line =====================
_FIRST_LINE FLPM_X={first_layer_print_min[0]} FLPM_Y={first_layer_print_min[1]}

;#===== END G-CODE  =====================
```
