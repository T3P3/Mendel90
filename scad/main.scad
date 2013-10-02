//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// main assembly
//
include <conf/config.scad>
use <bed.scad>
use <z-screw_pointer.scad>
use <bar-clamp.scad>
use <pulley.scad>
use <y-bearing-mount.scad>
use <y-idler-bracket.scad>
use <y-belt-anchor.scad>
use <z-coupling.scad>
use <z-motor-bracket.scad>
use <z-limit-switch-bracket.scad>
use <z-top-limit-switch-bracket-for-lc-mendel.scad>
use <fan-guard.scad>
use <wade.scad>
use <cable_clip.scad>
use <pcb_spacer.scad>
use <ATX_PSU_brackets.scad>
use <spool_holder.scad>
use <tube_cap.scad>
use <d-motor_bracket.scad>
use <lc_cutout.scad>
include <positions.scad>


X = 0 * X_travel / 2; // - limit_switch_offset;
Y = 0 * Y_travel / 2; // - limit_switch_offset;
Z = 0.5 * Z_travel;


//
// X axis
//
X_bar_length = motor_end - idler_end + 2 * x_end_bar_length();
module x_axis_assembly(show_extruder) {
    X_belt_gap = x_carriage_belt_gap() - 15;

    assembly("x_axis_assembly");

    for(side = [-1,1])
        translate([(idler_end + motor_end) / 2 + eta, side * x_bar_spacing() / 2, Z + Z0])
            rotate([0,90,0])
                rod(X_bar_dia, X_bar_length);

    translate([-X + X_origin, 0, Z + Z0 + x_carriage_offset()])
        rotate([180, 0, 180])
            x_carriage_assembly(show_extruder);

    color(belt_color)
        translate([0, x_belt_offset(), Z + Z0])
            rotate([90, 0, 0]) render()
                union() {
                    difference() {
                        twisted_belt(X_belt, idler_end + x_idler_offset(), 0, ball_bearing_diameter(X_idler_bearing) / 2,
                            motor_end - x_motor_offset(), 0, pulley_ir(pulley_type), X_belt_gap - x_belt_loop_length());

                        translate([-X + X_origin - nozzle_x_offset() + (x_carriage_belt_gap() - X_belt_gap) / 2,
                                pulley_inner_radius + belt_thickness(X_belt) / 2, 0])
                            cube([X_belt_gap, belt_thickness(X_belt) * 3, belt_width(X_belt) * 2], center = true);
                    }
                }

    end("x_axis_assembly");
}
//
// X motor with wiring
//
module x_motor_assembly() {
    assembly("x_motor_assembly");
    z_cable_extra = 100;
    z_cable_travel = (Z_travel + (ribbon_clamp_z - (Z_travel + Z0 + x_end_ribbon_clamp_z()))) * 2;

    pmax = [-X_travel / 2 + X_origin - motor_end, 0, x_carriage_offset()] + extruder_connector_offset();

    mirror([1,0,0])
        x_end_assembly(true);

    translate([-x_motor_offset(),
               gantry_setback - sheet_thickness(frame) / 2 + ribbon_clamp_slot_depth() - cable_strip_thickness,
               ribbon_clamp_z - (Z + Z0) + ribbon_clamp_width(frame_screw) / 2])
        rotate([0, -90, 180])
            cable_strip(
                x_end_ways,
                z_cable_strip_depth,
                z_cable_travel,
                Z + Z0 + x_end_ribbon_clamp_z() - ribbon_clamp_z,
                z_cable_extra
            );

    elliptical_cable_strip(
        extruder_ways,
        x_end_extruder_ribbon_clamp_offset(),
        [-X + X_origin - motor_end, 0, x_carriage_offset()] + extruder_connector_offset(),
        pmax
    );

    translate([-X + X_origin - motor_end + cable_strip_thickness, - ribbon_clamp_width(M3_cap_screw), x_carriage_offset()] + extruder_connector_offset())
        rotate([-90, 180, 0])
            d_shell_assembly(NEMA17);

    ribbon_cable(x_end_ways,
        10                      // Width of D type
        + 12                    // To back of shell
        + elliptical_cable_strip_length(x_end_extruder_ribbon_clamp_offset(), pmax)
        + 60                    // Across the X motor bracket
        + cable_strip_length(z_cable_strip_depth, z_cable_travel, z_cable_extra)
        + 5                     // Through the slot
        + 180                   // Down back of gantry
        + 90                    // Across to Melzi
        + 5);                   // Strip

    end("x_motor_assembly");
}
//
// Z axis
//
Z_motor_length = NEMA_length(Z_motor);
Z_bar_length = height - Z_motor_length - base_clearance + sheet_thickness(frame)/2;  //modified for LC M90 Z bar lengths

module z_end(motor_end) {
    Z_screw_length = Z0 + Z_travel + anti_backlash_height() + axis_end_clearance
        - (Z_motor_length + NEMA_shaft_length(Z_motor) + 2);

    if(!motor_end && bottom_limit_switch)
        translate([-z_bar_offset(), gantry_setback, Z0 - x_end_thickness() / 2])
            z_limit_switch_assembly();
    if(!motor_end && top_limit_switch)
        translate([-z_bar_offset()-2.2, gantry_setback, height_LC-z_top_side_bracket_height-49 -110])
            z_top_limit_switch_LC_assembly();

    translate([-z_bar_offset(), 0, Z_motor_length]) {

        z_motor_assembly(gantry_setback, motor_end);

        translate([0, 0, NEMA_shaft_length(Z_motor) + 2 + Z_screw_length / 2]) {
            studding(d = Z_screw_dia, l = Z_screw_length);

            translate([0, 0, -Z_screw_length / 2 + z_coupling_length() / 2 - 1])
                render() z_screw_pointer_stl();
        }

        //
        // lead nut
        //
        translate([0, 0, Z + Z0 - x_end_thickness() / 2 + nut_thickness(Z_nut) - Z_motor_length])
            rotate([180, 0, 0])
                nut(Z_nut, brass = true);

        translate([z_bar_offset(), 0, Z_bar_length / 2])
            rod(Z_bar_dia, Z_bar_length);
    }
}

module z_axis_assembly() {
    assembly("z_axis_assembly");

    translate([motor_end, 0, 0])
        mirror([1,0,0])
            z_end(true);

    translate([idler_end, 0, 0])
        z_end(false);

    translate([motor_end, 0, Z + Z0])
        x_motor_assembly();

    translate([idler_end, 0, Z + Z0])
        x_end_assembly(false);

    end("z_axis_assembly");
}

//
// Y axis
//
Y_bar_length =  base_depth - 2 * base_clearance;

Y_bar_length2 = Y_travel + limit_switch_offset + bearing_mount_length(Y_bearings) + 2 * bar_clamp_depth + axis_end_clearance + bar_clamp_switch_y_offset();

Y_bar_spacing = Y_carriage_width - bearing_mount_width(Y_bearings);
Y_bearing_inset = bearing_mount_length(Y_bearings) / 2 + bar_clamp_depth + axis_end_clearance;

Y_belt_motor_offset = 13 + belt_width(Y_belt) / 2;

Y_belt_line = X_origin - ribbon_clamp_slot(bed_ways) / 2 - y_belt_anchor_width() / 2 - 5;

Y_motor_end = -base_depth / 2 + y_motor_bracket_width() / 2 + base_clearance;
Y_idler_end =  base_depth / 2 - y_idler_offset() - base_clearance - y_idler_travel();
Y_belt_anchor_m = Y_motor_end + NEMA_width(Y_motor) / 2 + Y_travel / 2;
Y_belt_anchor_i = Y_idler_end - y_idler_clearance() - Y_travel / 2;
Y_belt_end = y_belt_anchor_depth() / 2 + 15;
Y_belt_gap = Y_belt_anchor_i - Y_belt_anchor_m - 2 * Y_belt_end;


//
// supported bar
//
module rail(length, height, endstop) {
    translate([0, 0, height])
        rotate([90,0,0])
            rod(Y_bar_dia, length);

    for(end = [-1, 1])
        translate([0, end * (length / 2 - bar_clamp_depth / 2), 0])
            rotate([0, 0, 90])
                y_bar_clamp_assembly(Y_bar_dia, height, bar_clamp_depth, endstop && end == 1);
}

Y2_rail_offset = (bar_clamp_switch_y_offset() - axis_end_clearance) / 2;

module y_rails() {
    translate([-Y_bar_spacing / 2, 0, 0])
        rail(Y_bar_length, Y_bar_height);

    rotate([0,0,180])
        translate([-Y_bar_spacing / 2, Y2_rail_offset, 0])
            rail(Y_bar_length2, Y_bar_height, true);
}

module rail_holes(length) {
    for(end = [-1, 1])
        translate([0, end * (length / 2 - bar_clamp_depth / 2), 0])
            rotate([0, 0, 90])
                bar_clamp_holes(Y_bar_dia, true)
                    base_screw_hole();
}

module y_rail_holes() {
    translate([-Y_bar_spacing / 2, 0, 0])
        rail_holes(Y_bar_length);

    rotate([0,0,180])
        translate([-Y_bar_spacing / 2, Y2_rail_offset, 0])
             rail_holes(Y_bar_length2);
}

