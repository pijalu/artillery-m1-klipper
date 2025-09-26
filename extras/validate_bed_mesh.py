# Validate Bed Mesh Leveling
#
# Copyright (C) 2025 Pierre Poissinger <pierre.poissinger@gmail.com>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
#
# VALIDATE_BED_MESH 
#   Probe 4 bed corner + center against loaded bed mesh - if deviation exceeds MAX_DEVIATION, remesh
#   Optionally save config if remeshing
#
#  VALIDATE_BED_MESH_AT X=<x> Y=<y>
#   Get interpolated Z from bed mesh at XY, probe the point and report deviation
#   printer.validate_bed_mesh.last_mesh_z: interpolated Z from mesh
#   printer.validate_bed_mesh.last_probed_z: probed Z at XY
#   printer.validate_bed_mesh.last_deviation: deviation between mesh and probed Z

class ValidateBedMesh:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.mesh_z = 0.0
        self.probed_z = 0.0
        self.deviation = 0.0
        self.gcode = None

        self.speed = config.getfloat('speed', 50., above=0.)
        self.horizontal_move_z = config.getfloat('horizontal_move_z', 3.)
        
        self.probe = None
        self.mcu_probe = None
        # probe settings are set to none, until they are available
        self.lift_speed, self.probe_x_offset, self.probe_y_offset, _ = \
            None, None, None, None
        
        # Lookup GCode object now
        self.gcode = self.printer.lookup_object('gcode')

        self.printer.register_event_handler("klippy:connect",
                                            self._handle_connect)
        
        # Register command
        self.gcode.register_command(
            "VALIDATE_BED_MESH_AT", self.cmd_VALIDATE_BED_MESH_AT,
            desc="Get interpolated Z + probe + deviation at XY from bed"
        )
        self.gcode.register_command(
            "VALIDATE_BED_MESH", self.cmd_VALIDATE_BED_MESH,
            desc="Probe 5 points on the bed mesh and check deviation"
        )
    
    def _handle_connect(self):
        # Only now lookup bed_mesh — safe after initialization
        self.bed_mesh = self.printer.lookup_object("bed_mesh", None)
        if self.bed_mesh is None:
            raise config.error("VALIDATE BED MESH: bed_mesh not configured")

        self.probe = self.printer.lookup_object('probe', None)
        if (self.probe is None):
            config = self.printer.lookup_object('configfile')
            raise config.error(
                "VALIDATE BED MESH requires [probe] to be defined")
        
        probe_name = self.probe.get_status(None).get("name", "")
        
        # MCU probe only for probe_air
        if probe_name.startswith("probe_air"):
            self.mcu_probe = self.probe.mcu_probe

        self.gcode = self.printer.lookup_object('gcode')
        
        self.lift_speed = self.probe.get_probe_params()['lift_speed']
        self.probe_x_offset, self.probe_y_offset, self.probe_z_offset = \
            self.probe.get_offsets()

    def get_status(self, eventtime):
        # Required so macros can query results
        return {"last_mesh_z": self.mesh_z, 
                "last_probed_z": self.probed_z, 
                "last_deviation": self.deviation}
    
    def _move_helper(self, target_coordinates):
        # pad target coordinates
        target_coordinates = \
            (target_coordinates[0], target_coordinates[1], None) \
            if len(target_coordinates) == 2 else target_coordinates
        toolhead = self.printer.lookup_object('toolhead')
        speed = self.speed if target_coordinates[2] == None else self.lift_speed
        toolhead.manual_move(target_coordinates, speed)
        toolhead.wait_moves()
        if self.mcu_probe:
            toolhead.dwell(0.05)
            self.mcu_probe.home_zero()
            toolhead.dwell(0.05)

    def _validate_at(self, x, y, gcmd):
        # Interpolate Z from mesh
        z = self.bed_mesh.z_mesh.calc_z(x, y)
        self.mesh_z = z

        ## Go probe the point to validate
        ## horizontal_move_z (to prevent probe trigger or hitting bed)
        self._move_helper((None, None, self.horizontal_move_z))
        # move to point to probe
        self._move_helper((x, y, None))

        probe_session = self.probe.start_probe_session(gcmd)
        probe_session.run_probe(gcmd)
        z = probe_session.pull_probed_results()[0][2] # only z
        probe_session.end_probe_session()

        self.probed_z = z - self.probe_z_offset # adjust for probe offset
        self.deviation = self.probed_z - self.mesh_z

    
    def cmd_VALIDATE_BED_MESH_AT(self, gcmd):
        x_offset, y_offset, z_offset = self.probe.get_offsets()
        x = gcmd.get_float("X")
        y = gcmd.get_float("Y")

        self._validate_at(x, y, gcmd) 
        gcmd.respond_info(f"Mesh Z at ({x:.2f}, {y:.2f}) = {self.mesh_z:.4f}mm)")
        gcmd.respond_info(f"Measured Z at ({x:.2f}, {y:.2f}) = {self.probed_z:.4f}mm)")
        gcmd.respond_info(f"Deviation = {self.deviation:.4f}mm")

    def cmd_VALIDATE_BED_MESH(self, gcmd):
        maxdeviation = gcmd.get_float("MAX_DEVIATION", 0.05)
        save_config = gcmd.get("SAVE_CONFIG", "FALSE").upper() == "TRUE"
        remesh = False
        min_x, min_y = self.bed_mesh.status['mesh_min']
        max_x, max_y = self.bed_mesh.status['mesh_max']

        positions = [(min_x, min_y), 
                     (min_x, max_y),
                     (max_x/2, max_y/2), 
                     (max_x, min_y), 
                     (max_x, max_y)]
        
        for pos in positions:
            x, y = pos
            self._validate_at(x, y, gcmd)
            gcmd.respond_info(f"VALIDATE MESH {x:.2f}, {y:.2f} Deviation = {self.deviation:.4f}mm")
            if abs(self.deviation) > maxdeviation:
                remesh = True
                break

        # Move back to horizontal move height
        self._move_helper((None, None, self.horizontal_move_z))

        if remesh:
            gcmd.respond_info(f"VALIDATE MESH: Deviation exceeded {maxdeviation:.4f}mm, remeshing recommended")   
            self.gcode.run_script_from_command("BED_MESH_CALIBRATE")
            if save_config:
                self.gcode.run_script_from_command("SAVE_CONFIG")
        else:
            # Move back to center
            self._move_helper((max_x/2, max_y/2, None))
            gcmd.respond_info(f"VALIDATE MESH: All points within {maxdeviation:.4f}mm deviation")
  

def load_config(config):
    # This returns the object instance; Klipper exposes it as printer.validate_bed_mesh
    return ValidateBedMesh(config)
