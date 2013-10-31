//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// X carriage, carries the extruder
//

include <conf/config.scad>
use <bearing-holder.scad>
use <wade.scad>

hole = 36;
width = hole + 2 * bearing_holder_width(X_bearings);

extruder_width = 26;
function nozzle_x_offset() = 16;                // offset from centre of the extruder


length = 80;
top_thickness = 3;
rim_thickness = 8;
nut_trap_thickness = 8;
corner_radius = 5;
wall = 2; //2.8;

base_offset = nozzle_x_offset();      // offset of base from centre
bar_offset = ceil(max(X_bearings[2] / 2 + rim_thickness + 1,                     // offset of carriage origin from bar centres
                 nut_radius(M3_nut) * 2 + belt_thickness(X_belt) + pulley_inner_radius + 6 * layer_height));

mounting_holes = [[-25, 0], [25, 0], /*[57, 7]*/];

function x_carriage_offset() = bar_offset;
function x_bar_spacing() = hole + bearing_holder_width(X_bearings);
function x_carriage_width() = width;
function x_carriage_length() = length;
function x_carriage_thickness() = rim_thickness;

bar_y = x_bar_spacing() / 2;
bar_x = (length - bearing_holder_length(X_bearings)) / 2;

tooth_height = belt_thickness(X_belt) / 2;
tooth_width = belt_pitch(X_belt) / 2;

lug_width = max(2.5 * belt_pitch(X_belt), 2 * (M3_nut_radius + 2));
lug_depth = X_carriage_clearance + belt_width(X_belt) + belt_clearance + M3_clearance_radius + lug_width / 2;
lug_screw = -(X_carriage_clearance + belt_width(X_belt) + belt_clearance + M3_clearance_radius);
slot_y =  -X_carriage_clearance - (belt_width(X_belt) + belt_clearance) / 2;

function x_carriage_belt_gap() = length - lug_width;

clamp_thickness = 3;
dowel = 5;
dowel_height = 2;

tension_screw_pos = 8;
tension_screw_length = 25;

function x_carriage_lug_width() = lug_width;
function x_carriage_lug_depth() = lug_depth;
function x_carriage_dowel() = dowel;


//
//Helper module for rotation
//
module rotate_about(v,a) {
	translate(v) rotate(a) translate(-v) child(0);
}


module belt_lug(motor_end) {
    height = motor_end ? x_carriage_offset() - pulley_inner_radius:
                         x_carriage_offset() - ball_bearing_diameter(X_idler_bearing) / 2;

    height2 = motor_end ? height + clamp_thickness : height;
    width = lug_width;
    depth = lug_depth;
    extra = 0.5;            // extra belt clearance

    union() {
        difference() {
            union() {
                translate([width / 2, -depth + width / 2])
                    cylinder(r = width / 2, h = height2 + (motor_end ? M3_nut_trap_depth : 0));
                translate([0, -(depth - width / 2)])
                    cube([width, depth - width / 2, height2]);
            }

            translate([width / 2, slot_y, height - belt_thickness(X_belt) / 2 + 2 * eta])                   // slot for belt
                cube([width + 1, belt_width(X_belt) + belt_clearance, belt_thickness(X_belt)], center = true);

            translate([width / 2, lug_screw, height2 + M3_nut_trap_depth + eta])
                nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth);

            // slot to join screw hole
            translate([width / 2,  -(X_carriage_clearance + belt_width(X_belt) + belt_clearance),
                       height - belt_thickness(X_belt) / 2 + extra /2])
                cube([M3_clearance_radius * 2, M3_clearance_radius * 2, belt_thickness(X_belt) + extra], center = true);

            if(motor_end) {
                translate([width, slot_y, (height - belt_thickness(X_belt)) / 2])                       // tensioning screw
                    rotate([90, 0, 90])
                        nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth, true);

                translate([width / 2, slot_y, height - (belt_thickness(X_belt) - extra) / 2 - eta])                 // clearance slot for belt
                    cube([width + 1, belt_width(X_belt) + extra, belt_thickness(X_belt) + extra], center = true);
            }
        }
        if(motor_end)
            //
            // support membrane
            //
            translate([width / 2, lug_screw, height + extra + layer_height / 2 - eta])
                cylinder(r = M3_clearance_radius + 1, h = layer_height, center = true);
        else
            for(i = [-1:1])                                                                                 // teeth to grip belt
                translate([width / 2 + i * belt_pitch(X_belt), slot_y, height- belt_thickness(X_belt) + tooth_height / 2 - eta ])
                    cube([tooth_width, belt_width(X_belt) + belt_clearance + eta, tooth_height], center = true);

    }
}

loop_dia = x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt);
loop_straight = tension_screw_length + wall - loop_dia / 2 - tension_screw_pos - lug_width / 2;
belt_end = 15;

module belt_loop() {
    height = loop_dia + 2 * belt_thickness(X_belt);
    length = loop_straight + belt_end;