module y_carriage() {
    difference() {
        sheet(Y_carriage, Y_carriage_width, Y_carriage_depth, [3,3,3,3]);

        translate([0, ribbon_clamp_y, 0])
            rotate([180, 0, 0])
                ribbon_clamp_holes(bed_ways, cap_screw)
                    cylinder(r = screw_clearance_radius(cap_screw), h = 100, center = true);

        translate([0, Y_carriage_depth / 2, 0])
            cube([ribbon_clamp_slot(bed_ways) + 2, ribbon_clamp_width(cap_screw), sheet_thickness(Y_carriage) + 1], center = true);

        translate([Y_bar_spacing / 2, 0, 0])
            rotate([0,180,0])
                bearing_mount_holes()
                    cylinder(r = screw_clearance_radius(cap_screw), h = 100, center = true);

        for(end = [-1, 1])
            translate([-Y_bar_spacing / 2, end * (Y_carriage_depth / 2 - Y_bearing_inset), 0])
                rotate([0,180,0])
                    bearing_mount_holes()
                        cylinder(r = screw_clearance_radius(cap_screw), h = 100, center = true);

        for(end = [[Y_belt_anchor_m, 0], [Y_belt_anchor_i, 180]])
            translate([Y_belt_line - X_origin, end[0], 0])
                rotate([0, 180, end[1]])
                    y_belt_anchor_holes()
                        cylinder(r = M3_clearance_radius, h = 100, center = true);

        for(x = [-bed_holes / 2, bed_holes / 2])
            for(y = [-bed_holes / 2, bed_holes / 2])
                translate([x, y, 0])
                    cylinder(r = M3_clearance_radius-0.2, h = 100, center = true);
        //additional central mounting hole for easier levelling
        translate([0, -bed_holes / 2, 0])
          cylinder(r = M3_clearance_radius-0.2, h = 100, center = true);
    }
}

module y_heatshield() {
    width =  Y_carriage_width - 2 * bar_clamp_tab;
    difference() {
        group() {
            difference() {
                sheet(Cardboard, width, Y_carriage_depth);

                translate([Y_bar_spacing / 2, 0, 0])
                    rotate([0,180,0])
                        bearing_mount_holes()
                            cube([10,10, 100], center = true);

                for(end = [-1, 1])
                    translate([-Y_bar_spacing / 2, end * (Y_carriage_depth / 2 - Y_bearing_inset), 0])
                        rotate([0,180,0])
                            bearing_mount_holes()
                                cube([10,10, 100], center = true);

                for(end = [[Y_belt_anchor_m, 0], [Y_belt_anchor_i, 180]])
                    translate([Y_belt_line - X_origin, end[0], 0])
                        rotate([0, 180, end[1]])
                            hull()
                                y_belt_anchor_holes()
                                    cube([10, 10, 100],center =true);
            }
            translate([0, 0, sheet_thickness(Cardboard) / 2])
                taped_area(FoilTape, 50, width, Y_carriage_depth, 5);
        }
        translate([0, Y_carriage_depth / 2, 0])
            cube([ribbon_clamp_length(bed_ways, cap_screw), 70, 100], center = true);
    }
}


module y_carriage_assembly(solid = true) {
    carriage_bottom = Y_carriage_height - sheet_thickness(Y_carriage) / 2;
    carriage_top = Y_carriage_height + sheet_thickness(Y_carriage) / 2;

    assembly("y_carriage_assembly");

    translate([Y_bar_spacing / 2, 0, Y_bar_height])
        rotate([0,180,0])
            y_bearing_assembly(Y_bearing_holder_height);

    for(end = [-1, 1])
        translate([-Y_bar_spacing / 2, end * (Y_carriage_depth / 2 - Y_bearing_inset), Y_bar_height])
            rotate([0,180,0])
                y_bearing_assembly(Y_bearing_holder_height);

    for(end = [[Y_belt_anchor_m, 0, false], [Y_belt_anchor_i, 180, true]])
        translate([Y_belt_line - X_origin, end[0], carriage_bottom])
            rotate([0, 180, end[1]])
                y_belt_anchor_assembly(Y_belt_clamp_height, end[2]);

    translate([0, ribbon_clamp_y, carriage_top + ribbon_clamp_thickness()])
        rotate([180, 0, 0])
            color(ribbon_clamp_color) render() ribbon_clamp(bed_ways, cap_screw, nutty = true);

    translate([0, ribbon_clamp_y, carriage_bottom])
        rotate([180, 0, 0])
            ribbon_clamp_assembly(bed_ways, cap_screw, 20, sheet_thickness(Y_carriage) + ribbon_clamp_thickness(true), false, false);


    translate([0, 0, Y_carriage_height + eta * 2])
        if(solid)
            y_carriage();
        else
            %y_carriage();

    end("y_carriage_assembly");
}

module print_bed_assembly(show_bed = true, show_heatshield = true) {
    assembly("print_bed_assembly");
    //
    // Y carriage
    //
    translate([X_origin, Y + Y0, 0]) {

        translate([0, 0, Y_carriage_height + sheet_thickness(Y_carriage) / 2]) {
            if(show_bed) {
                bed_assembly(Y);
                if(show_heatshield)
                    translate([0, 0, sheet_thickness(Cardboard) / 2])
                        y_heatshield();
            }
        }

        translate([0, -(Y + Y0) + ribbon_clamp_y + ribbon_clamp_width(base_screw) / 2, ribbon_clamp_slot_depth() - cable_strip_thickness])
            rotate([90, 0, 90])
                cable_strip(
                    bed_ways,
                    y_cable_strip_depth,
                    Y_travel,
                    Y
                );

        y_carriage_assembly(show_bed);

    }
    end("print_bed_assembly");
}

module y_axis_assembly(show_bed = true, show_heatshield = true, show_carriage = true) {
    assembly("y_axis_assembly");

    translate([X_origin, 0, 0])
        y_rails();

    translate([Y_belt_line, Y_motor_end, y_motor_height()]) rotate([90,0,-90]) {
        color(belt_color)
        render() difference() {
            twisted_belt(Y_belt,
                         Y_motor_end - Y_idler_end,
                         pulley_inner_radius - ball_bearing_diameter(Y_idler_bearing) / 2,
                         ball_bearing_diameter(Y_idler_bearing) / 2,
                         0, 0, pulley_ir(pulley_type), Y_belt_gap);
            translate([-(Y_belt_anchor_i + Y_belt_anchor_m) / 2 + Y_motor_end - Y0 - Y, pulley_inner_radius + belt_thickness(Y_belt)/2, 0])
                cube([Y_belt_gap, belt_thickness(Y_belt) * 2, belt_width(Y_belt) * 2], center = true);
        }

        translate([0, 0, -Y_belt_motor_offset])
            y_motor_assembly();
    }
    translate([Y_belt_line, Y_idler_end, 0])
        y_idler_assembly();

    if(show_carriage)
        print_bed_assembly(show_bed, show_heatshield);

    end("y_axis_assembly");
}

module y_axis_screw_holes() {
    translate([X_origin, 0, 0]) {
        y_rail_holes();

        translate([Y_belt_line - X_origin, Y_idler_end, 0])
            y_idler_screw_hole();

        translate([Y_belt_line - X_origin, Y_motor_end, y_motor_height()])
            rotate([90,0,-90])
                translate([0, 0, -Y_belt_motor_offset])
                    y_motor_bracket_holes()
                        base_screw_hole();
    }
}
//
// List of cable clips
//

z_gantry_wire_height = height - base_clearance - fixing_block_width() -fixing_block_height() -
                                               base_clearance - cable_clip_extent(base_screw, endstop_wires);

bed_wires_y = Y0 + Y_bar_length2 / 2 - Y2_rail_offset + cable_clip_extent(base_screw, thermistor_wires);

Y_cable_clip_x = base_width / 2 - right_w - cable_clip_extent(base_screw, motor_wires);
Y_front_cable_clip_y = -Y_bar_length2 / 2 + 25;
Y_back_cable_clip_y = gantry_Y + sheet_thickness(frame) + fixing_block_height() - 5;

cable_clips = [ // cable1, cable2 , position, vertical, rotation

    // near to the Y limit switch
    [endstop_wires, motor_wires,
        [Y_cable_clip_x, Y_front_cable_clip_y, 0], false, 0],
    // at the foot of the gantry
    [endstop_wires, motor_wires,
        [Y_cable_clip_x, Y_back_cable_clip_y, 0], false, 0],
    // bed wires
    [bed_wires, thermistor_wires,
        [20, bed_wires_y, 0], false, -90],
    // Z axis left
    [endstop_wires, fan_motor_wires,
        [left_stay_x - 15, gantry_Y + sheet_thickness(frame), z_gantry_wire_height-10], true, 90],

    // Z axis right
    [endstop_wires, fan_motor_wires,
        [right_stay_x + 15, gantry_Y + sheet_thickness(frame), z_gantry_wire_height-10], true, 90],

];

module place_cable_clips(holes = false) {
    for(clip = cable_clips) {
        translate(clip[2])
            rotate([clip[3] ? -90 : 0, 0, 0]) rotate([0, 0, clip[4]])
                if(holes)
                    cable_clip_hole(clip[3], clip[0], clip[1]);
                else
                    cable_clip_assembly(clip[3], clip[0], clip[1]);
    }
}

//
// Frame
//
window_corner_rad = 5;

module fixing_blocks(upper = false, holes = false) {
    w = fixing_block_width();
    h = fixing_block_height();
    t = sheet_thickness(frame);

    if(upper) {     // all screws into frame
        translate([left_stay_x + t / 2, gantry_Y + t, stay_height - base_clearance - h - w / 2]) // top
            rotate([0,-90,-90])
                child();

        translate([right_stay_x - t / 2, gantry_Y + t, stay_height - base_clearance - h - w / 2]) // top
            rotate([0,90, 90])
                child();

        translate([left_stay_x + t / 2, gantry_Y + t, base_clearance + h + w / 2])              // front
            rotate([0,-90,-90])
                child();

        translate([right_stay_x - t / 2, gantry_Y + t, base_clearance + h + w / 2])              // front
            rotate([0,90, 90])
                child();
    }
    else {  // one screw in the base
        for(x = [-base_width/2 + base_clearance + w /2,
                  base_width/2 - base_clearance - w /2,
                 -base_width/2 - base_clearance - w /2 + left_w,
                  right_stay_x + sheet_thickness(frame) / 2 + w / 2 + base_clearance])
            translate([x, gantry_Y + t, 0])
                child();

        translate([left_stay_x + t / 2, base_depth / 2 - base_clearance - w / 2, 0]) // back
            rotate([0, 0,-90])
                child();

        translate([right_stay_x - t / 2, base_depth / 2 - base_clearance - w / 2, 0]) // back
            rotate([0,0, 90])
                child();

        // extra holes for bars
        if(holes && base_nuts) {
            translate([left_stay_x + t / 2, -base_depth / 2 + base_clearance + w / 2, 0]) // front
                rotate([0, 0,-90])
                    child();

            translate([right_stay_x - t / 2, -base_depth / 2 + base_clearance + w / 2, 0]) // front
                rotate([0,0, 90])
                    child();
        }

    }
}

