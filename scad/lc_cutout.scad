//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// LC_Cutout for the T3P3 M90 variant
//
include <conf/config.scad>

frame_slot_w = 6.2;
frame_slot_d = 8.2;
clearance=0;
frame_slot_spacing = 22;
frame_screw_r = 1.45;
frame_screw_l = lc_fixing_screw_length+2; //+2 is to allow either 6mm or 4mm sheet to be used interchangebly
frame_nut = screw_nut(lc_fixing_screw_type);
frame_nut_rad = nut_flat_radius(frame_nut)+clearance/2 -0.14;
frame_nut_t =1.65;
tab_top_r=2;

$fn=20;

module lc_screw_side_cutout(cut_thickness = sheet_thickness(base)){
	lc_screw_cutout(cut_thickness);
  lc_tabs_cutout(cut_thickness);
}

module lc_screw_cutout(cut_thickness = sheet_thickness(base))
{
	cylinder(h=cut_thickness+0.1, r= frame_screw_r,$fn=20, center=true);
}

module lc_tabs_cutout(cut_thickness = sheet_thickness(base)) {
	for(i=[-1,1])
		translate([0,i*frame_slot_spacing/2,0])
			lc_tab_cutout(cut_thickness);
}

module lc_tab_cutout(cut_thickness = sheet_thickness(base)){
	cube([frame_slot_w+clearance,frame_slot_d+clearance,cut_thickness+0.1], center=true);
}

module lc_nut_side_cutout(cut_thickness = sheet_thickness(base), cutout=true){
	adjustment = (cutout ? 0 : -0.5);
	union(){
		translate([0,-(frame_screw_l-cut_thickness+adjustment)/2,0])
			cube([frame_screw_r*2+adjustment,frame_screw_l-cut_thickness+0.1+adjustment,cut_thickness+0.1+adjustment], center=true);
		translate([0,-(frame_screw_l-cut_thickness)/2-0.5,0])
			cube([frame_nut_rad*2+adjustment,frame_nut_t+adjustment,cut_thickness+0.1+adjustment], center=true);
	}
}

module lc_tabs(cut_thickness = sheet_thickness(base)){
	for(i=[-1,1])
		translate([i*frame_slot_spacing/2,0,0]){
      lc_tab(cut_thickness);
	}
}

//Single locating tab
module lc_tab(cut_thickness = sheet_thickness(base)){
			translate([0,(cut_thickness-tab_top_r)/2,0])
				cube([frame_slot_d,cut_thickness-tab_top_r,cut_thickness], center=true);
			translate([0,cut_thickness-tab_top_r/2-0.1,0])
				cube([frame_slot_d-tab_top_r*2,tab_top_r+0.2,cut_thickness], center=true);
			for(j=[-1,1])
				translate([j*(frame_slot_d/2-tab_top_r),cut_thickness-tab_top_r,0])
					cylinder(h=cut_thickness,r=tab_top_r,center=true);
}

module lc_fixing_screw(cut_thickness = sheet_thickness(base)){
	translate([0,0,sheet_thickness(base)/2])
		screw_and_washer(lc_fixing_screw_type, lc_fixing_screw_length, true);
	translate([0,0,-(frame_screw_l+cut_thickness)/2+1])
		nut(frame_nut, false,false);
}

module lc_blank_stl(cut_thickness = sheet_thickness(base)){
  lc_nut_side_cutout(cut_thickness,false);
}

//example
if(1){
	%difference() {
		union(){
			cube([40,60,sheet_thickness(base)],center=true);//box for the cutouts to display on
			translate([0,30,0])
				lc_tabs(sheet_thickness(base));
			translate([-15,0,0])
				lc_fixing_screw(sheet_thickness(base));
			rotate([0,0,180])
				translate([0,30,0])
					lc_tab(sheet_thickness(base));
		}
		translate([-15,0,0])
			lc_screw_side_cutout(sheet_thickness(base));
  		translate([0,30,0])
			lc_nut_side_cutout(sheet_thickness(base));
	}
	translate([-15,0,-30-sheet_thickness(base)/2]) rotate([90,0,90])
		difference() {
			union(){
				cube([40,60,sheet_thickness(base)],center=true);//box for the cutouts to display on
				translate([0,30,0])
					lc_tabs(sheet_thickness(base));
			}
		translate([-15,0,0])
			lc_screw_side_cutout(sheet_thickness(base));
		translate([15,0,0])
			lc_tab_cutout(sheet_thickness(base));
  		translate([0,30,0])
			lc_nut_side_cutout(sheet_thickness(base));
	}
}
else
lc_blank_stl(sheet_thickness(base)); //Blanking fitting for LC nut slots