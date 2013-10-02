//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// End caps for the aluminium box tubes used on the dibond version
//
include <conf/config.scad>
include <positions.scad>

wall = 3;
clearance = 0.25;
boss = washer_diameter(M3_washer) + 1;
punch = 3;
base_screw_offset = fixing_block_width() / 2 + base_clearance - AL_tube_inset;
length = wall + base_screw_offset + 10;
width = tube_width(AL_square_tube) + 2 * wall + clearance;

function tube_cap_base_thickness() = 3 * layer_height;
function tube_jig_base_thickness() = wall;

module base_tube() {
    difference() {
        translate([0, 0, -tube_height(AL_channel) / 2])
            rotate([90, 0, 0])
                square_tube(AL_channel, base_depth - 2 * AL_tube_inset);

        for(end = [-1,1])
            translate([0, end * (base_depth / 2 - fixing_block_width() / 2 - base_clearance), -tube_height(AL_channel)]) {
                base_screw_hole();
                cylinder(r = screw_head_radius(base_screw) + 0.5, h = tube_thickness(AL_channel) * 2 + 1, center = true);
            }
    }
}

module channel_cap_stl() {
    stl("channel_cap");
    h = tube_height(AL_channel);
    w = tube_width(AL_channel);
    t = tube_thickness(AL_channel);
    clearance = 0.3;

    base_thickness = tube_cap_base_thickness();

    w_outer = w - 1;
    h_outer = h - 2;
    w_inner_base = w - t*2;
    w_inner_top  = w_inner_base - clearance;
    h_inner_base = h - t*2;
    h_inner_top  = h_inner_base - clearance;

    union() {
        translate([-w_outer / 2, - h_outer / 2, 0])
            cube([w_outer, h_outer, base_thickness]);

        hull() {
            translate([-w_inner_top/2 ,(-h_inner_top)/2-(h_outer-h_inner_top)/2, 0])
                cube([w_inner_top, h_inner_top+(h_outer-h_inner_top)/2, 5]);

            translate([-w_inner_base / 2, - h_inner_base / 2, 0])
                cube([w_inner_base, h_inner_base, base_thickness + 1]);
        }
    }
}

channel_cap_stl();