module fixing_block_holes() {
    fixing_blocks(upper = false, holes = true)
        group() {
            fixing_block_v_hole(0)
                base_screw_hole();
            fixing_block_h_holes(0)
                frame_screw_hole();
        }

    fixing_blocks(upper = true, holes = true)
        group() {
            fixing_block_v_hole(0)
                frame_screw_hole();
            fixing_block_h_holes(0)
                frame_screw_hole();
        }
}

Y_motor_stay_hole_y = gantry_Y + sheet_thickness(frame) + fixing_block_height() + motor_wires_hole_radius;

//LC Z Assembly dimensions
m_width = ceil(NEMA_width(Z_motor));
z_bracket_d = gantry_setback + m_width / 2;
z_top_bracket_width = Z_bar_dia+2*sheet_thickness(frame)+42;
z_top_bracket_depth = gantry_setback+Z_bar_dia/2+4;
z_top_side_bracket_height = lc_fixing_offset*2-8;
z_top_bracket_offset = 10;
lc_back_top_z = height -gantry_thickness+10;

hinge_x_cutout = 30+sheet_thickness(PMMA6);
hinge_y_cutout = 4;
hinge_z_cutout = 25;
hinge_hole_a_x = 32;
hinge_hole_b_x = 24;
hinge_hole_a_y = hinge_y_cutout+19;
hinge_hole_b_y = hinge_y_cutout+6;

module frame_base() {
    difference() {
        translate([0,0, -sheet_thickness(base) / 2])
            sheet(base, base_w_LC, base_d_LC, [base_corners, base_corners, base_corners, base_corners]);            // base
        //frame stay LC screw face slots
        translate([left_stay_x,gantry_Y+ sheet_thickness(frame)+lc_fixing_offset,-sheet_thickness(base) / 2])
            lc_screw_side_cutout(sheet_thickness(base));
        translate([left_stay_x,gantry_Y+ sheet_thickness(frame)+stay_depth_LC-lc_fixing_offset,-sheet_thickness(base) / 2])
            lc_screw_side_cutout(sheet_thickness(base));
        translate([right_stay_x,gantry_Y+ sheet_thickness(frame)+lc_fixing_offset,-sheet_thickness(base) / 2])
            lc_screw_side_cutout(sheet_thickness(base));
        translate([right_stay_x,gantry_Y+ sheet_thickness(frame)+stay_depth_LC-lc_fixing_offset,-sheet_thickness(base) / 2])
            lc_screw_side_cutout(sheet_thickness(base));
        //Gantry LC screw face slots
        translate([base_width/2-lc_fixing_offset,gantry_Y + sheet_thickness(frame) / 2,-sheet_thickness(base) / 2])
          rotate([0,0,90])
            lc_screw_side_cutout(sheet_thickness(base));
        translate([-base_width/2+lc_fixing_offset,gantry_Y + sheet_thickness(frame) / 2,-sheet_thickness(base) / 2])
          rotate([0,0,90])
            lc_screw_side_cutout(sheet_thickness(base));
        translate([left_stay_x+lc_fixing_offset,gantry_Y + sheet_thickness(frame) / 2,-sheet_thickness(base) / 2])
          rotate([0,0,90])
            lc_screw_side_cutout(sheet_thickness(base));
        translate([right_stay_x+lc_fixing_offset,gantry_Y + sheet_thickness(frame) / 2,-sheet_thickness(base) / 2])
          rotate([0,0,90])
            lc_screw_side_cutout(sheet_thickness(base));
        //Z motor bracket slots
        for(x = [1,-1]){
          translate([idler_end-z_bar_offset()+ x*(2+z_bracket_d/2-sheet_thickness(frame)/2), Y0,-sheet_thickness(base) / 2])
             lc_screw_side_cutout(sheet_thickness(frame));
          translate([motor_end+z_bar_offset()+ x*(2+z_bracket_d/2-sheet_thickness(frame)/2), Y0,-sheet_thickness(base) / 2])
             lc_screw_side_cutout(sheet_thickness(frame));
			}              
        //Back Box fixing holes
        for(x=[right_stay_x-lc_fixing_offset,(left_stay_x + right_stay_x)/2,left_stay_x+lc_fixing_offset])
          translate([x,base_d_LC/2,-sheet_thickness(base) / 2])
            lc_nut_side_cutout(sheet_thickness(base),true);
        //side Box fixing holes
        for(y=[-1,1])
          for(x=[-base_d_LC/2+lc_fixing_offset,(-base_d_LC/2 + gantry_Y)/2,gantry_Y-lc_fixing_offset])
            translate([y*base_w_LC/2,x,-sheet_thickness(base) / 2])
              rotate([0,0,y*-90])
                lc_nut_side_cutout(sheet_thickness(base),true);
        //holes and cutouts for door hinges
        for(x=[-(base_w_LC-hinge_x_cutout+2*sheet_thickness(frame))/2,(base_w_LC-hinge_x_cutout+2*sheet_thickness(frame))/2])
          translate([x,-base_d_LC/2+hinge_y_cutout/2,(hinge_z_cutout)/ 2-sheet_thickness(frame)])
            cube([hinge_x_cutout+0.1,hinge_y_cutout+0.1,hinge_z_cutout+0.1],center=true);
        for(x=[-(base_w_LC-hinge_hole_a_x*2+2*sheet_thickness(frame))/2,(base_w_LC-hinge_hole_a_x*2+2*sheet_thickness(frame))/2])
          translate([x,-base_d_LC/2+hinge_hole_a_y,-sheet_thickness(frame)/2])
            rotate([0,0,90])
              slot(r=1.75,l=2.5,h=sheet_thickness(frame)+2);
        for(x=[-(base_w_LC-hinge_hole_b_x*2+2*sheet_thickness(frame))/2,(base_w_LC-hinge_hole_b_x*2+2*sheet_thickness(frame))/2])
          translate([x,-base_d_LC/2+hinge_hole_b_y,-sheet_thickness(frame)/2])
            rotate([0,0,90])
              slot(r=1.75,l=2.5,h=sheet_thickness(frame)+2);          


        
        y_axis_screw_holes();

        //translate([motor_end + z_bar_offset(), 0, 0])               // in case motor has second shaft
         //   cylinder(r = 4, h = 100, center = true);

        //translate([idler_end - z_bar_offset(), 0, 0])
        //    cylinder(r = 4, h = 100, center = true);


        translate([X_origin, ribbon_clamp_y,0])
            ribbon_clamp_holes(bed_ways, base_screw)
                base_screw_hole();
        if(atx_psu(psu))
            translate([right_stay_x + sheet_thickness(frame) / 2, psu_y, psu_z])
                rotate([0, -90, 180])
                    atx_screw_positions(psu, true)
                        base_screw_hole();
        //holes for alu bars to provide base clearance and stiffness
          translate([left_stay_x - 0, -base_depth / 2 + lc_fixing_offset / 2, 0]) // front
                    cylinder(r = M3_clearance_radius-0.2, h = 100, center = true);
          translate([right_stay_x +0, -base_depth / 2 + lc_fixing_offset / 2, 0]) // front
                    cylinder(r = M3_clearance_radius-0.2, h = 100, center = true);
        
        place_cable_clips(true);
        //
        // Holes for wires to run underneath
        //
        if(base_nuts) {
            // Y motor
            translate([Y_belt_line + Y_belt_motor_offset + NEMA_length(Y_motor) - 2, Y_motor_end +30, 0])
                rotate([0,0,90])
                slot(r=4,l=8,h=100);
                
            translate([Y_cable_clip_x - cable_clip_offset(base_screw, endstop_wires),
                    Y_motor_stay_hole_y + 4 + hole_edge_clearance + endstop_wires_hole_radius+5, 0])
                slot(r=4,l=8,h=100);
                
            // Y limit
            translate([X_origin + Y_bar_spacing / 2 + bar_rail_offset(Y_bar_dia) - bar_clamp_tab / 2,
                       Y_front_cable_clip_y - 35, 0])
                slot(r=4,l=4,h=100);
                
            translate([Y_cable_clip_x + cable_clip_offset(base_screw, motor_wires), Y_motor_stay_hole_y+5, 0])
                slot(r=4,l=4,h=100);
        }
    }
}


