//
// Mendel90 LC version 
// tony@think3dprint3d.com
// blog.think3dprint3d.com
//
// GNU GPL v2
//
// based on the Mendel90 by
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Top bottom limit switch bracket for Mendel 90 LC
//
include <conf/config.scad>


wall = 2;
thickness = 5;

screw_slot_length = 10;
screw_spacing = 20;
switch_boss=7;
switch_mount_x=8.8;
switch_mount_y=10;
screw_mount_y=max(switch_mount_x,M3_nut_radius*2+wall);
screw_mount_x=4+wall;
screw_mount_z=switch_boss+screw_spacing+M3_nut_radius*2+wall;
support_taper=5;

module z_top_limit_switch_bracket_LC_stl() {
	rotate([-90,0,0]){
    stl("z_top_limit_switch_bracket_LC");
    difference() {
        union() {
            //
            // Boss for switch screws
            //
					rotate([90,0,0])
            translate([switch_mount_y, -(microswitch_hole_y_offset() - switch_boss / 2), -microswitch_thickness() / 2])
                hull() {
                    microswitch_hole_positions()
                        cylinder(h = switch_mount_x, r = switch_boss / 2);
                    translate([-switch_mount_y, microswitch_hole_y_offset() - switch_boss / 2, microswitch_thickness() / 2])
                        cube([1, switch_boss, switch_mount_x]);
                 }
            //
            // Screw slot
            //
					translate([0, -switch_mount_x, 0])
					hull(){
						cube([screw_mount_x+support_taper,screw_mount_y,1]);
						translate([0, 0, screw_mount_z])
								cube([screw_mount_x,screw_mount_y,1]);
					}
            
        

        }
        
        for(z=[-screw_spacing/2,screw_spacing/2])
        translate([screw_mount_x+2, -switch_mount_x/2,(switch_boss+screw_mount_z)/2+z])
            rotate([0, 90, 180])
                nut_trap(M3_clearance_radius, M3_nut_radius, screw_head_height(M3_hex_screw)+2, true,false);
			rotate([90,0,0])
			translate([switch_mount_y, -(microswitch_hole_y_offset() - switch_boss / 2),0])
        microswitch_hole_positions()
            poly_cylinder(h = 100, r = No2_pilot_radius, center = true);
    }
	}
}

module z_top_limit_switch_LC_assembly() {
 assembly("z_top_limit_switch_LC_assembly");
    pos = 0;
    screw_length = 16;
    //washer_thickness = hinge_length / washers;
rotate([0,0,-90]){
    translate([0, 0, pos]) {
            color(z_limit_switch_bracket_color) render()
						rotate([90,0,0])
                z_top_limit_switch_bracket_LC_stl();
			for(z=[-screw_spacing/2,screw_spacing/2])
        translate([-6.3+2  -screw_head_height(M3_hex_screw), -switch_mount_x/2, (switch_boss+screw_mount_z)/2+z])
            rotate([0, 90, 180])
                screw_and_washer(M3_cap_screw, 16);
			for(z=[-screw_spacing/2,screw_spacing/2])
        translate([screw_mount_x-2 , -switch_mount_x/2, (switch_boss+screw_mount_z)/2+z])
            rotate([0, -90, 180])
                nut(M3_nut, true);
			rotate([90, 0, 0]) 
        translate([switch_mount_y, -(microswitch_hole_y_offset() - switch_boss / 2), -microswitch_thickness() / 2])
            {
					if(exploded)
						translate([5.2,-16,-8]) 
							rotate([0,0,180])
                		microswitch();
					else
						translate([5.2,-16,0]) 
							rotate([0,0,180])
                		microswitch();
               microswitch_hole_positions()
							translate([0,0,-microswitch_thickness()])
								rotate([180,0,0])
                    	screw_and_washer(No2_screw, 13);

            }
    }
}
 end("z_top_limit_switch_LC_assembly");
}

if(1)
    z_top_limit_switch_LC_assembly();
else
    z_top_limit_switch_bracket_LC_stl();
