///////////////////////////////////////////////////////////////
// Ballast generator with tie cut-outs oriented across the width.
//
// - Layer 1: solid 10‑stud ring with studs on inner & outer edges.
// - Layer 2: 8‑stud ring with a 2‑stud central gap, 1‑stud rail cutouts,
//   end notches, and `num_ties` rectangular cut-outs (2×8 tiles)
//   oriented so the long side spans the full radial width.
//
// Parameters:
//   radius_studs – radius of the curved segment.
//   angle_deg    – sweep of the segment.
//   num_ties     – number of 2×8 cut-outs to remove from layer 2.
///////////////////////////////////////////////////////////////

stud  = 8.0;
plate = 3.2;
stud_d = 4.8;
stud_h = 1.8;

wall_width = 0.8;

// Fixed sizes in studs
width1_studs            = 10;
width2_studs            = 8;
tie_gap_studs           = 2;
notch_thickness_studs   = 1;
tie_cutout_depth_studs  = 2; // now interpreted as arc thickness (2 studs)
tie_cutout_length_studs = 8; // interpreted as radial width (8 studs)

// Define brick footprint (1 stud x 10 studs) and thickness
//brick_depth  = 1 * stud;     // 1 stud along the arc
brick_inside_length = width1_studs * stud - (2 * wall_width) ;    // 10 studs across the width

// --- Underside grip tubes (anti-studs) ---
tube_outer_d = 3.2;   // stud distance between
tube_inner_d = 2.2;   // 
tube_h       = 3.2;   // how far the tube extends downward (mm)

stud_arc_len = 4 * stud;   // 4 studs along arc
stud_row_radial_offset = 0.5 * stud;  // centered on layer 2 surface

end_clearance_mm = 1.0;  // <-- tweak (try 0.6–1.2)


module ballast_segment(radius_studs=24, angle_deg=22.5, num_ties=0,adjust_rail_thickness=0) {
    base_h   = plate;
    raised_h = plate;
    r_center = radius_studs * stud;

    // Radii for layers
    r1_in  = r_center - (width1_studs/2) * stud;
    r1_out = r_center + (width1_studs/2) * stud;
    r2_in  = r_center - (width2_studs/2) * stud;
    r2_out = r_center + (width2_studs/2) * stud;

    // Central gap on layer 2
    r_gap_in  = r_center - (tie_gap_studs/2) * stud;
    r_gap_out = r_center + (tie_gap_studs/2) * stud;

    // Rail cutouts on layer 2
    rail_cutout_outer_in  = r2_out - 2 * stud-(adjust_rail_thickness/2);
    rail_cutout_outer_out = r2_out - 1 * stud;
    rail_cutout_inner_in  = r2_out - 7 * stud;
    rail_cutout_inner_out = r2_out - 6 * stud+(adjust_rail_thickness/2);

    end_clearance_deg = (end_clearance_mm / r2_in) * 180 / PI;
    // End notch size
    notch_angle_deg = notch_thickness_studs * stud / r_center * 180 / PI;

    // Each tie cut-out has a tangential half-angle based on 2‑stud thickness
    tie_cutout_half_deg = (tie_cutout_depth_studs * stud / 2) / r_center * 180 / PI;

    // Angles for tie cut-outs evenly spaced along the arc
    tie_angles = (num_ties > 0)
        ? [ for (i = [1 : num_ties]) (i / (num_ties + 1)) * angle_deg ]
        : [];
    usable_start = notch_angle_deg;
    usable_end   = angle_deg - notch_angle_deg;

    // tie_angles is your existing list of tie CENTER angles
    bounds = concat([usable_start], tie_angles, [usable_end]);

    // Skip regions: end notches + tie cut-outs
    skip_regions = concat(
        [ [0, notch_angle_deg],
          [angle_deg - notch_angle_deg, angle_deg] ],
        [ for (a_i = tie_angles)
            [ a_i - tie_cutout_half_deg, a_i + tie_cutout_half_deg ] ]
    );

    
    gap_angles =
    concat(
        [usable_start],
        tie_angles,
        [usable_end]
    );

    

    // --- Layer 1 ---
    