module frame_gantry() {
    difference() {
        translate([0, gantry_Y + sheet_thickness(frame) / 2, height_LC / 2])
            rotate([90,0,0])
              union() {
                difference() {
                    union(){
                      //bottom tabs
                      translate([base_width/2-lc_fixing_offset,-height_LC/2+0.1,0])
                        rotate([0,0,180])
                          lc_tabs(sheet_thickness(frame));
                      translate([-base_width/2+lc_fixing_offset,-height_LC/2+0.1,0])
                        rotate([0,0,180])
                          lc_tabs(sheet_thickness(frame));
                      translate([left_stay_x+lc_fixing_offset,-height_LC/2+0.1,0])
                        rotate([0,0,180])
                          lc_tabs(sheet_thickness(frame));
                      translate([right_stay_x+lc_fixing_offset,-height_LC/2+0.1,0])
                        rotate([0,0,180])
                          lc_tabs(sheet_thickness(frame));
                      sheet(frame, base_w_LC, height_LC, [frame_corners, frame_corners, 0, 0]);   // vertical plane
                    }
                    translate([X_origin,- (height_LC-height)/2 -gantry_thickness,0])
                        rounded_rectangle([window_width,  height, sheet_thickness(frame) + 1], r = window_corner_rad);
                    //bottom nut slots
                    translate([base_width/2-lc_fixing_offset,-height_LC/2,0])
                      rotate([0,0,180])
                        lc_nut_side_cutout(sheet_thickness(frame),true);
                    translate([-base_width/2+lc_fixing_offset,-height_LC/2,0])
                      rotate([0,0,180])
                        lc_nut_side_cutout(sheet_thickness(frame),true);
                    translate([left_stay_x+lc_fixing_offset,-height_LC/2,0])
                      rotate([0,0,180])
                        lc_nut_side_cutout(sheet_thickness(frame),true);
                    translate([right_stay_x+lc_fixing_offset,-height_LC/2,0])
                      rotate([0,0,180])
                        lc_nut_side_cutout(sheet_thickness(frame),true);
                    //left stay lc fixings
                    translate([left_stay_x,height_LC/2-lc_fixing_offset,0])
                        lc_screw_side_cutout(sheet_thickness(frame));
                    translate([left_stay_x,+lc_fixing_offset,0])
                        lc_screw_side_cutout(sheet_thickness(frame));
                    translate([left_stay_x,-height_LC/2+3*lc_fixing_offset,0])
                        lc_screw_side_cutout(sheet_thickness(frame));
                    //right stay lc fixings
                    translate([right_stay_x,height_LC/2-lc_fixing_offset,0])
                        lc_screw_side_cutout(sheet_thickness(frame));
                    translate([right_stay_x,+lc_fixing_offset,0])
                        lc_screw_side_cutout(sheet_thickness(frame));
                    translate([right_stay_x,-height_LC/2+3*lc_fixing_offset,0])
                        lc_screw_side_cutout(sheet_thickness(frame)); 
                    //Z axis bottom
                    translate([idler_end-z_bar_offset(),-height_LC/2+NEMA_length(Z_motor)+sheet_thickness(frame)/2,0])
                      rotate([0,0,90])
                        lc_screw_side_cutout(sheet_thickness(frame));
                    translate([motor_end+z_bar_offset(),-height_LC/2+NEMA_length(Z_motor)+sheet_thickness(frame)/2,0])
                      rotate([0,0,90])
                        lc_screw_side_cutout(sheet_thickness(frame));
                    for(x = [1,-1]){
                      translate([idler_end-z_bar_offset()+ x*(2+(gantry_setback + ceil(NEMA_width(Z_motor)/2))/2-sheet_thickness(frame)/2), -height_LC/2+(NEMA_length(Z_motor))/2,0])
                         lc_screw_side_cutout(sheet_thickness(frame));
                    }
                    for(x = [1,-1]){
                      translate([motor_end+z_bar_offset()+ x*(2+(gantry_setback + ceil(NEMA_width(Z_motor)/2))/2-sheet_thickness(frame)/2), -height_LC/2+(NEMA_length(Z_motor))/2,0])
                         lc_screw_side_cutout(sheet_thickness(frame));
                    }
                    //Z axis top
                    translate([idler_end-z_top_bracket_offset,height -sheet_thickness(frame)/2-height_LC/2,0])
                      rotate([0,0,90])
                        lc_tabs_cutout(sheet_thickness(frame));
                    translate([motor_end+z_top_bracket_offset,height -sheet_thickness(frame)/2-height_LC/2,0])
                      rotate([0,0,90])
                        lc_tabs_cutout(sheet_thickness(frame));

                    for(x = [1,-1]){
                      translate([idler_end-z_top_bracket_offset+ x*(z_top_bracket_width/2-sheet_thickness(frame)/2-2),height+z_top_side_bracket_height/2-height_LC/2,0])
                        lc_screw_side_cutout(sheet_thickness(frame)); 
                    }
                    for(x = [1,-1]){
                      translate([motor_end+z_top_bracket_offset+ x*(z_top_bracket_width/2-sheet_thickness(frame)/2-2),height+z_top_side_bracket_height/2-height_LC/2,0])
                        lc_screw_side_cutout(sheet_thickness(frame));
                    }
                    //Back top box
                    translate([left_stay_x+2*lc_fixing_offset,height -height_LC/2 -gantry_thickness+10,0])
                      rotate([0,0,90])
                        lc_tabs_cutout(sheet_thickness(frame));
                    translate([right_stay_x-2*lc_fixing_offset,height -height_LC/2 -gantry_thickness+10,0])
                      rotate([0,0,90])
                        lc_tabs_cutout(sheet_thickness(frame));
                }
              }
        
        //side Box fixing holes
        for(y=[-1,1])
          for(x=[lc_fixing_offset,(height_LC+lc_fixing_offset/2)*1/3, (height_LC-lc_fixing_offset/2)*2/3,height_LC-lc_fixing_offset])
            translate([y*base_w_LC/2,gantry_Y+sheet_thickness(frame)/2,x])
              rotate([0,90,y*-90])
                lc_nut_side_cutout(sheet_thickness(base),true);
          //top Box fixing holes
          for(x=[-base_w_LC/2+lc_fixing_offset,(base_w_LC/2-lc_fixing_offset/2)*1/3, (-base_w_LC/2+lc_fixing_offset/2)*1/3,base_w_LC/2-lc_fixing_offset])
            translate([x,gantry_Y+sheet_thickness(frame)/2,height_LC])
              rotate([90,0,0])
                lc_nut_side_cutout(sheet_thickness(base),true);
          

        //
        // Z limit switch holes
        //
        //bottom holes
        translate([idler_end -z_bar_offset(), gantry_Y, Z0 - x_end_thickness() / 2])
            z_limit_screw_positions()
              rotate([0,0,90])
                slot(r = 1.6, l = 15, h = 100, center = true);
        
        //top holes
        for (z=[10,-10])
        translate([idler_end-z_bar_offset()-6.4, gantry_Y, height_LC-z_top_side_bracket_height-28+z])
              rotate([90,90,0])
                slot(r = 1.6, l = 10, h = 100, center = true);
                
        
        //
        // X ribbon clamp
        //
        translate([motor_end - x_motor_offset(), gantry_Y, ribbon_clamp_z]) {
            ribbon_clamp_holes(x_end_ways, frame_screw)
                rotate([90, 0, 0])
                    frame_screw_hole();

            if(cnc_sheets)
                translate([0, 0, ribbon_clamp_width(frame_screw) / 2 + 5])
                    rotate([90, 0, 0])
                        slot(r = 2.5, l = ribbon_clamp_slot(x_end_ways), h = 100, center = true);

        }
        //
        // PSU bracket hole
        //
        if(atx_psu(psu))
            translate([right_stay_x + sheet_thickness(frame) / 2, psu_y, psu_z])
                rotate([0, -90, 180])
                    atx_screw_positions(psu, false)
                        frame_screw_hole();
                        
        //Idler/Motor rod clamp adjustment holes (to negate requirement for 5.5mm flat spanner for assembly
         translate([idler_end - 17.5,
                    gantry_Y, Z_motor_length + z_motor_bracket_height() + 50])
            rotate([90, 0, 0])
                cylinder(r=4,h=100, center=true);    
         translate([motor_end + 17.5,
                    gantry_Y, Z_motor_length + z_motor_bracket_height() + 50])
            rotate([90, 0, 0])
                cylinder(r=4,h=100, center=true);    
        
        //
        // Wiring holes
        //
        translate([idler_end - bar_rail_offset(Z_bar_dia) + 0.5 * bar_clamp_tab,
                    gantry_Y, height - base_clearance - bar_clamp_depth - endstop_wires_hole_radius - base_clearance])
            rotate([90, 0, 0])
                slot(r=3,l=3,h=100);  // Z top endstop
                
        translate([-base_width / 2 + base_clearance+ 30, gantry_Y, 25])
            rotate([90, 0, 0])
                slot(r=4,l=8,h=100);    // Z lhs motor

        translate([max(motor_end + bar_rail_offset(Z_bar_dia),
                       base_width / 2 - right_w + fixing_block_width() + base_clearance),
                    gantry_Y, 25])
            rotate([90, 0, 0])
                slot(r=4,l=8,h=100);   // Z rhs motor

        translate([idler_end - bar_rail_offset(Z_bar_dia),
                    gantry_Y, Z_motor_length + z_motor_bracket_height() + endstop_wires_hole_radius])
            rotate([90, 0, 0])
                slot(r=3,l=3,h=100);    // bottom limit switch

        place_cable_clips(true);
    }
}

module frame_stay(left, bodge = 0) {
    x = left ? left_stay_x : right_stay_x;