    color(belt_color)
    translate([loop_dia / 2, 0, 0])
        linear_extrude(height = belt_width(X_belt), convexity = 5, center = true)
            difference() {
                union() {
                    circle(r = height / 2, center = true);
                    translate([0, -height / 2])
                        square([length, height]);
                }
                union() {
                    circle(r = loop_dia / 2, center = true);
                    translate([0, -loop_dia / 2])
                        square([length, loop_dia]);
                }
                translate([loop_straight, -height])
                    square([100, height]);
            }
}

function x_belt_loop_length() = PI * loop_dia / 2 + loop_straight * 2 + belt_end;

module x_belt_clamp_stl()
{
    height = clamp_thickness;
    width = lug_width;
    depth = lug_depth;

    stl("x_belt_clamp");
    union() {
        difference() {
            union() {
                translate([width / 2, -depth + width / 2])
                    cylinder(r = width / 2, h = height + M3_nut_trap_depth);
                translate([0, -(depth - width / 2)])
                    cube([width, depth - width / 2, height]);
            }
            translate([width / 2, lug_screw, height + M3_nut_trap_depth])
                nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth);
        }
   }
}

module x_belt_grip_stl()
{
    height = clamp_thickness + belt_thickness(X_belt);
    width = lug_width;
    depth = lug_depth;

    stl("x_belt_grip");
    union() {
        difference() {
            linear_extrude(height = height, convexity = 5)
                hull() {
                    translate([width / 2, -depth + width / 2])
                        circle(r = width / 2);
                    translate([0, -(depth - width / 2 - dowel)])
                        square([width, depth - width / 2]);
                }
            translate([width / 2, lug_screw, -1])
                poly_cylinder(r = M3_clearance_radius, h = height + 2);                                // clamp screw hole

            translate([width / 2,  -(X_carriage_clearance + belt_width(X_belt) + belt_clearance), height])  // slot to join screw hole
                cube([M3_clearance_radius * 2, M3_clearance_radius * 2, 2 * belt_thickness(X_belt)], center = true);

            translate([width / 2, slot_y, height - belt_thickness(X_belt) / 2 + 2 * eta])                   // slot for belt
                cube([width + 1, belt_width(X_belt) + belt_clearance, belt_thickness(X_belt)], center = true);
        }
        translate([width / 2, dowel / 2, eta])
            cylinder(r = dowel / 2 - 0.1, h = height + dowel_height);

        for(i = [-1:1])                                                                                     // teeth
            translate([width / 2 + i * belt_pitch(X_belt), slot_y, height - belt_thickness(X_belt) + tooth_height / 2 - eta ])
                cube([tooth_width, belt_width(X_belt) + belt_clearance + eta, tooth_height], center = true);
    }
}
belt_tensioner_rim = X_carriage_clearance;
belt_tensioner_rim_r = 2;
belt_tensioner_height = belt_tensioner_rim + belt_width(X_belt) + belt_clearance + belt_tensioner_rim;

function x_belt_tensioner_radius() = (x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt)) / 2;

module x_belt_tensioner_stl()
{
    stl("x_belt_tensioner");

    flat = 1;
    d = 2 * x_belt_tensioner_radius();

    module d(r, w) {
        difference() {
            union() {
                circle(r, center = true);
                translate([0, -r])
                    square([w + 1, 2 * r]);
            }
            translate([w, - 50])
                square([100, 100]);
        }
    }

    difference() {
        translate([d / 2, 0, 0]) union() {
            linear_extrude(height = belt_tensioner_height)
                d(d / 2, flat);

            linear_extrude(height = belt_tensioner_rim)
                d(d / 2 + belt_tensioner_rim_r, flat);
        }
        translate([wall, 0, belt_tensioner_height / 2])
            rotate([90, 0, 90])
                teardrop(r = M3_clearance_radius, h = 100);
    }
}

duct_wall = 2 * 0.35 * 1.5;
top_thickness = 2;
fan_nut_trap_thickness = 4;
fan_bracket_thickness = 3;

fan_screw = fan_screw(part_fan);
fan_nut = screw_nut(fan_screw);
fan_washer = screw_washer(fan_screw);
fan_screw_length = screw_longer_than(fan_depth(part_fan) + fan_bracket_thickness + fan_nut_trap_thickness + nut_thickness(fan_nut, true) + washer_thickness(fan_washer));
fan_width = max(2 * fan_hole_pitch(part_fan) + screw_boss_diameter(fan_screw), fan_bore(part_fan) + 2 * wall);
fan_screw_boss_r = fan_width / 2 - fan_hole_pitch(part_fan);

