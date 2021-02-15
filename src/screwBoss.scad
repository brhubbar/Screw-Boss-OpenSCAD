// Implements a variety of methods to fixture with screws.
//
// Generates the following features:
//  - Clearance hole, where the screw can slide.
//  - Interference hole, where the screw threads into the body.
//  - Recess for the screw head (always positioned on the bottom of the boss).
//  - Nut trap where a nut can be inserted to get a secure hold on a part.
//  - Boss for the screw, usually filling a void in a part.
//    - Tolerance hole with a (removable) captive nut.
//    - Interference hole for the screw to thread into.
//
// The above features are implemented individually as `low-level` features.
// They are all located in such a manner to allow placement of any
// combination of those features. They are not implemented in combination
// because there are few use cases for a pre-cutout feature in OpenSCAD,
// as the cutout will usually have to cut through another feature in the
// main part.
//
// Bosses are constructed in the 1st octant (+X+Y+Z) if isFloating=false, and
// the 5th octant (+X+Y-Z) if isFloating=true. Cutouts are located to allow
// them to be immediately removed from a pre-constructed boss (every module
// accepts inputs for the size of the boss that the negative is for).
//
// Features that could result in floating surfaces (such as a reduction in
// diameter from that of a screw head to just the threads) are generated with
// optimized bridging to remove the need for support material while printing.
//
// There are clearance parameters defined at the top of this file. Those
// may vary by 3D printer, so feel free to fudge them to meet your needs.
//
// There are a lot of repeated inputs required due to the limitations of
// OpenSCAD to remember information, so just bear with it as you have to
// provide the same parameters to each function call.
//
// Modules
// -------
//  boss(L, W, R, isFloating) -- returns a WxWxL boss with radius R on
//    vertical edges. isFloating=true adds a 45deg slant to the bottom,
//    extending beyond the specified height, L.
//  clearanceNegative(D, L, W, isFloating) -- returns a negative to cut a
//    clearance hole. Uses `clearance` defined at the top of the file.
//  interferenceNegative(D, L, W, isFloating) -- returns a negative to cut an
//    interference hole. Uses `interference` defined at the top of the file.
//  screwHeadNegative(D, H, d, W, layerHeight, isFloating) -- returns a
//    negative to cut a screw head recess. Optimizes briding inside so this
//    recess can be below the smaller hole (d) on a print bed.
//  nutTrapNegative(F, H, L, W, d, layerHeight, a, isFloating) -- returns a
//    negative for a nut trap to cut out of the boss.
//
// Revisions
// ---------
//     v0.0.1:
//
// Copyright (C) 2021  brhubbar
//
// https://github.com/brhubbar/Screw-Boss-OpenSCAD.git
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// brhubbar / v0.0.1


// Tolerances for interference and clearance fits. Adjust as necessary
// to meet your printer's needs. Positive values add to the diameter,
// negative values subtract from the diameter. All in mm.
clearance = 0.4;
interference = 0;


module boss(L, W, R=0, isFloating=false) {
  // Generate a filleted prism with square WxW cross section and L height.
  //
  // This does not have the negative (hole) cut out. If the boss isFloating,
  // the base is extended at a 45 degree slant. The slant can be placed
  // against a wall to improve print quality. The boss is also translated
  // so that it may be located by its top surface, rather than its base (as
  // in the case of a non-floating boss).
  //
  // Inputs
  // ------
  //  L -- height of the prism in the z-axis (mm)
  //  W -- cross-sectional width of the prism (mm)
  //  R -- (default=0) radius of edge blend on vertical edges (mm)
  //  isFloating -- (default=false) boolean to optimize the boss for floating.
  //    this includes adding a slant to the bottom, and setting the origin
  //    at the top corner, rather than the bottom corner.

  // If the boss is floating, double the height of the boss and translate it
  // downward half its height.
  L = isFloating ? L*2 : L;
  transDown = isFloating ? -L : 0;

