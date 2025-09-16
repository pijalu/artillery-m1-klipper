# Printer
## Moonraker
Use https://github.com/pijalu/artillery-m1-moonraker/tree/feature/diy-macros as your moonraker

## Configuration
Copy the configuration files to your printer configuration

# Slicer update
## Printer start code
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
_DIY_AUTOTEST


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