front_nut_width = 2 * nut_radius(M3_nut) + wall;
front_nut_height = 2 * nut_radius(M3_nut) * cos(30) + wall;
front_nut_depth = wall + nut_trap_depth(M3_nut);
front_nut_pitch = min((bar_x - bearing_holder_length(X_bearings) / 2 - nut_radius(M3_nut) - 0.3), fan_hole_pitch(part_fan) - 5);
front_nut_z = 3;
front_nut_y = - width / 2 + wall;

gap = 6;
taper_angle = 30;
nozzle_height = 6;
//tony@t3p3 changed duct height to better clear bulldog clip handles on bed
duct_height = 17;
ir = hot_end_duct_radius(hot_end);
or = ir + duct_wall + gap + duct_wall;
skew = nozzle_height * tan(taper_angle);
throat_width = (or + skew) * 2;

fan_x = base_offset;
fan_y = -(width / 2 + fan_width(part_fan) / 2) - (X_carriage_clearance + belt_width(X_belt) + belt_clearance)+3;
fan_z = 20;

fan_y_duct = -fan_y + hot_end_duct_offset(hot_end)[1];

bearing_gap = 2;
bearing_slit = 1;

hole_width = hole - wall - bearing_slit;
hole_offset = (hole - hole_width) / 2;


module base_shape() {
    difference() {
        hull() {
            translate([-length / 2, -width / 2])
                square();

            translate([ length / 2 - 1, -width / 2])
                square();

            translate([bearing_holder_length(X_bearings) / 2 + bearing_gap, width / 2 - corner_radius])
                circle(r = corner_radius, center = true);

            translate([-bearing_holder_length(X_bearings) / 2 - bearing_gap, width / 2 - corner_radius])
                circle(r = corner_radius, center = true);

            translate([-length / 2 + corner_radius, extruder_width / 2 ])
                circle(r = corner_radius, center = true);

            translate([ length / 2 - corner_radius , extruder_width / 2])
                circle(r = corner_radius, center = true);
        }
        translate([0, width / 2 - (bearing_holder_width(X_bearings) + bearing_slit) / 2 + eta])
            square([bearing_holder_length(X_bearings) + 2 * bearing_gap,
                     bearing_holder_width(X_bearings) + bearing_slit ], center = true);
    }
}

module inner_base_shape() {
    difference() {
        square([length - 2 * wall, width - 2 * wall], center = true);
        minkowski() {
            difference() {
                square([length + 1, width + 1], center = true);
                translate([10,0])
                    square([length + 1, 2 * wall + eta], center = true);
                base_shape();

            }
            circle(r = wall, center = true);
        }
    }
}

rrpe_w = 40;  //40mm fan
rrpe_fanheatsink_d=24;
rrpe_coolingblock_d=8;
rrpe_nozzle_z_clearance=17;
rrpe_d = rrpe_fanheatsink_d+rrpe_coolingblock_d;   //fan+cooling block
rrpe_pn_fixing_clearance_r = 6.5/2;
rrpe_pn_fixing_clearance_h = rrpe_coolingblock_d+13;
rrpe_bowden_clearance_r = 4.3/2;
rrpe_bowden_r = 4/2;
rrpe_fixing_clearance_r = 3.3/2;
rrpe_mount_thickness = 7;
rrpe_fixing_spacing = 15/2;
rrpe_z_drop = 10;
rrpe_fixing_length=rrpe_z_drop+rrpe_mount_thickness+5;
rrpe_fixing_depth=rrpe_pn_fixing_clearance_r*2+1.2;
rrpe_bar_offset = -1.5; //off set on Y to fit the extruders in
rrpe_mount_inset = 10; //amount the RRPE mounts are inset from the edge of the Y carriage
rrpe_mount_width = rrpe_fixing_spacing*2 +rrpe_pn_fixing_clearance_r*2+20;
rrpe_d_mount_hole_spacing = 25;