  translate([0, 0, transDown]) // Translates the result of difference()
  // Difference in the case that it's floating. If it's not floating, there
  // won't be a second body generated, thus no subtraction.
  difference() {
  // Conditional depending on if the boss will be radiused.
  if (R > 0) {
    // Correct dimensions for the effects of the minkowski sum. See
    // `Minkowski Sandbox.scad` for more info.
    // The height of the cylinder is arbitrary, as long as it's corrected
    // for. It also cannot so large that the corrected dimensions become
    // negative.
    cylH = 0.1;
    W = W - 2*R;
    L = L - cylH;

    // Create a prism with rounded sides. Use a cylinder to round only the
    // vertical edges.
    minkowski() {
      // Create the prism to act as the base for the sum.
      // Include an extra slant if the boss is floating.
      cube([W, W, L]);
      // Shift the center of the cylinder to place three faces of the
      // resulting body on the three planes of the origin. Removing the
      // `translate` command would shift the boss so its origin sat at the
      // center of one of the edge radii, making placement more difficult.
      translate([R, R, 0]) cylinder(r=R, h=cylH);
    }
  } else {
    // If the fillet radius is 0, the minkowski sum won't work (the
    // cylinder is an empty body), so the dimensions should not be
    // corrected.
    cube([W, W, L]);
  }

  // This is the second body for subtraction. Only generated if its needed
  // (to save computation time for non-floating objects).
  if (isFloating == true) {
    // Create a triangular prism on the base of the boss.
    polyhedron(points = [ [0, 0, 0],  // 0
                          [W, 0, 0],  // 1
                          [W, W, 0],  // 2
                          [0, W, 0],  // 3
                          [0, W, W],  // 4
                          [W, W, W]   // 5
                          ],
              faces = [ [0, 1, 2, 3], // Bottom
                        [2, 5, 4, 3], // Vertical square
                        [0, 3, 4],    // triangle on YZ plane
                        [1, 5, 2],    // opposite triangle
                        [0, 4, 5, 1]  // slanted surface
                        ]);
  } // End of second body conditional construction
  } // End of difference.
}


module clearanceNegative(D, L, W=0, isFloating=false) {
  // Generates the 'negative' of a clearance hole cutout.
  //
  // If W is provided, the negative is properly located to cut directly
  // out of a boss() generated with the same parameters. This allows for
  // fast, sensible location of features intended to build the same boss.
  // Otherwise, will locate coaxial with the z-axis with the bottom
  // resting on the xy plane.
  //
  // Inputs
  // ------
  //  D -- nominal diameter of the screw threads (mm
  //  L -- cutout height/depth (mm)
  //  W -- (default=0) boss cross sectional width to locate the negative
  //    in space (mm)
  //  isFloating -- (default=false) boolean to optimize the boss for floating.
  //    this includes adding a slant to the bottom, and setting the origin
  //    at the top corner, rather than the bottom corner.

  // Adjust dimensions to accommodate a boss that has been built floating.
  L = isFloating ? L*2 : L;
  transZ = isFloating ? -L/2 : L/2;

  // Move the cylinder to be centered in the boss to cut out perfectly
  // within the limits of the boss. Correct the diameter to provide a
  // clearance fit.
  translate([W/2, W/2, transZ])
    cylinder(d=D+clearance, h=L, center=true);
}


module interferenceNegative(D, L, W=0, isFloating=false) {
  // Generates the 'negative' of an interference hole cutout.
  //
  // If W is provided, the negative is properly located to cut directly
  // out of a boss() generated with the same parameters. This allows for
  // fast, sensible location of features intended to build the same boss.
  // Otherwise, will locate coaxial with the z-axis with the bottom
  // resting on the xy plane.
  //
  // Inputs
  // ------
  //  D -- nominal diameter of the screw threads (mm)
  //  L -- cutout height/depth (mm)
  //  W -- (default=0) boss cross sectional width to locate the negative
  //    in space (mm)
  //  isFloating -- (default=false) boolean to optimize the boss for floating.
  //    this includes adding a slant to the bottom, and setting the origin
  //    at the top corner, rather than the bottom corner.

  // Adjust dimensions to accommodate a boss that has been built floating.
  L = isFloating ? L*2 : L;
  transZ = isFloating ? -L/2 : L/2;

  // Move the cylinder to be centered in the boss to cut out perfectly
  // within the limits of the boss. Correct the diameter to create an
  // interference fit.
  translate([W/2, W/2, transZ])
    cylinder(d=D+interference, h=L, center=true);
}


module screwHeadNegative(D, H, d=0, W=0, layerHeight=0.2, isFloating=false, L=0) {
  // Generates the negative to recess a screw head into a part.
  //
  // Sets a stepped square hole at the inside of the recess to accomodate
  // recesses that are placed on the bed plate. This works because a 3D
  // printer will bridge across the hole to print those square edges,
  // rather than trying to print a circle in the middle of open air.
  // This action assumes a clearance hole is used because an interference
  // hole with a screw head recess doesn't make practical sense. The bolt
  // should pass through whatever it's recessed in, then thread into the
  // next body.
  //
  // Note that this will overlap with an interferenceNegative or
  // clearanceNegative, so L for those must account for H.
  //
  // Applies clearance to H and D to ensure the head is fully recessed.
  //
  // Inputs
  // ------
  //  D -- nominal diameter of the screw head (mm)
  //  H -- height of the screw head (mm)
  //  d -- (default=0) diameter of the hole being counter-bored (mm). Used
  //    to generate optimized bridging.
  //  W -- (default=0) boss cross sectional width to locate the negative
  //    in space (mm)
  //  layerHeight -- (default=0.2) layer height for optimized bridging.
  //  isFloating -- (default=false) boolean to optimize the boss for floating.
  //    this includes adding a slant to the bottom, and setting the origin
  //    at the top corner, rather than the bottom corner.
  //  L -- (default=0) Boss height. Only required when isFloating=true