    difference() {
            translate([x, gantry_Y + sheet_thickness(frame) + stay_depth_LC / 2, stay_height_LC / 2])
                rotate([90,0,90]){
                union(){
                    difference(){
                      union(){
                        sheet(frame, stay_depth_LC, stay_height_LC, [0, frame_corners, 0, 0]);
                        //bottom tabs
                        translate([stay_depth_LC/2-lc_fixing_offset,-stay_height_LC/2+0.1,0])
                          rotate([0,0,180])
                            lc_tabs(sheet_thickness(frame));
                        translate([-stay_depth_LC/2+lc_fixing_offset,-stay_height_LC/2+0.1,0])
                          rotate([0,0,180])
                            lc_tabs(sheet_thickness(frame));
                        //side tabs
                        translate([-stay_depth_LC/2+0.1,stay_height_LC/2-lc_fixing_offset,0])
                          rotate([0,0,90])
                            lc_tabs(sheet_thickness(frame));
                        translate([-stay_depth_LC/2+0.1,+lc_fixing_offset,0])
                          rotate([0,0,90])
                            lc_tabs(sheet_thickness(frame));
                        translate([-stay_depth_LC/2+0.1,-height_LC/2+3*lc_fixing_offset,0])
                          rotate([0,0,90])
                            lc_tabs(sheet_thickness(frame));
                      }
                      //bottom nut slots
                      translate([stay_depth_LC/2-lc_fixing_offset,-stay_height_LC/2,0])
                          rotate([0,0,180])
                          lc_nut_side_cutout(sheet_thickness(frame),true);
                      translate([-stay_depth_LC/2+lc_fixing_offset,-stay_height_LC/2,0])
                        rotate([0,0,180])
                          lc_nut_side_cutout(sheet_thickness(frame),true);
                      //side nut slots
                      translate([-stay_depth_LC/2,stay_height_LC/2-lc_fixing_offset,0])
                          rotate([0,0,90])
                            lc_nut_side_cutout(sheet_thickness(frame),true);
                      translate([-stay_depth_LC/2,+lc_fixing_offset,0])
                          rotate([0,0,90])
                            lc_nut_side_cutout(sheet_thickness(frame),true);
                       translate([-stay_depth_LC/2,-height_LC/2+3*lc_fixing_offset,0])
                          rotate([0,0,90])
                            lc_nut_side_cutout(sheet_thickness(frame),true);
                      //top back box fixings
                      translate([stay_depth_LC/2-lc_fixing_offset,-stay_height_LC / 2 +lc_back_top_z,0])
                        rotate([0,0,-90])
                          lc_screw_side_cutout(sheet_thickness(frame));
                      translate([-stay_depth_LC/2+lc_fixing_offset,-stay_height_LC / 2 +lc_back_top_z,0])
                        rotate([0,0,-90])
                          lc_screw_side_cutout(sheet_thickness(frame));
                      //extruder gantry fixings
                      translate([-1.5 ,-stay_height_LC / 2 +390 -sheet_thickness(MelamineMDF63)/sqrt(2),0])
                        rotate([0,0,-45])
                          lc_screw_side_cutout(sheet_thickness(MelamineMDF63));
                      translate([-10 ,-stay_height_LC / 2 + 390+sheet_thickness(MelamineMDF63)/sqrt(2),0])
                        rotate([0,0,-45]) 
                          lc_screw_side_cutout(sheet_thickness(MelamineMDF63));
                    }
                  }
                }
              //Back Box fixing holes
                for(z=[lc_fixing_offset,(height_LC+lc_fixing_offset/2)*1/3, (height_LC-lc_fixing_offset/2)*2/3])
                    translate([x,base_d_LC/2,z])
                      rotate([0,90,0])
                        lc_nut_side_cutout(sheet_thickness(base),true);
        

        //spool_holder_holes();

        //if(left)
           // translate([x + (sheet_thickness(frame) + fan_depth(case_fan)) / 2, fan_y, fan_z])
           //     rotate([0,90,0])
           //         scale([1 + bodge, 1 + bodge, 1]) fan_holes(case_fan);       // scale prevents OpenCSG z buffer artifacts

        if(!left) {
            //
            // Electronics mounting holes
            //
             //add RAMPS with Arduino MEGA weird screw positions
            translate([x, controller_y+55, controller_z+95])
              rotate([90, -90, 90]){
                translate([14, 2.5, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([15.3, 50.8, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([96.5, 2.5, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([90.2, 50.8, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([66.1, 35.6, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([66.1, 7.7, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
              }
            //add DUET and Expansion board screw positions  (+Z,-Y,X)
            translate([x, controller_y+107, controller_z+234])
              rotate([90, -90, 90]){
                translate([0, -1.1, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([0, 116.5, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([-61.28, 0, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([-61.28, 115, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([-83, 0, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([-83, 115, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([-175, 0, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);
                translate([-175, 115, 0])
                  cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true); 
              }
            translate([x, psu_y, psu_z])
                if(atx_psu(psu))
                    rotate([0, -90, 180]) {
                        atx_screw_positions(psu)
                            frame_screw_hole();

                        atx_resistor_holes(psu);
                    }
                else
                    rotate([0, 90, 0])
                        psu_screw_positions(psu)
                            cylinder(r = psu_screw_hole_radius(psu), h = 100, center = true);

            //
            // Wiring holes
            //
            translate([x, Y_motor_stay_hole_y -5, 15])
                rotate([90, 90, 90])
                    slot(r=3,l=11,h=100); // Y motor wires at bottom

            translate([x, bed_wires_y + cable_clip_offset(base_screw, bed_wires), 0])
                rotate([90, 0, 90])
            slot(r=5.9,l=13,h=100);  // Bed wires at bottom

        }

              translate([x, gantry_Y + sheet_thickness(frame), z_gantry_wire_height-10])
                rotate([90, 90, 90])
                    slot(r=8,l=9,h=100);         // Z  motor wires
   
    }
}

module lc_back_top() {
  translate([(left_stay_x+right_stay_x)/2,gantry_Y +(stay_depth_LC)/2  +sheet_thickness(frame) ,lc_back_top_z]){
    difference(){
      union() {
        sheet(frame, right_stay_x-left_stay_x-sheet_thickness(frame), stay_depth_LC, [0, 0, 0, 0]);
        for(x = [1,-1]){
          //side tabs
          translate([x*(right_stay_x-left_stay_x-sheet_thickness(frame)-0.01)/2,stay_depth_LC/2-lc_fixing_offset,0])
            rotate([0,0,x*-90])
              lc_tabs(sheet_thickness(frame));
          translate([x*(right_stay_x-left_stay_x-sheet_thickness(frame)-0.01)/2,-stay_depth_LC/2+lc_fixing_offset,0])
            rotate([0,0,x*-90])
              lc_tabs(sheet_thickness(frame));
        }
        //front tabs
        translate([(left_stay_x-right_stay_x)/2+2*lc_fixing_offset,-stay_depth_LC/2+0.01,0])
          rotate([0,0,180])
            lc_tabs(sheet_thickness(frame));
        translate([(right_stay_x-left_stay_x)/2-2*lc_fixing_offset,-stay_depth_LC/2+0.01,0])
          rotate([0,0,180])
            lc_tabs(sheet_thickness(frame));                             
      }
      //side nut slots
      for(x = [1,-1]){
        translate([x*(right_stay_x-left_stay_x-sheet_thickness(frame))/2,stay_depth_LC/2-lc_fixing_offset,0])
          rotate([0,0,x*-90])
            lc_nut_side_cutout(sheet_thickness(base),true);
        translate([x*(right_stay_x-left_stay_x-sheet_thickness(frame))/2,-stay_depth_LC/2+lc_fixing_offset,0])
          rotate([0,0,x*-90])
            lc_nut_side_cutout(sheet_thickness(base),true);
      }
      
      //back nut slots    
      translate([(left_stay_x-right_stay_x)/2+2*lc_fixing_offset,stay_depth_LC/2,0])
        rotate([0,0,0])
          lc_nut_side_cutout(sheet_thickness(base),true);
      translate([(right_stay_x-left_stay_x)/2-2*lc_fixing_offset,stay_depth_LC/2,0])
        rotate([0,0,0])
          lc_nut_side_cutout(sheet_thickness(base),true);      
    }
  }
}


module lc_z_axis_top(left=true) {
  if(left)
    union() {
      translate([idler_end-z_top_bracket_offset,Y0+gantry_setback-z_top_bracket_depth/2,height-sheet_thickness(frame)/2])
        lc_z_axis_top_plate(true);
      for(x = [1,-1])
        translate([idler_end-z_top_bracket_offset +x*(z_top_bracket_width/2-sheet_thickness(frame)/2-2),Y0+gantry_setback-z_top_bracket_depth/2, height+z_top_side_bracket_height/2])
          rotate([0,90,0])
             lc_z_axis_top_side();
    }  
  else
    union() {
      translate([motor_end+z_top_bracket_offset,Y0+gantry_setback-z_top_bracket_depth/2,height-sheet_thickness(frame)/2])
        mirror(1,0,0)
          lc_z_axis_top_plate(false);
      for(x = [1,-1])
        translate([motor_end+z_top_bracket_offset +x*(z_top_bracket_width/2-sheet_thickness(frame)/2-2),Y0+gantry_setback-z_top_bracket_depth/2, height+z_top_side_bracket_height/2])
          rotate([0,90,0])
            lc_z_axis_top_side();
    }
}
module lc_z_axis_top_plate(left=true) {
  difference() {
    union(){
      sheet(frame, z_top_bracket_width, z_top_bracket_depth , [0, 0, 0, 0]);
      //side tab
      translate([0,z_top_bracket_depth/2,0])
        lc_tabs(sheet_thickness(frame));
    }
    //top screw side slots
    for(x = [1,-1])
       translate([x*(z_top_bracket_width/2-sheet_thickness(frame)/2-2),0,0])
          //rotate([0,0,90])
              lc_screw_side_cutout(sheet_thickness(frame));   
    if(left)             
      translate([z_top_bracket_offset,-gantry_setback+z_top_bracket_depth/2,0]){
          cylinder(r = Z_bar_dia / 2-0.4, h = sheet_thickness(frame)+1, center = true);       // hole for z smooth rod
          translate([-z_bar_offset(),0,0])
            cylinder(r = 3.2, h = sheet_thickness(frame)+1, center = true);       // hole for z threaded rod insertion
    }
    else
      translate([z_top_bracket_offset,-gantry_setback+z_top_bracket_depth/2,0]){
        cylinder(r = Z_bar_dia / 2-0.4, h = sheet_thickness(frame)+1, center = true);       // hole for z smooth rod
        translate([-z_bar_offset(),0,0])
          cylinder(r = 3.2, h = sheet_thickness(frame)+1, center = true);       // hole for z threaded rod insertion
    }
  }
}

module lc_z_axis_top_side(){
  difference(){
    union(){
      sheet(frame, z_top_side_bracket_height,z_top_bracket_depth , [0, 0, 0, 0]);
      //side tabs
      translate([0,z_top_bracket_depth/2-0.01,0]) //2
          lc_tabs(sheet_thickness(frame));
      //bottom tabs
      rotate([0,0,270]){
        translate([0,z_top_side_bracket_height/2 -0.01,0])
          lc_tabs(sheet_thickness(frame));
      }
    }
    //side nut slots
    translate([0,z_top_bracket_depth/2,0])
      lc_nut_side_cutout(sheet_thickness(frame),true);
    //bottom nut slots
    rotate([0,0,270]){
      translate([0,z_top_side_bracket_height/2,0])
        lc_nut_side_cutout(sheet_thickness(frame),true);
    }
    //cutout to make side triangular
    translate([-z_top_side_bracket_height/2+10.65,-z_top_bracket_depth-3.35,-(sheet_thickness(frame)+1)/2])
      rotate([0,0,39.8]) //acos(z_top_side_bracket_height/z_top_bracket_depth)
        cube([z_top_side_bracket_height,z_top_bracket_depth+20,sheet_thickness(frame)+1]);
  }
}


module lc_z_axis_bottom_side(){
  difference(){
    union(){
      sheet(frame, (NEMA_length(Z_motor)),z_bracket_d , [0, 0, 0, 0]);
      //sidetabs
      translate([0,z_bracket_d/2,0])
        lc_tabs(sheet_thickness(frame));
      //top tabs
      rotate([0,0,90])
        translate([-z_bracket_d / 2 + m_width / 2,(NEMA_length(Z_motor))/2 -0.01,0])
          lc_tabs(sheet_thickness(frame));
      //bottom tabs
      rotate([0,0,-90])
        translate([z_bracket_d / 2 -m_width / 2,(NEMA_length(Z_motor))/2 -0.01,0])
          lc_tabs(sheet_thickness(frame));
    }
    //side nut slots
    translate([0,z_bracket_d/2,0])
      lc_nut_side_cutout(sheet_thickness(frame),true);
    //top nut slots
    rotate([0,0,90])
      translate([-z_bracket_d / 2 + m_width / 2,(NEMA_length(Z_motor))/2,0])
        lc_nut_side_cutout(sheet_thickness(frame),true); 
    //bottom nut slots
    rotate([0,0,-90])
      translate([z_bracket_d / 2 - m_width / 2,(NEMA_length(Z_motor))/2,0])
        lc_nut_side_cutout(sheet_thickness(frame),true); 
  }
}

module lc_z_axis_bottom_plate(){
  difference(){
    union(){
      sheet(frame, z_bracket_d+8, z_bracket_d, [0, 0, 0, 0]);
        //side tabs
        translate([0,z_bracket_d/2,0])
          lc_tabs(sheet_thickness(frame));
     }
    translate([0,-z_bracket_d / 2 + m_width / 2, 0]){
      cylinder(r = (21.88/2), h = sheet_thickness(frame) + 1, center = true);// hole for stepper locating boss
      for(x = NEMA_holes(Z_motor))                                              // motor screw holes
        for(y = NEMA_holes(Z_motor))
            translate([x,y,0])
              cylinder(r = 1.45, h = sheet_thickness(frame) + 1, center = true);
      echo("z_bar_offset: ", z_bar_offset(), " Z_bar_dia/2-0.4: ", Z_bar_dia/2-0.4);
      translate([z_bar_offset(), 0,  0])
        cylinder(r = Z_bar_dia / 2-0.4, h = sheet_thickness(frame)+1, center = true);       // hole for z rod
      //top nut slots
      translate([0,z_bracket_d - m_width / 2,0])
         lc_nut_side_cutout(sheet_thickness(frame),true);
      //top screw side slots
      for(x = [1,-1])
        translate([x*(2+z_bracket_d/2-sheet_thickness(frame)/2),0,0])
          //rotate([0,0,90])
              lc_screw_side_cutout(sheet_thickness(frame));
    }                
  }
}

module lc_z_axis_bottom_assembly(left=true) {
    lc_z_axis_bottom(left);
    if(left){
      translate([idler_end-z_bar_offset(),Y0, NEMA_length(Z_motor)+sheet_thickness(frame)/2]){
        NEMA(Z_motor);
       // translate([0,0, sheet_thickness(frame)])
       //   NEMA_screws(Z_motor);
      }
    }
    else{
      translate([motor_end+z_bar_offset(),Y0, NEMA_length(Z_motor)+sheet_thickness(frame)/2]){
        NEMA(Z_motor);
        //translate([0,0, sheet_thickness(frame)])
         // NEMA_screws(Z_motor);
      }
    }
}

module lc_z_axis_bottom(left=true) {
  if(left)
    union() {
      translate([idler_end-z_bar_offset(),z_bracket_d / 2 - m_width / 2 +Y0, NEMA_length(Z_motor)+sheet_thickness(frame)/2])
          lc_z_axis_bottom_plate();
      for(x = [1,-1])
        translate([idler_end-z_bar_offset()+x*(2+z_bracket_d/2-sheet_thickness(frame)/2),z_bracket_d / 2 - m_width / 2 +Y0, (NEMA_length(Z_motor))/2])
          rotate([0,90,0])
             lc_z_axis_bottom_side();
    }  
  else
    union() {
      translate([motor_end+z_bar_offset(),z_bracket_d / 2 - m_width / 2 +Y0, NEMA_length(Z_motor)+sheet_thickness(frame)/2])
          mirror(1,0,0)
            lc_z_axis_bottom_plate();
      for(x = [1,-1])
        translate([motor_end+z_bar_offset()+x*(2+z_bracket_d/2-sheet_thickness(frame)/2),z_bracket_d / 2 - m_width / 2 +Y0, (NEMA_length(Z_motor))/2])
          rotate([0,90,0])
            lc_z_axis_bottom_side();
    }
}
//uses a sandwich of three sheets of frame material for rigidity, top and
//bottom of sandwich have tabs+fixing holes, middle of sandwich does not
module lc_extruder_assembly()
{
  translate([(left_stay_x+right_stay_x)/2,gantry_Y +(stay_depth_LC)/2  +sheet_thickness(MelamineMDF63)/sqrt(2) ,390-sheet_thickness(MelamineMDF63)/sqrt(2)])
    rotate([45,0,0])
      lc_extruder_mount(true);
  translate([(left_stay_x+right_stay_x)/2,gantry_Y +(stay_depth_LC)/2 ,390])
    rotate([45,0,0])   
      lc_extruder_mount(false);
  translate([(left_stay_x+right_stay_x)/2,gantry_Y +(stay_depth_LC)/2 -sheet_thickness(MelamineMDF63)/sqrt(2) ,390+sheet_thickness(MelamineMDF63)/sqrt(2)])
    rotate([45,0,0]) 
      lc_extruder_mount(true);
  for(x=[105,45,-15,-75,-135])
    translate([x, 145, 365]) rotate([-45,0,0]) import("rrp_extruder/extruder-drive.stl");
}

module lc_extruder_mount(outside=true) {
  difference(){
    union() {
      sheet(frame, right_stay_x-left_stay_x-sheet_thickness(frame), stay_depth_LC/3, [0, 0, 0, 0]);
      if(outside){
        for(x = [1,-1]){
          //side tabs
          translate([x*(right_stay_x-left_stay_x-sheet_thickness(frame)-0.01)/2,0,0])
            rotate([0,0,x*-90])
              lc_tabs(sheet_thickness(frame));
        }
      }                            
    }
    if(outside){
    //side nut slots
      for(x = [1,-1]){
        translate([x*(right_stay_x-left_stay_x-sheet_thickness(frame))/2,0,0])
          rotate([0,0,x*-90])
            lc_nut_side_cutout(sheet_thickness(frame),true);
      }
    }
    for(x=[105,45,-15,-75,-135]){
      translate([x+16.3, 0, 0]) cylinder(r=5.3/2,h=sheet_thickness(frame)*3+1,center=true);
      translate([x+28.8, 0, 0]) cylinder(r=3.4/2,h=sheet_thickness(frame)*3+1,center=true);
      translate([x-3.2, 0, 0]) cylinder(r=3.4/2,h=sheet_thickness(frame)*3+1,center=true);
    }

  }        
}

//lc acrylic variables

lc_box_back_height = lc_back_top_z+sheet_thickness(PMMA6)*3/2;
lc_box_back_width = right_stay_x-left_stay_x+sheet_thickness(PMMA6);
lc_box_height = height_LC+sheet_thickness(PMMA6);
lc_box_depth = base_d_LC -stay_depth_LC;

module lc_box_back() {
translate([(left_stay_x+right_stay_x)/2, gantry_Y +(stay_depth_LC)  +sheet_thickness(frame) +sheet_thickness(PMMA6)/2, (lc_back_top_z-sheet_thickness(PMMA6)/2)/2])
    rotate([90,0,0])
      difference(){
        sheet(PMMA6, lc_box_back_width, lc_box_back_height, [0, 0, 0, 0]);
        //side fixings
        for (x = [(left_stay_x-right_stay_x)/2 , (-left_stay_x+right_stay_x)/2 ])
        for(z=[lc_fixing_offset,(height_LC+lc_fixing_offset/2)*1/3, (height_LC-lc_fixing_offset/2)*2/3])
          translate([x,z-((lc_back_top_z-sheet_thickness(PMMA6)/2)/2),0])
            lc_screw_cutout(sheet_thickness(PMMA6));
        //top fixings   
      translate([(left_stay_x-right_stay_x)/2+2*lc_fixing_offset,((lc_back_top_z+sheet_thickness(PMMA6)/2)/2),0])
        lc_screw_cutout(sheet_thickness(PMMA6));
      translate([(right_stay_x-left_stay_x)/2-2*lc_fixing_offset,((lc_back_top_z+sheet_thickness(PMMA6)/2)/2),0])
        lc_screw_cutout(sheet_thickness(PMMA6));
        
       //bottom fixings
        for(x=[right_stay_x-lc_fixing_offset,(left_stay_x + right_stay_x)/2,left_stay_x+lc_fixing_offset])
          translate([x-(left_stay_x+right_stay_x)/2,-((lc_back_top_z+sheet_thickness(PMMA6)/2)/2),0])
            lc_screw_cutout(sheet_thickness(PMMA6));
        }
}

module lc_box_side(left=true) {
    x = left ? -base_w_LC/2-sheet_thickness(PMMA6)/2 : base_w_LC/2+sheet_thickness(PMMA6)/2;
		i = left ? 1 : -1;
 translate([x, -(base_d_LC -(stay_depth_LC))/2+gantry_Y+sheet_thickness(PMMA6), (height_LC -sheet_thickness(PMMA6))/2])
    rotate([90,0,90])
      difference(){   
    sheet(PMMA6, lc_box_depth, lc_box_height, [0, 0, 0, 0]);
    //bottom fixing holes
    for(a=[-base_d_LC/2+lc_fixing_offset,(-base_d_LC/2 + gantry_Y)/2,gantry_Y-lc_fixing_offset])
      translate([a+(base_d_LC -(stay_depth_LC))/2-gantry_Y-sheet_thickness(PMMA6),-height_LC/2,0])
          lc_screw_cutout(sheet_thickness(PMMA6));
    //top nut traps holes
    for(a=[-base_d_LC/2+lc_fixing_offset,(-base_d_LC/2 + gantry_Y)/2,gantry_Y-lc_fixing_offset])
      translate([a+(base_d_LC -(stay_depth_LC))/2-gantry_Y-sheet_thickness(PMMA6),(height_LC+sheet_thickness(PMMA6))/2,0])
          lc_nut_side_cutout(sheet_thickness(PMMA6),true);
    //side fixing holes
    for(z=[lc_fixing_offset,(height_LC+lc_fixing_offset/2)*1/3, (height_LC-lc_fixing_offset/2)*2/3,height_LC-lc_fixing_offset])
      translate([(base_d_LC -(stay_depth_LC)-sheet_thickness(frame))/2,z-((height_LC -sheet_thickness(PMMA6))/2),0])
          lc_screw_cutout(sheet_thickness(PMMA6));
    //holes and cutouts for door hinges
        for(z=[-(height_LC +sheet_thickness(PMMA6)-hinge_z_cutout)/2,(height_LC -hinge_z_cutout)/2+3*sheet_thickness(PMMA6)/2])
          translate([-(base_d_LC -(stay_depth_LC)-hinge_y_cutout)/2,z, i*(hinge_x_cutout-sheet_thickness(PMMA6))/2])
            rotate([0,-90,90])
              cube([hinge_x_cutout+0.1,hinge_y_cutout+0.1,hinge_z_cutout+0.1],center=true);
    //hole for bottom Z endstop adjustment (not currently used)
      //  if(left){
      //    translate([((base_d_LC -(stay_depth_LC))/2+gantry_Y+sheet_thickness(PMMA6))/2 +30.5,Z0 - x_end_thickness() / 2-(height_LC -sheet_thickness(PMMA6))/2 +28,0])
      //      cylinder(r=4,h=sheet_thickness(PMMA6)+2,$fn=20,center=true);
      //  }
  }
}

module lc_box_top() {
  translate([0, -(base_d_LC -(stay_depth_LC))/2+gantry_Y+sheet_thickness(PMMA6), height_LC +sheet_thickness(PMMA6)/2])
    difference(){   
    sheet(PMMA6, base_w_LC+2*sheet_thickness(PMMA6),lc_box_depth, [0, 0, 0, 0]);
    //side fixing holes
    for(x=[ (-base_w_LC-sheet_thickness(PMMA6))/2 , (base_w_LC+sheet_thickness(PMMA6))/2])
      for(a=[-base_d_LC/2+lc_fixing_offset,(-base_d_LC/2 + gantry_Y)/2,gantry_Y-lc_fixing_offset])
        translate([x,a+(base_d_LC -(stay_depth_LC))/2-gantry_Y-sheet_thickness(PMMA6),0])
            lc_screw_cutout(sheet_thickness(PMMA6));
    //back fixing holes
    for(x=[-base_w_LC/2+lc_fixing_offset,(base_w_LC/2-lc_fixing_offset/2)*1/3, (-base_w_LC/2+lc_fixing_offset/2)*1/3,base_w_LC/2-lc_fixing_offset])
      translate([x,(base_d_LC -(stay_depth_LC)-sheet_thickness(frame))/2,0])
          lc_screw_cutout(sheet_thickness(PMMA6));
    //holes and cutouts for door hinges
        for(x=[ (-base_w_LC+hinge_x_cutout)/2 -sheet_thickness(PMMA6), (base_w_LC-hinge_x_cutout)/2+sheet_thickness(PMMA6)])
          translate([x,-(base_d_LC -(stay_depth_LC)-hinge_y_cutout)/2,(sheet_thickness(PMMA6)-hinge_z_cutout)/2])
              cube([hinge_x_cutout+0.1,hinge_y_cutout+0.1,hinge_z_cutout+0.1],center=true);
        
        for(x=[-(base_w_LC-hinge_hole_a_x*2+2*sheet_thickness(PMMA6))/2,(base_w_LC-hinge_hole_a_x*2+2*sheet_thickness(PMMA6))/2])
          translate([x,-(base_d_LC -(stay_depth_LC)-hinge_hole_a_y*2)/2,sheet_thickness(PMMA6)/2])
            rotate([0,0,90])
              slot(r=1.75,l=2.5,h=sheet_thickness(PMMA6)+20);
        for(x=[-(base_w_LC-hinge_hole_b_x*2+2*sheet_thickness(PMMA6))/2,(base_w_LC-hinge_hole_b_x*2+2*sheet_thickness(PMMA6))/2])
          translate([x,-(base_d_LC -(stay_depth_LC)-hinge_hole_b_y*2)/2,sheet_thickness(PMMA6)/2])
            rotate([0,0,90])
              slot(r=1.75,l=2.5,h=sheet_thickness(PMMA6)+20);          
              
              
    //slot for bowden cable/filament
    translate([(left_stay_x+right_stay_x)/2,((base_d_LC -(stay_depth_LC))/2+gantry_Y+sheet_thickness(PMMA6))/2,0])
              slot(r=4,l=(right_stay_x-left_stay_x),h=100);
    }
}

module lc_box_door(left=true) {
  x = left ? -base_w_LC/4-sheet_thickness(PMMA6)/2 : base_w_LC/4+sheet_thickness(PMMA6)/2;
    translate([x, -(base_d_LC +sheet_thickness(PMMA6))/2, (height_LC)/2])
      rotate([90,0,0])
        difference(){   
          sheet(PMMA6, base_w_LC/2+sheet_thickness(PMMA6), height_LC+2*sheet_thickness(PMMA6), [0, 0, 0, 0]);
          //door nob holes
          //translate([-x*0.85,0,0])
          // lc_screw_cutout(sheet_thickness(PMMA6));
        }
}

 y0 = sheet_thickness(PMMA6);
 y1 = y0+ lc_box_back_height+0.1;
 y2 = y1+ lc_box_back_height+0.1;
 y3 = y2+ lc_box_height+0.1;
 y4 = y3+ (lc_box_height)*3/2+sheet_thickness(PMMA6);


 
module box_all() projection(cut=true)
{
    //translate([ -base_w_LC/2-sheet_thickness(PMMA6),y4+1.5+0.1,-height_LC -sheet_thickness(PMMA6)/2]) rotate([0, 0, 0]) lc_box_top();
    //translate([-lc_box_back_width/2 +22.125,y1,base_d_LC/2+sheet_thickness(PMMA6)/2]) rotate([-90, 0, 0]) lc_box_back();
   // translate([-lc_box_back_width/4 +33.375,y2,base_w_LC/2+sheet_thickness(PMMA6)/2]) rotate([-90, -90, 0]) lc_box_side(true);
    //translate([-lc_box_back_width/4 -lc_box_depth+33.375 -0.1,y2,-base_w_LC/2-sheet_thickness(PMMA6)/2]) rotate([-90, -90, 0]) lc_box_side(false);
    translate([0 ,y3,-base_d_LC/2-sheet_thickness(PMMA6)/2]) rotate([-90, 0, 0]) lc_box_door();
    //translate([ -base_w_LC/2-sheet_thickness(PMMA6)-0.1,y3,-base_d_LC/2-sheet_thickness(PMMA6)/2]) rotate([-90, 0, 0]) lc_box_door();


//spares
    //translate([-lc_box_back_width/2 +22.125,y0,base_d_LC/2+sheet_thickness(PMMA6)/2]) rotate([-90, 0, 0]) lc_box_back();
    //translate([ -lc_box_back_width-0.18,y0,-base_d_LC/2-sheet_thickness(PMMA6)/2]) rotate([-90, 0, 0]) lc_box_door();
    //translate([-6 ,y4+32.77,-base_d_LC/2-sheet_thickness(PMMA6)/2]) rotate([-90, 0, 90]) lc_box_door();
    //translate([ -base_w_LC/2-sheet_thickness(PMMA6)+31,y1+39.8,-height_LC -sheet_thickness(PMMA6)/2]) rotate([0, 0, 90]) lc_box_top();
    //translate([ -base_w_LC-sheet_thickness(PMMA6)*2-30.85,y1+39.8,-height_LC -sheet_thickness(PMMA6)/2]) rotate([0, 0, 90]) lc_box_top();
   //translate([-lc_box_back_width/4 -lc_box_depth-13.6,y0,-base_w_LC/2-sheet_thickness(PMMA6)/2]) rotate([-90, -90, 0]) lc_box_side(false);
}

module bed_fan_assembly() {
    assembly("bed_fan_assembly");
    translate([left_stay_x, fan_y, fan_z])
        rotate([0, -90, 0]) {
            translate([0, 0, -(sheet_thickness(frame) + fan_depth(case_fan)) / 2])
                fan_assembly(case_fan, sheet_thickness(frame) + fan_guard_thickness());

            translate([0, 0, sheet_thickness(frame) / 2])
                color(fan_guard_color) render() fan_guard(case_fan);
        }
    end("bed_fan_assembly");
}

module electronics_assembly() {
    assembly("electronics_assembly");
    translate([right_stay_x + sheet_thickness(frame) / 2, controller_y, controller_z])
        rotate([90, 0, 90]) {
            controller_screw_positions(controller)
                pcb_spacer_assembly();

            translate([0, 0, pcb_spacer_height()])
                controller(controller);
        }

    end("electronics_assembly");
}

module psu_assembly() {
    thickness = sheet_thickness(frame) + washer_thickness(M3_washer) * 2;
    psu_screw = screw_longer_than(thickness + 2);
    if(psu_screw > thickness + 5 && psu_screw_from_back(psu))
        echo("psu_screw too long");

    assembly("psu_assembly");

    translate([right_stay_x + sheet_thickness(frame) / 2, psu_y, psu_z])
        rotate([0, 90, 0]) {
            psu_screw_positions(psu) group() {
                if(psu_screw_from_back(psu))
                    translate([0, 0, -sheet_thickness(frame)])
                        rotate([180, 0, 0])
                            screw_and_washer(psu_screw_type(psu), psu_screw, true);
                else
                    screw_and_washer(frame_screw, frame_screw_length, true);
            }
            if(exploded)
                %psu(psu);
            else
                psu(psu);
            if(atx_psu(psu))
                rotate([0, 0, 180])
                    atx_bracket_assembly();
            else
                if(psu_width(psu))              // not external PSU
                    translate([-psu_length(psu) / 2, psu_width(psu) / 2, 0])
                        mains_inlet_assembly();

        }
    end("psu_assembly");
}

module frame_assembly(show_gantry = true) {
    assembly("frame_assembly");

    translate([motor_end - x_motor_offset(), gantry_Y, ribbon_clamp_z])
        rotate([90, 0, 0]) {
            if(frame_nuts)
                ribbon_clamp_assembly(x_end_ways, frame_screw, frame_screw_length, sheet_thickness(frame), false, true, nutty = true);
            else
                ribbon_clamp_assembly(x_end_ways, frame_screw, frame_screw_length);
        }

    translate([X_origin, ribbon_clamp_y,0]) {
        if(base_nuts)
            ribbon_clamp_assembly(bed_ways, base_screw, base_screw_length, sheet_thickness(base), false, true, nutty = true);
        else
            ribbon_clamp_assembly(bed_ways, base_screw, base_screw_length);

    }

    place_cable_clips();

    frame_base();
    if(base_nuts) {
        for(side = [ left_stay_x + fixing_block_height() / 2 + sheet_thickness(frame) / 2,
                    right_stay_x - fixing_block_height() / 2 - sheet_thickness(frame) / 2])
            explode2([0, 0, -4])
            translate([side, 0,  -sheet_thickness(base)]) {
                color("silver") render() base_tube();

                for(end = [-1, 1])
                    translate([0, end * (base_d_LC / 2 - AL_tube_inset + tube_cap_base_thickness() + eta), -tube_height(AL_square_tube) / 2])
                        rotate([90, 0, 90 - 90 * end])
                            explode([0, 0, -20])
                                color("lime") render()
                                    tube_cap_stl();


                translate([0, -(base_d_LC / 2 - fixing_block_width() / 2 - base_clearance), sheet_thickness(base)]) {
                    nut_and_washer(base_nut, true);

                    translate([0, 0, -sheet_thickness(base) - tube_thickness(AL_square_tube)])
                        rotate([180, 0, 0])
                            screw_and_washer(base_screw, base_screw_length);
                }
            }
    }

    if(show_gantry) {


        lc_z_axis_top(true);
        lc_z_axis_top(false);

        lc_z_axis_bottom_assembly(true);
        lc_z_axis_bottom_assembly(false);

        lc_back_top();
        frame_stay(true, eta);
        frame_stay(false);
        frame_gantry();
    }

    end("frame_assembly");
}


module machine_assembly(show_bed = true, show_heatshield = true, show_spool = false) {
    assembly("machine_assembly");

    translate([0,0, sheet_thickness(base)]) {
        bed_fan_assembly();
        electronics_assembly();
        psu_assembly();

        if(show_spool)
            spool_assembly(left_stay_x, right_stay_x);

        translate([0, Y0, 0]) {
            x_axis_assembly(true);
            z_axis_assembly();
        }

        y_axis_assembly(show_bed, show_heatshield);
        //
        // Draw the possibly transparent bits last
        //
        frame_assembly(true);
    }
    end("machine_assembly");
}



machine_assembly(show_bed = true, show_heatshield = true, show_spool = false);
//y_heatshield();
//frame_assembly(show_spool = false);
//y_axis_assembly(true);

//z_axis_assembly();
//x_axis_assembly(false);



module frame_all()  projection(cut=true)
{
    translate([0,0, gantry_Y + sheet_thickness(frame) / 2]) rotate([-90, 0, 0]) frame_gantry();
    translate([-6,130, 0]) rotate([0, 0, 0]) y_carriage();
    translate([0, -base_d_LC / 2 - 10, sheet_thickness(base) / 2]) frame_base();
    translate([-base_w_LC / 2 - 10 + gantry_Y + sheet_thickness(frame), 0, left_stay_x])  rotate([0, 90, 90]) frame_stay(true);
    translate([-base_w_LC / 2 - 10 + gantry_Y + sheet_thickness(frame), -height_LC-10, right_stay_x]) rotate([0, 90, 90]) frame_stay(false);
    translate([ stay_depth_LC + sheet_thickness(frame)-115, height_LC-stay_depth_LC/2+60, -height +gantry_thickness-10]) rotate([0, 0, 0]) lc_back_top();
    translate([ -stay_depth_LC - sheet_thickness(frame)-95, height_LC+40, 0]) rotate([0, 0, 0]) lc_extruder_mount(true);
    translate([ -stay_depth_LC - sheet_thickness(frame)-95, height_LC+45+stay_depth_LC/3, 0]) rotate([0, 0, 0]) lc_extruder_mount(false);
    translate([ -stay_depth_LC - sheet_thickness(frame)-95, height_LC+50+stay_depth_LC*2/3, 0]) rotate([0, 0, 0]) lc_extruder_mount(true);
    translate([295, 195, - sheet_thickness(frame)/4])  rotate([0, 0, 0]) lc_z_axis_top_side();
    translate([285, 195, - sheet_thickness(frame)/4])  rotate([0, 0, 180]) lc_z_axis_top_side();
    translate([295, 260, - sheet_thickness(frame)/4])  rotate([0, 0, 0]) lc_z_axis_top_side();
    translate([285, 260, - sheet_thickness(frame)/4])  rotate([0, 0, 180]) lc_z_axis_top_side();
    translate([290, 330, 0])  rotate([0, 0, 0]) lc_z_axis_top_plate();
    translate([290, 400, 0])  rotate([0, 0, 0]) mirror ([1,0,0])lc_z_axis_top_plate();
    translate([260, 480, 0])   rotate([0, 0, 0]) lc_z_axis_bottom_plate();
    translate([260, 560, 0])   rotate([0, 0, 0]) mirror ([1,0,0])lc_z_axis_bottom_plate();
    translate([290, 130, - sheet_thickness(frame)/4])  rotate([0, 0, 270]) lc_z_axis_bottom_side();
    translate([290, 65, - sheet_thickness(frame)/4])  rotate([0, 0, 270]) lc_z_axis_bottom_side();
    translate([290, 0, - sheet_thickness(frame)/4])  rotate([0, 0, 270]) lc_z_axis_bottom_side();
    translate([290, -65, - sheet_thickness(frame)/4])  rotate([0, 0, 270]) lc_z_axis_bottom_side();
}

module frame_base_dxf() projection(cut = true) translate([0,0, sheet_thickness(base) / 2]) frame_base();

module frame_left_dxf() projection(cut = true) translate([0, -gantry_Y - sheet_thickness(frame), left_stay_x]) rotate([0, 90, 0]) frame_stay(true);

module frame_right_dxf() projection(cut = true) mirror([0,1,0]) translate([0,-gantry_Y - sheet_thickness(frame), right_stay_x]) rotate([0, 90, 0]) frame_stay(false);

module y_carriage_dxf() projection(cut = true) y_carriage();

module y_heatshield_dxf() projection(cut = true) y_heatshield();

module frame_gantry_dxf(drill = !cnc_sheets) {
    corner_rad = window_corner_rad;
    projection(cut = true) translate([0,0, gantry_Y + sheet_thickness(frame) / 2]) rotate([-90, 0, 0]) frame_gantry();
    if(drill)
        for(side = [-1, 1])
            translate([X_origin + side * (window_width / 2 - corner_rad), height - gantry_thickness - corner_rad])
                circle(corner_rad - eta);
}

module frame_gantry_and_y_carriage_dxf() {
    top = height - gantry_thickness;
    bottom = Y_carriage_depth;
    gap = cnc_tool_dia * 2 + 1;
    h = floor(top - bottom - 2 * gap);
    w = floor(window_width - 2 * gap);
    frame_gantry_dxf(false);
    translate([X_origin, Y_carriage_depth / 2]) y_carriage_dxf();
    if(h > 20)
        *translate([X_origin, (top + bottom) / 2])
            square([w, h], center = true);                        // make the offcut a rectangle

}

module frame_stays_dxf() {
    frame_left_dxf();
    translate([0, -4])
        frame_right_dxf();
}

total_height = height + sheet_thickness(base) + (base_nuts ? tube_height(AL_square_tube) : 0);
spool_height = total_height - height + spool_z + spool_diameter(spool) / 2;

echo("Width: ", base_w_LC, " Depth: ", base_d_LC, " Height: ", total_height, " Spool Height:", spool_height);

echo("X bar: ",  X_bar_length, " Y Bar 1: ", Y_bar_length, " Y Bar 2: ", Y_bar_length2, " Z Bar: ", Z_bar_length);