module rrpe_mount(){
	translate([0,0,rrpe_nozzle_z_clearance+rrpe_coolingblock_d-rrpe_z_drop/2])
	difference(){
		//mounting block
		union(){
			hull(){
				translate([0,0,(rrpe_mount_thickness)/2])
					cube([rrpe_fixing_depth,rrpe_pn_fixing_clearance_r*2+4,rrpe_mount_thickness],center=true);	
				translate([0,0,rrpe_mount_thickness+rrpe_z_drop/2])
					cube([rrpe_fixing_depth,rrpe_pn_fixing_clearance_r*2,rrpe_mount_thickness+2],center=true);
			}
			translate([0,0,(rrpe_mount_thickness+rrpe_z_drop)/2])
				cube([rrpe_fixing_depth,rrpe_mount_width,rrpe_mount_thickness+rrpe_z_drop],center=true);
		}	

		//holes
		rrpe_mounting_cutout();
	}

}
module rrpe_mounting_cutout(){
		//bowden cable
		hull(){
				translate([0,0,(rrpe_mount_thickness)/2])
					cylinder(h=rrpe_mount_thickness, r=rrpe_pn_fixing_clearance_r, center=true);
				translate([0,0,rrpe_mount_thickness+3/2])
					cylinder(h=3, r=rrpe_bowden_clearance_r, center=true);
				translate([rrpe_fixing_depth/2,0,(rrpe_mount_thickness)/2])
					cube([rrpe_fixing_depth+0.1,rrpe_pn_fixing_clearance_r*2,rrpe_mount_thickness],center=true);
				translate([rrpe_fixing_depth/2,0,rrpe_mount_thickness+3/2])
					cube([rrpe_fixing_depth+0.1,rrpe_bowden_clearance_r*2,3],center=true);
			}
			translate([0,0,rrpe_mount_thickness+rrpe_z_drop/2])
				cylinder(h=rrpe_z_drop+2, r=rrpe_bowden_clearance_r, center=true);
			translate([rrpe_fixing_depth/2,0,rrpe_mount_thickness+rrpe_z_drop/2])
				cube([rrpe_fixing_depth+0.1,rrpe_bowden_r*2,rrpe_z_drop+2],center=true);
		//m3 fixings
		for(y=[-rrpe_fixing_spacing,rrpe_fixing_spacing])
			translate([0,y,0]){
				translate([0,0,rrpe_mount_thickness+rrpe_z_drop/2])
					cylinder(h=rrpe_z_drop+2, r=rrpe_pn_fixing_clearance_r, center=true);
				translate([0,0,rrpe_mount_thickness/2])
					cylinder(h=rrpe_mount_thickness+5, r=rrpe_fixing_clearance_r, center=true);
				translate([rrpe_fixing_depth/2,0,(rrpe_mount_thickness+rrpe_z_drop)/2])
					cube([rrpe_fixing_depth+0.1,rrpe_fixing_clearance_r*2,rrpe_mount_thickness+rrpe_z_drop+2],center=true);
				translate([rrpe_fixing_depth/2,0,rrpe_mount_thickness+rrpe_z_drop/2])
					cube([rrpe_fixing_depth,rrpe_pn_fixing_clearance_r*2,rrpe_z_drop+2],center=true);
			}
}

module rrpe(){
	//fan+cooling block

	translate([rrpe_fanheatsink_d/2+rrpe_coolingblock_d/2,0,rrpe_nozzle_z_clearance+rrpe_w/2-rrpe_z_drop/2])
		cube([rrpe_fanheatsink_d,rrpe_w,rrpe_w],center=true);
	translate([0,0,rrpe_nozzle_z_clearance+rrpe_coolingblock_d/2-rrpe_z_drop/2])
		cube([rrpe_coolingblock_d,rrpe_w,rrpe_coolingblock_d],center=true);
	translate([0,0,(rrpe_pn_fixing_clearance_h+rrpe_nozzle_z_clearance)/2-rrpe_z_drop/2])
		cylinder(h=rrpe_pn_fixing_clearance_h+rrpe_nozzle_z_clearance, r=rrpe_bowden_clearance_r, center=true);
	for(y=[-1,1])
		translate([0,y*rrpe_fixing_spacing,rrpe_nozzle_z_clearance+rrpe_fixing_length/2-1-rrpe_z_drop/2])
			cylinder(h=rrpe_fixing_length, r=rrpe_fixing_clearance_r, center=true);

}

//use <ribbon_clamp.scad>
connector = DCONN15;
d_face_height = 13;
d_offset = 20;//height above the X_carriage
d_flange_clearance = 0.7;
d_flange_thickness = d_flange_thickness(connector) + d_flange_clearance;
d_flange_width = d_flange_length(connector) + 2 * d_flange_clearance;
d_flange_height = d_flange_width(connector) + d_flange_clearance;
d_wall = 2;
d_slot_height = 11;
d_lid_thickness = 2.4;
d_slot_width = d_slot_length(connector);
d_thickness = 2.4;
d_length= d_thickness + 20;
d_height = d_slot_height / 2 + d_face_height / 2 + d_thickness;
d_width = d_flange_width + 2 * d_wall;
d_nut_slot = nut_thickness(M3_nut) + 0.3;
d_lug_depth = d_nut_slot + 3 * d_wall;
d_lug_width = 2 * nut_flat_radius(M3_nut) + d_wall;
d_lug_height = d_thickness + d_slot_height / 2 + M3_nut_radius;
d_screw_x = d_length - d_wall - No2_pilot_radius;
d_screw_y = (d_width + d_slot_width) / 4;
d_pitch  = d_width + 2 * nut_flat_radius(M3_nut);
d_front_thickness = d_wall + No2_pilot_radius + washer_diameter(M2p5_washer) / 2 + 1;
d_nut_x = d_length + d_flange_thickness + d_wall -d_lug_depth + d_wall;