    difference() {
        linear_extrude(height = base_h)
            annular_sector(r1_in, r1_out, 0, angle_deg);
        // Subtract a recess at the start (0°)
        rotate([0,0,0])
        translate([r1_in+wall_width, +wall_width, 0])
            cube([10*stud-(2*wall_width), 1*stud-(2.5*wall_width), base_h-wall_width], center=false);

        // Subtract a recess at the end (angle_deg)
        rotate([0,0,angle_deg])
        translate([r1_in+wall_width, -(1*stud)+(wall_width), 0])
           cube([10*stud-(2.5*wall_width), 1*stud-(2*wall_width), base_h-wall_width], center=false);

        // Subtract the edge recess
        // --- Inside arc bottom cutout ---
        linear_extrude(height = base_h - wall_width)
            annular_sector(
                r1_in + wall_width, 
                r1_in + 1*stud, 
                notch_angle_deg, 
                angle_deg - notch_angle_deg
            );

        // --- Outside arc bottom cutout ---
        linear_extrude(height = base_h - wall_width)
            annular_sector(
                r1_out + wall_width - 1*stud, 
                r1_out - wall_width, 
                notch_angle_deg, 
                angle_deg - notch_angle_deg
            );

        translate([r1_in+40, 17, 0])  
        mirror([1,0,0])     
        // position the text under the layer
        linear_extrude(height = plate/2)
            text(str("R", radius_studs, " - ", angle_deg, "°"),
                 size = 7,
                 halign = "center",
                 valign = "center");

        for (a_i = tie_angles) {
            rotate([0,0,a_i])
            // place the cut-out so it spans the full radial width from r2_in to r2_out
            translate([r2_in+(2*stud), - (tie_cutout_depth_studs * stud) / 2, 0])
                cube([ (width2_studs * stud / 2),
                       tie_cutout_depth_studs * stud,
                       raised_h ], center=false);
        }
    }
    // After layer 1 geometry is created (and recesses subtracted):
    end_grip_tubes_layer1(0, r1_in, stud/2-(wall_width/2));
    end_grip_tubes_layer1(angle_deg, r1_in, -stud/2+(wall_width/2));

    // --- Layer 2: minus gaps, rail cutouts, end notches, tie cut-outs ---
    translate([0,0, base_h])
    difference() {
        // base shape
        linear_extrude(height = raised_h)
            annular_sector(r2_in, r2_out, 0, angle_deg);

        // rail cutouts
        linear_extrude(height = raised_h)
            annular_sector(rail_cutout_outer_in, rail_cutout_outer_out, 0, angle_deg);
        linear_extrude(height = raised_h)
            annular_sector(rail_cutout_inner_in, rail_cutout_inner_out, 0, angle_deg);

        // end notches
        linear_extrude(height = raised_h)
            annular_sector(r2_in, r2_out, -end_clearance_deg, notch_angle_deg + end_clearance_deg);
        linear_extrude(height = raised_h)
            annular_sector(r2_in, r2_out, angle_deg - notch_angle_deg - end_clearance_deg, angle_deg + end_clearance_deg);
        // tie cut-outs oriented across the width:
        // long side (8 studs) along radial direction, short side (2 studs) along arc direction
        for (a_i = tie_angles) {
            rotate([0,0,a_i])
            // place the cut-out so it spans the full radial width from r2_in to r2_out
            translate([r2_in, - (tie_cutout_depth_studs * stud) / 2, 0])
                cube([ (width2_studs * stud),
                       tie_cutout_depth_studs * stud,
                       raised_h ], center=false);
        }
    }

    // --- Stud rows on layer 1 ---
    place_stud_row_with_skips(r1_in + 0.5 * stud, 0, angle_deg, base_h, []);

    place_stud_row_with_skips(r1_out - 0.5 * stud, 0, angle_deg, base_h, []);

    // --- Stud rows on layer 2 (skip end notches + tie regions) ---
    
    
    //Old
    //place_stud_row_with_skips(r2_in + 0.5 * stud, 0, angle_deg, base_h + raised_h, skip_regions);
    //place_stud_row_with_skips(r2_out - 0.5 * stud, 0, angle_deg, base_h + raised_h, skip_regions);

    tie_half_deg = ((2 * stud) / 2) / r_center * 180 / PI;  // half of 2-stud arc thickness

    stud_rows_between_ties(
        bounds,
        r_center,
        base_h + raised_h,
        tie_half_deg
    );

}

module subtract_brick_end(angle, r1_in) {
    rotate([0,0, angle])
    translate([r1_in, -stud/2, 0])
        cube([stud, brick_inside_length, plate], center=false);
}

// Places studs along a row, skipping any angle intervals in skip_regions.
module place_stud_row_with_skips(r, a0_deg, a1_deg, z_height, skip_regions=[]) {
    arc_len = (a1_deg - a0_deg) * PI / 180 * r;
    n = max(1, floor(arc_len / stud));
    step_deg = (a1_deg - a0_deg) / n;

