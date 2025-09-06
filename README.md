# Artillery M1 Pro Configuration
## Overview
This repository contains a set of community‑developed configuration files for the Artillery M1 Pro printer. The goal is to provide community optimized setup that you can use to overcome Artillery limitation, tweak as needed, and keep in sync with your machine’s firmware.


## Structure
* factory/ – the factory default Klipper configuration (Should be a copy of the official config used by factory reset).

* config/ – the running configuration file that includes custom parameters, macros, and common G‑code snippets.

sync.sh – a small helper script to pull the latest firmware / settings from your remote printer IP address.

## Branches
- artillery: contains Artillery provided configuration
- main: contains current configuration

## Tags
- artillery-xx.xx.xx.xx: tags Artillery provided configuration linked to firmware

## Disclaimer 
The files are community configurations: they come from the open‑source community, do not come with any guaranteed support, but have been tested on the Artillery M1 Pro and should work as-is after a quick sanity check.