module d_pcb_mount() {
			difference() {
         		union() {
							//back
							translate([0, d_offset, eta])
								cube([d_length,d_width,d_thickness]);
                    // connector wall
                    translate([d_length - d_front_thickness, d_offset, eta])
                        cube([d_front_thickness + d_flange_thickness + d_wall, d_width, d_height]);

                    // nut lugs
                    translate([d_length + d_flange_thickness + d_wall - d_lug_depth / 2, d_offset + d_width / 2, eta])
                        rounded_rectangle([d_lug_depth, d_width + 2 * d_lug_width, d_lug_height], r = 2, center = false);

                    // d side walls
                    for(y = [0, d_width - d_thickness])
                        translate([0, y + d_offset, eta])
                            cube([d_length, d_thickness, d_height]);
							//riser
							translate([0, 0, eta])
								cube([d_length-d_lug_depth/2,d_offset,d_thickness]);
						
							//base
							difference(){
								translate([0, 0, eta])
									cube([d_length-d_lug_depth/2,d_thickness+nut_thickness(M4_nut),d_thickness+rrpe_d_mount_hole_spacing + nut_flat_radius(M4_nut)*2 + d_thickness*2]);
								//nut traps for mounting
								for(z=[-1,1]) {
									translate([(d_length-d_lug_depth/2)/2,10-nut_thickness(M4_nut),z*rrpe_d_mount_hole_spacing/2 + (d_thickness+rrpe_d_mount_hole_spacing + nut_flat_radius(M4_nut)*2 + d_thickness*2)/2 ])
										rotate([90,0,0])
										nut_trap(M4_clearance_radius, M4_nut_radius, M4_nut_trap_depth);
								}
							}
							
							//bracing

							hull(){
								translate([0, 0, eta])
									cube([d_thickness,d_thickness+nut_thickness(M4_nut),d_thickness+rrpe_d_mount_hole_spacing + nut_flat_radius(M4_nut)*2 + d_thickness*2]);
                        translate([0, d_width - d_thickness + d_offset, eta])
                            cube([d_thickness, d_thickness, d_height]);
							}


                }
						//wiring hole for zip tie
						translate([0,(d_width - d_thickness)/2 + d_offset,d_height+5])
							rotate([90,0,90])
								teardrop_plus(r = 2.2, h = 20, center = true);
					

                translate([d_length, d_offset + (d_width - d_flange_width) / 2, d_thickness + d_slot_height / 2 - d_flange_height / 2])
                    cube([d_flange_thickness, d_flange_width, 20]);                         // slot for flange

                translate([10, d_width / 2 - d_slot_width / 2 + d_offset, d_thickness + eta * 2])  //slot for connector body
                    cube([30, d_slot_width, 20]);


                for(side = [-1, 1]) {
                    translate([d_nut_x + d_nut_slot / 2, d_width / 2 - side * d_pitch / 2 + d_offset, d_thickness + d_slot_height / 2]) //connector screws
                        rotate([90, 0, 90]) {
                            translate([0, nut_flat_radius(M3_nut), 0])
                                cube([nut_flat_radius(M3_nut) * 2, 15, d_nut_slot], center = true);

                            teardrop_plus(r = M3_clearance_radius, h = 20, center = true);
                        }

                    translate([d_screw_x, d_width / 2 - side * d_screw_y + d_offset, d_height + d_lid_thickness])         // lid screws holes
                        rotate([0,0,180])
                            poly_cylinder(r = No2_pilot_radius, h = 12 * 2, center = true);
                }
	}
}

module x_carriage_stl(){
    stl("x_carriage");

