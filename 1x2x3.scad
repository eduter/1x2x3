
use <pins.scad>

INF = 200;   // represents infinity - just needs to be bigger than anything else in the model
ZERO = 0.01; // number very close to zero, just to prevent 2 edges from being colinear

// settings
  clearance = 0.4;
  // edge pin settings
    bodyRadius = 4;
    headRadius = 7;
    bodyHeight = 3;
    headHeight = 2;

// aliases
cl = clearance;
br = bodyRadius;
hr = headRadius;
bh = bodyHeight;
hh = headHeight;


  // Pin Settings
    pin_h = 10;        // Pin, height
    pin_r = 4;         // Pin, radius
    pin_lh = 3;        // Pin, lip height
    pin_lt = 1;        // Pin, lip thickness
    pin_t = cl;       // Pin, lip tolerance
    pin_tight = false; // Pin, tight


module center_pin() {
  render() for (i=[0,1]) mirror([0,i,0])
    translate([0,-(pin_h+cl/2)/2,pin_lt/2-pin_r]) 
      pin(h=pin_h+cl/2, r=pin_r, lh=pin_lh, lt=pin_lt, t=pin_t, side=true);
}

module slice(centerWidth = 20, tilt1 = 0, tilt2 = 0) {
  edgePiece(centerWidth,+1,+1,tilt1) children();
  edgePiece(centerWidth,+1,-1,tilt1) children();
  centerPiece(centerWidth, +1) children();
  center_pin();
  centerPiece(centerWidth, -1) children();
  edgePiece(centerWidth,-1,+1,tilt2) children();
  edgePiece(centerWidth,-1,-1,tilt2) children();
}

module centerPiece(centerWidth, ySignal) {
  translate([0,ySignal*0.5*cl,0]) difference() {
    intersection() {
      render() children();
      translate([0,ySignal*INF/2,0]) cube([centerWidth, INF, INF], center=true);
    }
    quadrant(+1, ySignal) edgePinHole(centerWidth, cl, br, hr, bh, hh);
    quadrant(-1, ySignal) edgePinHole(centerWidth, cl, br, hr, bh, hh);

    //  Pin hole
    rotate([90,0,0]) pinhole(h=pin_h, r=pin_r, lh=pin_lh, lt=pin_lt, t=pin_t, tight=pin_tight);


  }
}

module edgePiece(centerWidth, xSignal, ySignal, tilt) {
  xs = xSignal;
  ys = ySignal;
  translate([xs*cl, ys*0.5*cl,0]) {
    intersection() {
      rotate([tilt, 0, 0]) children();
      quadrant(xs, ys) translate([(INF+centerWidth)/2, INF/2, 0]) cube(INF, center=true);
    }
    quadrant(xs, ys) translate([centerWidth/2,0,0]) edgePin(br,hr,bh,hh);
  }
}

module edgePinHole(centerWidth, clearance, bodyRadius, headRadius, bodyHeight, headHeight) {
  cl = clearance;
  br = bodyRadius;
  hr = headRadius;
  bh = bodyHeight;
  hh = headHeight;
  translate([centerWidth/2+ZERO, -ZERO, 0]) edgePin(br+cl, hr+cl, bh-2*cl, hh+2*cl);
}

module edgePin(bodyRadius, headRadius, bodyHeight, headHeight) {
  hd = 2 * headRadius;          // head diameter
  th = bodyHeight + headHeight; // total height
  render() rotate([90,0,90]) translate([0,0,-th]) intersection() {
    union() {
      cylinder(r=bodyRadius, h=th);
      cylinder(r=headRadius, h=headHeight);
    }
    translate([0,-headRadius,0]) cube([hd, hd, th]);
  }
}

module quadrant(xSignal, ySignal) {
  mirror([xSignal - 1, 0, 0]) mirror([0, ySignal - 1, 0]) children();
}

slice(tilt1=30, tilt2=10)
//  translate([3,3,0]) cube([60,40,20], center=true);
  rotate(15,[0,1,0]) translate([0,5,0]) cylinder(r=30,h=20,center=true);
