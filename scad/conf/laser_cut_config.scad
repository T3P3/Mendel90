//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Configuration file
//

echo("LaserCut:");

Z_bearings = LM8UU;
Y_bearings = LM8UU;
X_bearings = LM8UU;

X_motor = NEMA17;
Y_motor = NEMA17;
Z_motor = NEMA17;

hot_end = JHeadMk5;

X_travel = 200;
Y_travel = 200;
Z_travel = 200;

bed_depth = 214;
bed_width = 214;
bed_pillars = M3x20_pillar;
bed_glass = glass2;
bed_thickness = pcb_thickness + sheet_thickness(bed_glass);    // PCB heater plus glass sheet
bed_holes = 209;

base = MelamineMDF6;          
base_corners = 0;
base_nuts = true;

frame = MelamineMDF6;
frame_corners = 0;
frame_nuts = true;

case_fan = fan80x38;
psu = ALPINE500;
controller = RAMPS;
spool = spool_300x85;
bottom_limit_switch = false;
top_limit_switch = true;

single_piece_frame = true;
stays_from_window = false;
cnc_sheets = true;                 // If sheets are cut by CNC we can use slots, etc instead of just round holes
lc_sheets = true; //use the laser cut fixing method and additional slots for ease of assembly
lc_fixing_offset=24; //how far from an edge to put a LC fixing
lc_fixing_screw_type = M3_cap_screw;  
lc_fixing_screw_length = 16; //sheet_thickness(base)+10;

//additional dimensions for some sheets for LC M90
base_w_LC = 468.5+35;//base_width+10+25;
base_d_LC = 425+28;//base_depth+28;
height_LC = 390+12+30;//height+12+53;
stay_depth_LC=166+14;//stay_depth+14;
stay_height_LC=height_LC;


pulley_type = T2p5x16_metal_pulley;

Y_carriage = DiBond;

X_belt = T2p5x6;
Y_belt = T2p5x6;

motor_shaft = 5;
Z_screw_dia = 5;            // Studding for Z axis

Y_carriage_depth = bed_holes + 7;
Y_carriage_width = bed_holes + 7;

Z_nut_radius = M5_nut_radius;
Z_nut_depth = M5_nut_depth;
Z_nut = M5_nut;

//
// Default screw use where size doesn't matter
//
cap_screw = M3_cap_screw;
hex_screw = M3_hex_screw;
//
// Screw for the frame and base
//
frame_soft_screw = No6_screw;               // Used when sheet material is soft, e.g. wood
frame_thin_screw = M4_cap_screw;            // Used with nuts when sheets are thin
frame_thick_screw = M4_pan_screw;           // Used with tapped holes when sheets are thick and hard, e.g. plastic or metal
//
// Feature sizes
//
default_wall = 3;
thick_wall = 4;