    translate([base_offset, 0, top_thickness])
        difference(){
            union(){
                translate([0, 0, rim_thickness / 2 - top_thickness]) {
                    difference() {
                        union() {
                            // base plate
                            difference() {
                                linear_extrude(height = rim_thickness, center = true, convexity = 5)
                                    base_shape();

                                translate([0, 0, top_thickness])
                                    linear_extrude(height = rim_thickness, center = true, convexity = 5)
                                        //difference() {
                                            inner_base_shape();

//Extruder cutout wall
/*
                                            translate([-base_offset, -hole_offset])
                                                rounded_square(hole + 2 * wall,
																							hole_width + 2 * wall,
																								corner_radius + wall);
*/

                                       // }
                            }
                            // ribs between bearing holders
                            for(side = [-1,1])
                                assign(rib_height = bar_offset - X_bar_dia / 2 - 2)
                                translate([0, - bar_y + side * (bearing_holder_width(X_bearings) / 2 - (wall + eta) / 2), rib_height / 2 - top_thickness + eta])
                                    cube([2 * bar_x - bearing_holder_length(X_bearings) + eta, wall + eta, rib_height], center = true);


                            // Front nut traps for large fan mount
                            for(end = [-1, 1])
                                translate([end * (bar_x - bearing_holder_length(X_bearings) / 2 - front_nut_width / 2 + eta) - front_nut_width / 2,
                                            -width / 2 + wall, -top_thickness - eta])
                                     cube([front_nut_width, front_nut_depth, front_nut_height]);


//RRPE mounts
for(x=[-1,1]){
									translate([(x*(length-rrpe_fixing_depth-rrpe_mount_inset)/2),-rrpe_bar_offset,-top_thickness+rrpe_nozzle_z_clearance+rrpe_z_drop+rrpe_coolingblock_d])
										if(x==-1)
											mirror()
												rotate([180,0,0])
													rrpe_mount();
										else
											rotate([180,0,0])
												rrpe_mount();
								}

                         }


                        //Holes for bearing holders
                        translate([0,        bar_y, rim_thickness - top_thickness - eta])
                            cube([bearing_holder_length(X_bearings) - 2 * eta, bearing_holder_width(X_bearings) - 2 * eta, rim_thickness * 2], center = true);

                        translate([- bar_x, -bar_y, rim_thickness - top_thickness - eta])
                            cube([bearing_holder_length(X_bearings) - 2 * eta, bearing_holder_width(X_bearings) - 2 * eta, rim_thickness * 2], center = true);

                        translate([+ bar_x, -bar_y, rim_thickness - top_thickness - eta])
                            cube([bearing_holder_length(X_bearings) - 2 * eta, bearing_holder_width(X_bearings) - 2 * eta, rim_thickness * 2], center = true);
                    }
                }
                //
                // Floating bearing springs
                //
                for(side = [-1, 1])
                    translate([0, bar_y + side * (bearing_holder_width(X_bearings) - min_wall - eta) / 2, rim_thickness / 2 - top_thickness])
                        cube([bearing_holder_length(X_bearings) + 2 * bearing_gap + 1, min_wall, rim_thickness], center = true);


                // raised section for nut traps
                for(x = [-1,1])
                    translate([x*rrpe_d_mount_hole_spacing/2, 0, (nut_trap_thickness - top_thickness) / 2])
                        cylinder(r = 7, h = nut_trap_thickness - top_thickness, center = true);


                // belt lugs
                translate([-length / 2, -width / 2 + eta, -top_thickness])
                    belt_lug(true);

                translate([ length / 2, -width / 2 + eta, -top_thickness])
                    mirror([1,0,0])
                        belt_lug(false);

                //Bearing holders
                translate([0,        bar_y, bar_offset - top_thickness]) rotate([0,0,90]) bearing_holder(X_bearings, bar_offset - eta);
                translate([- bar_x, -bar_y, bar_offset - top_thickness]) rotate([0,0,90]) bearing_holder(X_bearings, bar_offset - eta);
                translate([+ bar_x, -bar_y, bar_offset - top_thickness]) rotate([0,0,90]) bearing_holder(X_bearings, bar_offset - eta);

            }
//Extuder hole and mounts
/*
            translate([-base_offset, 0, 0]) {

                // hole to clear the hot end
                translate([0, - hole_offset])
                    rounded_rectangle([hole, hole_width, 2 * rim_thickness], corner_radius);

                // holes for connecting extruder
                for(xy = mounting_holes)
                    translate([xy[0], xy[1], nut_trap_thickness - top_thickness])
                        nut_trap(M4_clearance_radius, M4_nut_radius, M4_nut_trap_depth);

            }
*/
            //
            // Belt grip dowel hole
            //
            translate([-length / 2 + lug_width / 2, -width / 2 + dowel / 2, -top_thickness])
                cylinder(r = dowel / 2 + 0.1, h = dowel_height * 2, center = true);

            //
            // Front mounting nut traps for fan assemblies
            //
            for(end = [-1, 1])
                translate([end * front_nut_pitch,
                           -width / 2 + front_nut_depth,
                           front_nut_z])
                    rotate([90, 0, 0])
                        intersection() {
                            nut_trap(screw_clearance_radius(M3_cap_screw), M3_nut_radius, M3_nut_trap_depth, true);
                            cylinder(r = M3_nut_radius + 1, h = bearing_holder_width(X_bearings), center = true);
                        }


								//cutout for RRPEs
		
								for(x=[-1,1]){
									translate([(x*(length-rrpe_fixing_depth-rrpe_mount_inset)/2),-rrpe_bar_offset,-top_thickness+rrpe_nozzle_z_clearance+rrpe_z_drop+rrpe_coolingblock_d])
										if(x==-1)
											mirror()
												rotate([180,0,0]){
													translate([0,0,-1.9])
														rrpe();
													translate([0,0,rrpe_nozzle_z_clearance+rrpe_coolingblock_d-rrpe_z_drop/2])
														rrpe_mounting_cutout();
												}
										else
											rotate([180,0,0]){
												translate([0,0,-1.9])
														rrpe();
												translate([0,0,rrpe_nozzle_z_clearance+rrpe_coolingblock_d-rrpe_z_drop/2])
													rrpe_mounting_cutout();
											}
								}
								//holes for D mount
								for(x=[-1,1])
									translate([(x*rrpe_d_mount_hole_spacing/2),0,rrpe_nozzle_z_clearance-rrpe_z_drop-rrpe_coolingblock_d])
										cylinder(h=30,r=2.1,center=true);

								
        }
}

