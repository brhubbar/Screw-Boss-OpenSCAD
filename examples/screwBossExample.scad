// This is meant to illustrate use of `screwBoss.scad`. The screwBoss
// library is most easily called using variables laying out the dimensions
// of the screw of interest.
//
// Inputs
// ------
//  headHeight -- height of the screw head (mm)
//  headDiam -- outer diameter of the head (mm)
//  screwLength -- length of the screw, excluding the head (mm)
//  screwDiam -- outer diameter of the threads (mm)
//  filletRadius -- radius of edge blending (mm)
//  nutHeight -- (optional) thickness of the nut (mm)
//  nutFlats -- (optional) distance from flat-to-flat on the nut (mm)
//  isFloating -- (default=false) adds a 45 degree chamfer to the boss for
//    printability (true | false)


// Include modules from the library.
use <../src/screwBoss.scad>;


// Set the resolution pretty low for design. Increase for final render.
$fn = 20;

// Set dimensions for the screw. These are for an M3x20mm cap screw.
headHeight = 3;
headDiam = 5.4;
screwLength = 10;
screwDiam = 3;
nutHeight = 2.4;
nutFlats = 5.5;
filletRadius = 2;

bossW = 10;

translate([0, 3*bossW, 0]) linear_extrude(1)
  text("Normal", size=15, font="Liberation Sans", halign="Left");
exampleSet(false);

translate([0, 10*bossW, 0]) linear_extrude(1)
  text("Floating", size=15, font="Liberation Sans", halign="Left");
translate([0, bossW*7, 0])
exampleSet(true);


module exampleSet(isFloating=false) { // Contains the rest of the file.
// EXAMPLE 1: PLace a boss
// Place a boss. Use named parameters for readability.
boss(W=bossW, L=screwLength, R=filletRadius, isFloating=isFloating);

// Label it.
linear_extrude(1)
text("1", size=10, font="Liberation Sans", halign="left", valign="top");


// EXAMPLE 2: PLace a boss with an interference hole cut out.
// Subtract a clearance hole from the boss. The result can be relocated.
translate([2*bossW, 0, 0])
  difference() {
    boss(W=bossW, L=screwLength, R=filletRadius, isFloating=isFloating);
    interferenceNegative(D=screwDiam, L=screwLength, W=bossW, isFloating=isFloating);
  }

// Draw just the negative for illustration.
translate([2*bossW, 2*bossW, 0])
  union() {
    interferenceNegative(D=screwDiam, L=screwLength, W=bossW, isFloating=isFloating);
  }

// Label it.
translate([2*bossW, 0, 0]) linear_extrude(1)
  text("2", size=10, font="Liberation Sans", halign="left", valign="top");


// EXAMPLE 3: Place a boss with a clearance hole and a screw head recess.
// Note that an interference hole and screw head recess would not be used
// together because the screw wouldn't hold anything in place. It would
// be like placing a nut on a bolt with nothing between the bolt head and
// the nut. Note also that the screw head comes with some additional geometry
// to give the otherwise floating circle for the clearance hole something to
// print on.
translate([4*bossW, 0, 0])
  difference() {
    boss(W=bossW, L=screwLength, R=filletRadius, isFloating=isFloating);
    clearanceNegative(D=screwDiam, L=screwLength, W=bossW, isFloating=isFloating);
    screwHeadNegative(D=headDiam, H=headHeight, d=screwDiam, W=bossW, isFloating=isFloating, L=screwLength);
  }

// Draw just the negative for illustration.
translate([4*bossW, 2*bossW, 0])
  union() {
    clearanceNegative(D=screwDiam, L=screwLength, W=bossW, isFloating=isFloating);
    screwHeadNegative(D=headDiam, H=headHeight, d=screwDiam, W=bossW, isFloating=isFloating, L=screwLength);
  }

// Label it.
translate([4*bossW, 0, 0]) linear_extrude(1)
  text("3", size=10, font="Liberation Sans", halign="left", valign="top");


// EXAMPLE 4: Place a boss with a clearance hole and a nut trap. The nut trap
// can be rotated to be accessible from any side of the boss. Note also that
// it is automatically located halfway up the boss.
translate([6*bossW, 0, 0])
  difference() {
    boss(W=bossW, L=screwLength, R=filletRadius, isFloating=isFloating);
    clearanceNegative(D=screwDiam, L=screwLength, W=bossW, isFloating=isFloating);
    nutTrapNegative(F=nutFlats, H=nutHeight, L=screwLength, W=bossW, d=screwDiam, a=45, isFloating=isFloating);
  }

// Draw just the negative for illustration.
translate([6*bossW, 2*bossW, 0])
  union() {
    clearanceNegative(D=screwDiam, L=screwLength, W=bossW, isFloating=isFloating);
    nutTrapNegative(F=nutFlats, H=nutHeight, L=screwLength, W=bossW, d=screwDiam, a=45, isFloating=isFloating);
  }

// Label it.
translate([6*bossW, 0, 0]) linear_extrude(1)
  text("4", size=10, font="Liberation Sans", halign="left", valign="top");

// Some labelling text.
linear_extrude(1)
text("Complete bosses", size=10, font="Liberation Sans", halign="right");

translate([0, 2*bossW, 0]) linear_extrude(1)
  text("Negatives", size=10, font="Liberation Sans", halign="right");

} // end of exampleSet.