    for (i = [0 : n-1]) {
    a = a0_deg + (i + 0.5) * step_deg;

    // Build a list containing a single element (e.g. 1) for each skip region
    // that contains angle 'a'. If no skip region matches, the list is empty.
    matches = [ for (reg = skip_regions)
        if ((a >= reg[0]) && (a <= reg[1]))
            1
    ];

    // If matches is empty (length zero), then place the stud.
    if (len(matches) == 0) {
        x = r * cos(a);
        y = r * sin(a);
        translate([x, y, z_height])
            cylinder(d = stud_d, h = stud_h, $fn = 24);
    }
}
}

module stud_rows_between_ties(bounds, r_center, z_height, tie_half_deg) {

    row_pitch_deg = (1 * stud) / r_center * 180 / PI;   // 4 studs along arc

    for (i = [0 : len(bounds)-2]) {

        // raw boundary centers
        left  = bounds[i];
        right = bounds[i+1];

        // shrink the usable gap so rows stay BETWEEN tie cutouts
        // For the ends, usable_start/end already account for notch, so we only
        // shrink by tie_half_deg when the boundary is a tie.
        left_is_end  = (i == 0);
        right_is_end = (i == len(bounds)-2);

        gap_start = left  + (left_is_end  ? 0 : tie_half_deg);
        gap_end   = right - (right_is_end ? 0 : tie_half_deg);

        gap_span = gap_end - gap_start;

        if (gap_span > 0) {

            // maximum rows that fit at exact 4-stud pitch
            rows = floor(gap_span / row_pitch_deg);

            if (rows > 0) {

                gap_center = (gap_start + gap_end) / 2;
                start_angle = gap_center - (rows - 1) * row_pitch_deg / 2;

                for (j = [0 : rows-1]) {
                    a = start_angle + j * row_pitch_deg;

                    // 4 studs across width (adjust this if you want different radial placement)
                    rotate([0,0,a])
                        translate([r_center + -3.5 * stud, 0, z_height])
                            cylinder(d=stud_d, h=stud_h, $fn=24);
                    rotate([0,0,a])
                        translate([r_center + 3.5 * stud, 0, z_height])
                            cylinder(d=stud_d, h=stud_h, $fn=24);
                    for (k = [-1.5 : 1 : 1.5]) {
                        rotate([0,0,a])
                            translate([r_center + k * stud, 0, z_height])
                                cylinder(d=stud_d, h=stud_h, $fn=24);
                    }
                }
            }
        }
    }
}

module anti_stud_tube() {
    difference() {
        translate([0,0,(tube_h-2.0)])
            cylinder(d=tube_outer_d, h=tube_h, $fn=48);
        translate([0,0,-tube_h])
            cylinder(d=tube_inner_d, h=tube_h, $fn=48);
    }
}


// Place a row of 10 anti-stud tubes inside the layer-1 end gap (1x10)
module end_grip_tubes_layer1(a_deg, r1_in, y_offset) {
  rotate([0,0,a_deg]) {
    // 9 tubes between 10 stud positions along the 10-stud radial recess
    for (i = [0:8]) {
      x = r1_in + (i + 1) * stud;   // between studs: 1..9 studs from r1_in
      y = y_offset;  // centered in the 1-stud tangential thickness
      translate([x, y, -1.2])
        anti_stud_tube();
    }
  }
}


// Draw an annular sector (helper)
module annular_sector(r_in, r_out, a0_deg, a1_deg, fn=180) {
    pts_out = [ for (i = [0:fn])
        let(t = i / fn, a = a0_deg + (a1_deg - a0_deg) * t)
            [ r_out * cos(a), r_out * sin(a) ] ];
    pts_in = [ for (i = [fn:-1:0])
        let(t = i / fn, a = a0_deg + (a1_deg - a0_deg) * t)
            [ r_in * cos(a), r_in * sin(a) ] ];
    polygon(concat(pts_out, pts_in));
}

// Example usage:
// ballast_segment(radius_studs=24, angle_deg=22.5, num_ties=1);
// ballast_segment(radius_studs=32, angle_deg=22.5, num_ties=2);
// ballast_segment(radius_studs=40, angle_deg=22.5, num_ties=3);
// ballast_segment(radius_studs=56, angle_deg=22.5, num_ties=4);

//R104
//ballast_segment(radius_studs=104, angle_deg=11.25, num_ties=4);
// AliExpress Injected Rails
//ballast_segment(radius_studs=104, angle_deg=11.25, num_ties=4, adjust_rail_thickness=2);

// ballast_segment(radius_studs=120, angle_deg=11.25, num_ties=4);
// ballast_segment(radius_studs=136, angle_deg=5.625, num_ties=2);

//R152
//ballast_segment(radius_studs=152, angle_deg=5.625, num_ties=3);
//AliExpress Injected Rails
ballast_segment(radius_studs=152, angle_deg=5.625, num_ties=3, adjust_rail_thickness=2);