module x_carriage_fan_assembly() {
    assembly("x_carriage_fan_assembly");

    translate([0, 0, nozzle_length + exploded * 15] + hot_end_duct_offset(hot_end))
        rotate([180, 0, 0])
            color(plastic_part_color("lime")) render() x_carriage_fan_duct_stl();


		translate([fan_x, fan_y, fan_z]) {

        color(fan_color) render() fan(part_fan);
        rotate([180, 0, 0]) {
            for(x = [-1, 1])
                for(y = [-1,1])
                    translate([x * fan_hole_pitch(part_fan), y * fan_hole_pitch(part_fan), fan_depth(part_fan) / 2 + (y < 0 ? fan_bracket_thickness : 0)])
                        screw_and_washer(fan_screw, fan_screw_length);
            fan_hole_positions(part_fan) group() {
                rotate([180, 0, 0])
                    translate([0, 0, fan_depth(part_fan) + top_thickness + 30 * exploded])
                        nut(fan_nut, true);
            }

            translate([0, 0, fan_depth(part_fan) / 2])
                color(plastic_part_color("lime")) render() x_carriage_fan_bracket_stl();
        }
    }

    end("x_carriage_fan_assembly");
}

module x_carriage_assembly(show_extruder = true, show_fan = true) {
    if(show_extruder) {
        translate([75, extruder_width / 2, eta])
            rotate([-90,0,180])
                wades_assembly();

        for(end = [-1, 1])
            translate([25 * end, 0, nut_trap_thickness])
                rotate([0, 0, 45])
                    wingnut(M4_wingnut);
    }
    //
    // Fan assembly
    //
    if(show_fan)
        simple_fan_bracket_assembly();

    assembly("x_carriage_assembly");
    color("DarkGoldenrod") render() x_carriage_stl();
    //
    // Fan bracket screws
    //
    for(side = [-1, 1])
        translate([fan_x + side * front_nut_pitch, -width / 2 - fan_bracket_thickness, front_nut_z + top_thickness]) {
            rotate([90, 0, 0])
                screw_and_washer(M3_cap_screw, 10);

            translate([0, fan_bracket_thickness + wall, 0])
                rotate([-90, 0, 0])
                    nut(M3_nut, true);
        }

    translate([base_offset, bar_y, bar_offset]) {
        linear_bearing(X_bearings);
        rotate([0,-90,0])
            scale([bearing_radius(X_bearings) / bearing_ziptie_radius(X_bearings), 1])
                ziptie(small_ziptie, bearing_ziptie_radius(X_bearings));
    }
    for(end = [-1,1])
        translate([base_offset + bar_x * end, -bar_y, bar_offset]) {
            linear_bearing(X_bearings);
            rotate([90,-90,90])
                scale([bearing_radius(X_bearings) / bearing_ziptie_radius(X_bearings), 1])
                    ziptie(small_ziptie, bearing_ziptie_radius(X_bearings));
        }
    //
    // Idler end belt clamp
    //
    translate([length / 2 + base_offset, -width / 2, x_carriage_offset() - ball_bearing_diameter(X_idler_bearing) / 2]) {
        mirror([1,0,0])
            color(x_belt_clamp_color) render() x_belt_clamp_stl();
        translate([-lug_width / 2, lug_screw, clamp_thickness])
            nut(M3_nut, true);
    }

    translate([length / 2 + base_offset - lug_width / 2, -width / 2 + lug_screw, 0])
        rotate([180, 0, 0])
            screw_and_washer(M3_cap_screw, 20);
    //
    // Motor end belt clamp
    //
    translate([-length / 2 + base_offset, -width / 2, x_carriage_offset() - pulley_inner_radius])
        translate([lug_width / 2, lug_screw, clamp_thickness])
            nut(M3_nut, true);

    translate([-length / 2 + base_offset, -width / 2, -(clamp_thickness + belt_thickness(X_belt))]) {
        color(x_belt_clamp_color) render() x_belt_grip_stl();
        translate([lug_width / 2, lug_screw, 0])
            rotate([180, 0, 0])
                screw_and_washer(M3_cap_screw, 25);
    }
	 
    translate([-length / 2 + base_offset - tension_screw_pos, -width / 2 + slot_y, (x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt)) /2]) {
        rotate([0, -90, 0])
            screw(M3_cap_screw, tension_screw_length);    // tensioning screw

        translate([tension_screw_length + wall, belt_tensioner_height / 2, 0])
            rotate([90, 180, 0])
                color(x_belt_clamp_color) render() x_belt_tensioner_stl();

        translate([tension_screw_length + wall, 0, 0])
            rotate([90, 180, 0])
                belt_loop();
    }
		//
		// Potential Belt Colision Area
		// (uncomment to view)
