/********************************************************
 * SmartiPi Touch 2 Speaker Dock - vsergeev
 * https://github.com/vsergeev/3d-smartipi-touch-2-speaker-dock
 * CC-BY-4.0
 *
 * Uses four M4x8 bolts and M4 nuts to attach the SmartiPi Touch 2 case to the
 * dock.
 *
 * Release Notes
 *  * v1.0 - 06/20/2023
 *      * Initial release.
 ********************************************************/

/* [Part Selection] */

part = "dock"; // [dock, antitip]

/* [Advanced] */

dock_x_width = 221.61;
dock_y_depth = 65;
dock_xyz_thickness = 3;
dock_top_xyz_thickness = 6;
dock_xy_radius = 5;

dock_feet_x_width = 10;
dock_feet_z_offset = 2;
dock_feet_x_offset = 0.80;
dock_feet_yz_angle = 12.5;

speaker_xyz_clearance = 2;
speaker_x_width = 180 + speaker_xyz_clearance;
speaker_y_depth = 35;
speaker_z_height = 48 + speaker_xyz_clearance;
speaker_lip_z_height = 5;

mounting_hole_nut_xy_clearance = 0.5;
mounting_hole_nut_xy_width = 7.66;
mounting_hole_nut_z_height = 4;
mounting_hole_bore_xy_diameter = 4.25;

// reportedly 159.02, but was too wide
mounting_hole_x_pitch = 156.00;
mounting_hole_y_pitch = 30;
mounting_hole_x_offset = (dock_x_width - 221.61) / 2 + 16.50;
mounting_hole_y_offset = (dock_y_depth - 30) / 2;

anti_tip_bracket_x_width = 20;
anti_tip_bracket_y_depth = 15;
anti_tip_bracket_yz_thickness = 3;
anti_tip_bracket_yz_clearance = 0.3;
anti_tip_bracket_yz_angle = 45;
anti_tip_bracket_yz_radius = 1;

/* [Hidden] */

$fn = 100;

overlap_epsilon = 0.01;

/******************************************************************************/
/* Derived Variables */
/******************************************************************************/

dock_z_height = dock_xyz_thickness + speaker_z_height + dock_top_xyz_thickness;

mounting_hole_positions = [ for (x = [0, 1], y = [0, 1])
                                [mounting_hole_x_offset + x * mounting_hole_x_pitch,
                                 mounting_hole_y_offset + y * mounting_hole_y_pitch] ];

/******************************************************************************/
/* Helper Operations */
/******************************************************************************/

module radius(r) {
    offset(r=r)
        offset(delta=-r)
            children();
}

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module profile_dock_xy_footprint() {
    union() {
        /* Radius in the front */
        radius(dock_xy_radius)
            square([dock_x_width, dock_y_depth], center=true);

        /* Rectangular in the back */
        translate([0, dock_y_depth / 4])
            square([dock_x_width, dock_y_depth / 2], center=true);
    }
}

module profile_speaker_body_xz_footprint() {
    square([speaker_x_width, speaker_z_height], center=true);
}

module profile_speaker_back_xz_footprint() {
    difference() {
        profile_speaker_body_xz_footprint();
        translate([0, -(speaker_z_height - speaker_lip_z_height) / 2])
            square([speaker_x_width + overlap_epsilon, speaker_lip_z_height + overlap_epsilon], center=true);
    }
}

module profile_dock_feet_yz_footprint() {
    polygon([[0, 0], [0, dock_y_depth], [-dock_feet_z_offset, dock_y_depth], [-dock_feet_z_offset + -dock_y_depth * tan(dock_feet_yz_angle), 0]]);
}

module profile_mounting_hole_nut_xy_footprint() {
    circle(d=mounting_hole_nut_xy_width + mounting_hole_nut_xy_clearance, $fn=6);
}

module profile_mounting_hole_bore_xy_footprint() {
    circle(d = mounting_hole_bore_xy_diameter);
}

module profile_mounting_access_cutout_xy_footprint() {
    circle(d = mounting_hole_nut_xy_width * 2);
}

