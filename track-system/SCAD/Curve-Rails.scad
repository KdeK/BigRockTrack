/*****************************************************************************************
* File: Curve-Rails.scad
* Author: Ken
* Date: 2026-01-27
* Description:
*   OpenSCAD script for generating customizable curved LEGO-compatible train track rails.
*   - Supports multiple radii and segment angles for various curve types (R24, R32, R40, etc).
*   - Generates rail profiles, endpoints, connectors, and optional crossbars.
*   - Designed for 3D printing and compatible with LEGO and 4DBrix standards.
*   - Main entry point: main(Radius, SegAng)
*   - Adjust parameters at the top of the file to select curve type.
*
* Usage:
*   Set the desired SegAng and Radius at the top of the file.
*   Render or export the model for 3D printing.
******************************************************************************************/

// Curve type presets (uncomment to select different radii/angles)
//  R24
// SegAng = 22.5; Radius = 24;  full = true; diverse = 2000;
//  R32
// SegAng = 22.5; Radius = 32;  full = true; diverse = 2000;
// R40 - Lego Standard
// R56 - 4DBrix
// R72 - 4DBrix
// R88 - 4DBrix
//  R104
// SegAng = 11.25; Radius = 104;  full = true; diverse = 2000;
//  R120
SegAng = 11.25; Radius = 120;  full = true; diverse = 2000;
//  R136
//SegAng = 5.625; Radius = 136;  full = true; diverse = 2000;
//  R152
//SegAng = 5.625; Radius = 152;  full = true; diverse = 1800;


// RailProfile: Defines the cross-sectional profile of a single rail
module RailProfile()
{
    translate ([0,1.5,0])polygon(points=[
    [1,4.7],[1,4.5],[1.2,4.5],[1.2,0.4],[1.6,-0.7],[3,-1.1],[3,-1.7],[3.9,-1.7],[3.9,-4.7],[2.6,-4.7],[2.6,-4.3],[2.5,-4.3],[2.5,-2.3],[-2.5,-2.3],[-2.5,-4.3],[-2.6,-4.3],[-2.6,-4.7],[-3.9,-4.7],[-3.9,-1.7],[-3,-1.7],[-3,-1.1],[-1.6,-0.7],[-1.2,0.4],[-1.2,4.5],[-1,4.5],[-1,4.7],[-0.1,4.7],[-0.1,4.5],[0.1,4.5],[0.1,4.7],[1,4.7]], convexity = 10);
}

// Track gauge (distance between rails)
TrakGage = 39.8;

// rail_endpoint_right: Generates the right-side end geometry for a rail
module rail_endpoint_right() {
  off_l=0.5;
  off_h=-0.15;
    poly = [[0,2],[0,6],[3.2+off_h,6],[3.2+off_h,4],[9.4,4],[9.4,3.1],[7,3.1],[4,2],[3.2+off_h,2]];
    translate([0,off_l,0]) rotate([90,-90,180]) linear_extrude(8-off_l) polygon(poly);
}

// rail_endpoint_left: Generates the left-side end geometry for a rail, including support
module rail_endpoint_left() {
  off_l=0.5;
  off_h=0.515;
    poly = [[3+off_h,8],[3+off_h,4],[9.4,4],[9.4,3.05],[7,3.05],[4,1],[3+off_h,1]];
    translate([0,off_l,0]) rotate([90,-90,180]) linear_extrude(8-off_l) polygon(poly);
    // support
    translate([-1.5,off_l,0]) cube([8,1,3+off_h], false);
}

// attach_poly: Helper for generating the attachment polygon for connectors
module attach_poly(h) {
 off_l=0.3;
     linear_extrude(h) polygon([[0-off_l,0],[2-off_l,1.9],[6+off_l,1.9],[8+off_l,0]]);
}

// attach: Generates the connector geometry for joining track segments
module attach(l) {
    off=0.1;
    union() {
        difference() {
            union() {
                // Cylinders and cubes for connector pegs and sockets
                translate ([-4,0,3]) cylinder(d=4.9,h=2, $fn = 50);
                translate ([-8,-4,0]) cube([8.3,8,3.2], false);
                translate ([12,0,3]) cylinder(d=4.9,h=2, $fn = 50);
                translate ([20,0,3]) cylinder(d=4.9,h=2, $fn = 50);
                translate ([28,0,3]) cylinder(d=4.9,h=2, $fn = 50);
                translate ([36,0,3]) cylinder(d=4.9,h=2, $fn = 50);
                translate ([52,0,3]) cylinder(d=4.9,h=2, $fn = 50);
                translate ([48,-4,0]) cube([8,8,3.2], false);
                if (!full) translate([7.5,0,0])cube([33,10,0.4], false);
                translate([8,0,0])cube([33,3.2,3.2], false);
                difference() {
                    translate ([8.2,-4,0]) cube([35.6,8,3.2], false);
                    translate ([12,-4.11,-0.5]) attach_poly(4);
                }
                difference() {
            union() {
                    translate ([16,-2.2,0]) cylinder(3.2,1,1,false, $fn = 80);
                    translate ([16,-4,0]) cylinder(3.2,1.9-off,1.9+off,false, $fn = 80);
            }
            translate ([16,-4,-0.5]) cylinder(4,1,1,false, $fn = 80);
                }
                translate ([28,-3.4,0]) mirror([0,1,0]) attach_poly(3.2);
            }
            translate ([32,-3.8,-0.5]) cylinder(4,2.1+off,2.1-off,false, $fn = 80);
                translate ([-4,0,0]) translate ([-2.5,-2.5,-1])cube([5,5,3.2], false);
                translate ([12,0,0]){
                    translate ([-2.5,-2.5,-1])cube([2.5,2.5,3.2], false);
                    translate ([0,0,-1])cube([2.5,2.5,3.2], false);
                    translate ([-2.5,0,-1])cube([2.5,2.5,3.2], false);
                    translate ([0,0,-1])cylinder(d=5,h=3.2, $fn = 50);
                }
                translate ([20,0,0]){
                    translate ([0,-2.5,-1])cube([2.5,2.5,3.2], false);
                    translate ([0,0,-1])cube([2.5,2.5,3.2], false);
                    translate ([-2.5,0,-1])cube([2.5,2.5,3.2], false);
                    translate ([0,0,-1])cylinder(d=5,h=3.2, $fn = 50);
                }
                translate ([28,0,0]){
                    translate ([-2.5,-2.5,-1])cube([2.5,2.5,3.2], false);
                    translate ([0,0,-1])cube([2.5,2.5,3.2], false);
                    translate ([-2.5,0,-1])cube([2.5,2.5,3.2], false);
                    translate ([0,0,-1])cylinder(d=5,h=3.2, $fn = 50);
                }
                translate ([36,0,0]) {
                    translate ([0,-2.5,-1])cube([2.5,2.5,3.2], false);
                    translate ([0,0,-1])cube([2.5,2.5,3.2], false);
                    translate ([-2.5,0,-1])cube([2.5,2.5,3.2], false);
                    translate ([0,0,-1])cylinder(d=5,h=3.2, $fn = 50);
                }
                translate ([52,0,-1]) translate ([-2.5,-2.5,0])cube([5,5,3.2], false);			
        }
                
    }
}