  // Adjust dimensions to include clearance.
  D = D + clearance;
  H = H + clearance;
  d = d + clearance;

  // Adjust dimensions to accommodate a floating boss. The screw head in this
  // case is still set into the bottom of the boss, since recessing the top
  // would leave the screw sticking out of a 45 degree slant - not conducive
  // to fastening to a second surface.
  H = isFloating? L : H;
  transZ = isFloating ? -(L+H) : 0;

  translate([0, 0, transZ]) // Will move the output of the union() block.
  // Generate the negative.
  union() {
    // Main recess. This is for the actual screw head.
    translate([W/2, W/2, H/2])
      cylinder(d=D, h=H, center=true);
    // Generate optimized bridging. This is set on top of the recess to
    // allow the reduced hole to print cleanly.
    translate([W/2, W/2, H])
      union() {
        // Create the first layer of bridging, extending to and matching the
        // edges of the head recess.
        intersection() {
          // Round out the edges of the bridging to avoid weird holes in the part.
          // The lower piece must extend to the edges of the circle.
          translate([0, 0, layerHeight/2])
            cube([D, d, layerHeight], center=true);
          // Create a cylinder to round them out.
          cylinder(d=D, h=layerHeight*3, center=true);
        }
        // Create the second layer of bridging, a square circumscribing the
        // smaller hole.
        translate([0, 0, 3*layerHeight/2])
          cube([d, d, layerHeight], center=true);
      }
  }
}

module nutTrapNegative(F, H, L, W, d=0, layerHeight=0.2, a=0, isFloating=false) {
  // Creates a nut-trap negative to cut out of the corner of a boss.
  //
  // Places the trap halfway up the boss, made for a clearance fit. The trap
  // is sized to cut out through the corner of an un-radiused, square boss.
  // The nut is assumed to be located at the center of the boss. If L (the
  // height of the boss) is not provided, the negative is cenetered at the
  // origin.
  //
  // Inputs
  // ------
  //  F -- size of the nut from flat-to-flat on the hexagon (mm)
  //  H -- height of the nut (mm)
  //  L -- height of the boss to locate the negative halfway up (mm)
  //  W -- boss cross sectional width to size the slot to the nut (mm)
  //  d -- (default=0) diameter of the hole being counter-bored (mm). Used
  //    to generate optimized bridging.
  //  layerHeight -- (default=0.2) layer height for optimized bridging.
  //  a -- (default=0) angle of CCW rotation of the nut trap about the
  //    z-axis (deg)
  //  isFloating -- (default=false) boolean to optimize the boss for floating.
  //    this includes adding a slant to the bottom, and setting the origin
  //    at the top corner, rather than the bottom corner.

  // Adjust dimensions for a clearance fit.
  F = F + clearance;
  H = H + clearance;
  d = d + clearance;

  // Adjust translation if the boss is floating.
  transZ = isFloating ? (-L/2 - H/2) : (L/2 - H/2);

  // cylinder() is used to generate the nut. It uses the diameter of the
  // circumscribing circle. F is the inscribed diameter, so convert
  // geometry and regular polygons.
  N_sides = 6;
  D = F/(cos(180/N_sides));

  // Size the trap to make it out of the side corner of a boss.
  Slot_W = W/2 * sqrt(2);

  translate([W/2, W/2, transZ]) rotate([0, 0, a]){
    // Generate the blank.
    union(){
      // Blank for the nut.
      cylinder(d=D, h=H, $fn=N_sides);
      // Slot to insert the nut.
      translate([0, -F/2, 0]) cube([Slot_W, F, H]);

      // Generate optimized bridging. This is set on top of the recess to
      // allow the reduced hole to print cleanly.
      translate([0, 0, H])
        union() {
          // Create the first layer of bridging, extending to and matching the
          // edges of the trap slot.
          translate([0, 0, layerHeight/2])
            cube([d, F, layerHeight], center=true);
          // Create the second layer of bridging, a square circumscribing the
          // smaller hole.
          translate([0, 0, 3*layerHeight/2])
            cube([d, d, layerHeight], center=true);
        }
    }
  }
}