module profile_anti_tip_bracket_yz_footprint() {
    lip_width = anti_tip_bracket_y_depth + anti_tip_bracket_yz_thickness;
    lip_height = anti_tip_bracket_yz_thickness * 2 + dock_top_xyz_thickness;

    leg_height = dock_feet_z_offset + dock_z_height + (lip_height - dock_top_xyz_thickness) / 2;
    leg_x_adjustment = cos(dock_feet_yz_angle);
    leg_y_adjustment = tan(anti_tip_bracket_yz_angle) * sin(dock_feet_yz_angle);

    union() {
        difference() {
            /* Lip Profile */
            translate([-lip_width / 2, 0])
                square([lip_width, lip_height], center=true);

            /* Cutout for Dock Top */
            translate([-(anti_tip_bracket_y_depth + anti_tip_bracket_yz_thickness - anti_tip_bracket_yz_clearance / 2), 0])
                square([anti_tip_bracket_y_depth * 2, dock_top_xyz_thickness + anti_tip_bracket_yz_clearance], center=true);
        }

        translate([0, lip_height / 2]) {
            /* Leg Profile */
            polygon([[0, 0],
                     [leg_height * tan(anti_tip_bracket_yz_angle) * leg_x_adjustment, -leg_height + leg_height * leg_y_adjustment],
                     [(leg_height - lip_height) * tan(anti_tip_bracket_yz_angle) * leg_x_adjustment, -leg_height + (leg_height - lip_height) * leg_y_adjustment],
                     [0, -lip_height]]);
        }
    }
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module speaker_cutout() {
    union() {
        /* Speaker body */
        translate([0, speaker_y_depth, speaker_z_height / 2 + dock_xyz_thickness])
            rotate([90, 0, 0])
                linear_extrude(speaker_y_depth + overlap_epsilon)
                    profile_speaker_body_xz_footprint();

        /* Speaker opening for back */
        translate([0, dock_y_depth * 1.5, speaker_z_height / 2 + dock_xyz_thickness])
            rotate([90, 0, 0])
                linear_extrude(dock_y_depth * 1.5)
                    profile_speaker_back_xz_footprint();
   }
}

module dock() {
    difference() {
        union() {
            /* Dock frame */
            translate([0, dock_y_depth / 2, 0])
                linear_extrude(dock_z_height)
                    profile_dock_xy_footprint();

            /* Dock feet */
            for (i = [-1, 1]) {
                translate([dock_feet_x_width / 2 + i * dock_feet_x_offset * dock_x_width / 2, 0])
                    rotate([0, -90, 0])
                        linear_extrude(dock_feet_x_width)
                            profile_dock_feet_yz_footprint();
            }
        }

        /* Speaker cutout */
        speaker_cutout();

        /* Mounting hole bores */
        for (pos = mounting_hole_positions) {
            translate([pos[0] - dock_x_width / 2, pos[1], dock_z_height - dock_top_xyz_thickness * 1.5])
                linear_extrude(dock_top_xyz_thickness * 2)
                    profile_mounting_hole_bore_xy_footprint();
        }

        /* Mounting hole nuts */
        for (pos = mounting_hole_positions) {
            translate([pos[0] - dock_x_width / 2, pos[1], dock_z_height - dock_top_xyz_thickness - overlap_epsilon])
                linear_extrude(mounting_hole_nut_z_height + overlap_epsilon)
                    profile_mounting_hole_nut_xy_footprint();
        }

        /* Mounting hole access cutouts */
        for (pos = mounting_hole_positions) {
            translate([pos[0] - dock_x_width / 2, pos[1], dock_z_height - dock_top_xyz_thickness - mounting_hole_nut_z_height - overlap_epsilon])
                linear_extrude(mounting_hole_nut_z_height + overlap_epsilon)
                    profile_mounting_access_cutout_xy_footprint();
        }
    }
}

module anti_tip_bracket() {
    linear_extrude(anti_tip_bracket_x_width)
        radius(anti_tip_bracket_yz_radius)
            profile_anti_tip_bracket_yz_footprint();
}

/******************************************************************************/
/* Top Level */
/******************************************************************************/

if (part == "dock") {
    dock();
} else if (part == "antitip") {
    anti_tip_bracket();
}