/*
		translate([base_offset, -width / 2 + slot_y,x_carriage_offset()/2 + ball_bearing_diameter(X_idler_bearing) + belt_thickness(X_belt)])
				%#cube([length+40,6.5,6.5],center=true);
*/
		
    translate([-length / 2 + base_offset + lug_width - M3_nut_trap_depth, -width / 2 + slot_y, (x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt)) /2])
        rotate([90, 0, 90])
            nut(M3_nut, false);   // tensioning nut

    end("x_carriage_assembly");
}


rotx=-60; //angle of rotation of the fan
pitch = fan_hole_pitch(part_fan);

module simple_fan_bracket_assembly(){
	
	translate([fan_x, fan_y, fan_z])
		rotate([rotx,0,0])
        	color(fan_color) render() fan(part_fan);
   translate([fan_x, fan_y, fan_z])
		rotate([rotx,0,0])
		translate([0,0,-(fan_depth(part_fan))/2])
        rotate([180, 0, 0])
            color("OrangeRed") render()
						simple_fan_bracket_stl();

}

module simple_fan_bracket_stl(){
	t = fan_bracket_thickness;
    h = fan_z - fan_depth(part_fan) / 2;
    boss_r = washer_diameter(fan_washer) / 2 + 2.5;
    w = front_nut_pitch * 2 + washer_diameter(M3_washer) + 2 * t;
    rad = sqrt(2) * pitch - boss_r;

    difference() {
        union() {
            hull() {
                translate([- w / 2, fan_y +width/ 2, -fan_depth(part_fan)-t-M4_nut_trap_depth])
                    cube([w, 1, t+M4_nut_trap_depth]);

                for(side = [-1, 1])
                    translate([side * pitch, -pitch, -fan_depth(part_fan)-t-M4_nut_trap_depth])
                        cylinder(r = boss_r, h = t+M4_nut_trap_depth);
            }
			
            translate([- w / 2, fan_y + width / 2+10, -fan_depth(part_fan)-15+eta])
					rotate([-rotx,0,0])
                cube([w, 12, 17]);			
        }
        //
        // clear the fan
        //
			translate([0,0,fan_depth(part_fan)])
            hull() {
                translate([- w / 2, fan_y +width/ 2-5, -fan_depth(part_fan)*2])
                    cube([w, 1, fan_depth(part_fan)-0.1]);

                for(side = [-1, 1])
                    translate([side * pitch, -pitch, -fan_depth(part_fan)*2])
                        cylinder(r = boss_r, h = fan_depth(part_fan)-0.1);
            }
        			cylinder(r = rad, h = 100, center = true);

        for(side = [-1, 1]) {
            //
            // mounting screw holes
            //
            translate([side * front_nut_pitch, -15, max(h - top_thickness - front_nut_z , fan_bracket_thickness + washer_diameter(M3_washer) / 2) ])
                rotate([90-rotx, 0, 0]){
                    vertical_tearslot(h = 100, l = h, r = M3_clearance_radius, center = true);
							vertical_tearslot(h = 57, l = h, r = 0.2+washer_diameter(M3_washer) / 2, center = true);
				}
            //
            // fan screw holes
            //
          translate([side * pitch, -pitch,-fan_depth(part_fan)-M4_nut_trap_depth/2-t])
						nut_trap(screw_clearance_radius(fan_screw), M4_nut_radius, M4_nut_trap_depth, true);
        }
    }

}



module x_carriage_rrpe_assembly(){

	x_carriage_assembly(false,true);
	translate([-3.5,9.5,0])
		rotate([-90,0,270])
		color(plastic_part_color("LightBlue")) render() d_pcb_mount();
		rotate([180,0,0])
	for(x=[-1,1]){
		translate([base_offset+x*(length-rrpe_fixing_depth-rrpe_mount_inset)/2,rrpe_bar_offset,-(rrpe_nozzle_z_clearance+rrpe_z_drop+rrpe_coolingblock_d+3)])
		if(x==-1)
			mirror()
				%rrpe();
		else
			%rrpe();
	}
}

module x_carriage_rrpe_stl() {
		rotate([0,0,0])
			x_carriage_stl();

		translate([width-15,-30,0])
		rotate([0,0,0])
			d_pcb_mount();
		translate([15,-72,-11])
			rotate([180,0,0])
				simple_fan_bracket_stl();
	translate([-width/2,0,0]){
   // x_belt_clamp_stl();
   // translate([0,-(lug_depth+7),0]) x_belt_grip_stl();
   // translate([6, 8, 0]) rotate([0, 0, -90]) x_belt_tensioner_stl();
	}

}


if(0) 
	x_carriage_rrpe_assembly();
else
    x_carriage_rrpe_stl();