// full_endpoint: Combines left and right endpoints with connector
module full_endpoint() {
    translate([0,-8,0]) rail_endpoint_left();
    translate([40,-8,0]) rail_endpoint_right();
    attach(8);
}

// CurvedRail: Generates the main curved rail geometry for given radius and angle
module CurvedRail(CurveRad,CurveSegAng)
{
    rotate_extrude(angle = CurveSegAng, convexity = 10, $fn = 9*CurveRad)
    {
        translate([-0.5*TrakGage-0.125+CurveRad,0,0])RailProfile();
        translate([0.5*TrakGage+0.125+CurveRad,0,0])RailProfile();
    }
}

// barreau: Generates crossbars (sleepers/ties) between rails, if 'full' is true
module barreau() {
    if (full){
        skip = 0.3;
        translate([-16,0,0]){difference(){ union(){
            translate([-8,-8,0]) cube([8+skip,16,3.2], false);
            translate ([-4,-4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([12,-4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([20,-4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([28,-4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([36,-4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([52,-4,3]) cylinder(d=4.9,h=2, $fn = 50);
            
            translate([8-skip,-8,0]) cube([32+(2*skip),16,3.2], false);	
                
            translate ([-4,4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([12,4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([20,4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([28,4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([36,4,3]) cylinder(d=4.9,h=2, $fn = 50);
            translate ([52,4,3]) cylinder(d=4.9,h=2, $fn = 50);
                
            translate([48-skip,-8,0]) cube([8+skip,16,3.2], false);
            }
            translate ([-6.5,-6.5,-1])cube([5,5,3.2], false);
            translate ([9,-6.5,-1])cube([30,5,3.2], false);
            translate ([49.5,-6.5,-1])cube([5,5,3.2], false);
            
            translate ([-6.5,1.5,-1])cube([5,5,3.2], false);
            translate ([9,1.5,-1])cube([30,5,3.2], false);
            translate ([49.5,1.5,-1])cube([5,5,3.2], false);
            }
        }
    } else {
    translate([-9.5,0,0]) cube([35,6,1.5], false);
    }
}

// main: Assembles the full curved rail segment with endpoints and crossbars
//   CurveRad: radius of curve (in LEGO units)
//   CurveSegAng: angle of curve segment (degrees)
//   barreau: crossbar module
module main(CurveRad,CurveSegAng,barreau){
    translate([-CurveRad*8,0,0])intersection()
    {
        union()
        {
            difference()
            {
                translate([0,0,3.2])CurvedRail(CurveRad*8,CurveSegAng);
                rotate([0,0,0])translate([CurveRad*8-0.25-40,0,0])cube([80,4,20]); 
                rotate([0,0,CurveSegAng])translate([CurveRad*8-0.25+40,0,0])rotate([0,0,180])cube([80,4,20]);

            }
            // Add the end pads
            difference()
            {
            rotate([0,0,0])translate([CurveRad*8-0.25-24,4,0])full_endpoint();
                        if (!full)
            translate([CurveRad*8-0.25,11,0])linear_extrude(2)text(str("R",CurveRad," L",CurveSegAng),size = 4, font="Helvetica:style=Bold", halign = "center", valign = "center");
            }
            rotate([0,0,CurveSegAng])translate([CurveRad*8-0.25+24.5,-4,0])rotate([0,0,180])full_endpoint();
            echo((CurveSegAng*2*3.14 * CurveRad*8+64)/360);// arc length
            {
                temp = round(CurveRad*8*CurveSegAng/diverse);
                
                b = CurveSegAng/temp;
                if (temp > 1)
                for (i = [1:temp-1]){
                    rotate([0,0,(i*b)])translate([CurveRad*8-0.25-7.75,0,0])barreau();
                }
        } 
        }
    }
}

// Entry point: generates the curved rail with selected parameters
translate([0,0,0]) rotate([0,0,0]) 
main(Radius,SegAng);
