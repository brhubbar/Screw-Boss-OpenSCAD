// Illustrates the minkowski summation and its uses.
//
// According to the [documentation]
// (https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations#minkowski),
// the summation of a cylinder and a rectangle will sum their dimensions in all
// three axes (e.g. a 10x10x2 prism summed with an OD2 x 1 cylinder results in
// a 14x14x3 prism with fillets in the plane of the cylinder.)
//
// The basic premise:
//  - Draw the two components and their minkowski sum.
//  - Show the effect of translating the objects on the location of the sum.
//
// The Minkowski Sum explained:
//  According to [Wikipedia](https://en.wikipedia.org/wiki/Minkowski_addition),
//  the minkowski sum is set addition in which each vector inside a set is
//  added to each vector in another set.
//
//  How does this relate to OpenSCAD? Think of each body as a 'set' of points.
//  The minkowski sum takes each point in one shape, and adds it to each point
//  in the other.
//
//  One might imagine the minkoski sum in this way:
//    For our example, the two parts are a rectangular prism and a cylinder.
//    Take the cylinder at its origin. Place the cylinder on one corner of their
//    prism. Now treat the faces of the prism as your limits, then sweep the
//    cylinder around, keeping its origin inside the limits. Any point in space
//    occupied by the cylinder while you sweep around, bumping into the edges
//    of the cylinder, is kept in the final minkowski sum.
//
//    Now if the cylinder is translated so that it doesn't touch the origin,
//    its origin is still what must remain within the bounds of the prism,
//    causing the resulting 'painted' solid to be offset from the origin as
//    well.
//
//  This should also make it clear why the minkowski slows things down so much -
//  Drawing the sum requires a computation of every point on one shape for every
//  point on the other shape, so two 10-point shapes demand 100 calculations.

// Lower the resolution to save time on calculations
$fn = 50;

// Set the [X, Y, Z] dimensions of the rectangular prism.
prismDim = [10, 10, 3];
// Set the [X, Y, Z] location of the corner of the prism.
prismTranslate = [10, 0, 0];

// Set the radius of the cylinder.
cylR = 3;
// Set the height of the cylinder.
cylH = 1;
// Set the location of the center of the bottom of the cylinder.
cylTranslate = [0, 0, 0];

// Show the prism in space. This acts as the limits of where the origin of the
// cylinder can reach when sweeping the cylinder around.
prism();
// Show the cylinder. This is the 'paint brush'.
// cyl();
halfSph();

// Show the bounds of the expected rectangle, without fillets.
// The `#` will show this part in transluscent red.
// # expectedDims();

// Draw the minkowski sum. The `%` will show the part in transluscent grey.
% minkowski(){
  prism();
  //cyl();

  // So if you did a sphere instead here, you'd get rounded corners all around.
  // The minkowski would trace the sphere from its center around the span of
  // the prism or cylinder, whichever you leave uncommented.
  //sph();

  // And half sphere leaves the bottom with square edges.
  //halfSph();
}

module prism() {
  // Make an orange cube.
  color([1, 0.5, 0]) translate(prismTranslate) cube(prismDim);
}

module cyl() {
  // Make a blue cylinder.
  color([0, 0.5, 1]) translate(cylTranslate) cylinder(r=cylR, h=cylH);
}

module sph() {
  sphere(r=cylR);
}

module halfSph() {
  difference(){
      sph();
      translate([-cylR,-cylR,-cylR*2])cube(cylR*2);
  }
}

module expectedDims() {
  // This is going to be a conglomeraton of the above dimensions.
  // The X and Y become a sum of their lengths plus the diameter of the
  // cylinder.
  X = prismDim[0] + cylR*2;
  Y = prismDim[1] + cylR*2;
  Z = prismDim[2] + cylH;

  // The origin is a sum of the origins of the two parts.
  // Offset in the XY plane to account for the radius of the cylinder.
  trans = prismTranslate + cylTranslate - [cylR, cylR, 0];

  color([0, 1, 0]) translate(trans) cube([X, Y, Z]);
}
