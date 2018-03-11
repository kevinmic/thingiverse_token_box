$fn = 50;

includeText = false;
Text = "1";
Font = "Euphemia UCAS:style=bold";
TextHeight = 7;
TextDistance = 2;

includeMagnet = true;
magnetDiameter = 3.35;
magnetPosition = [2,2,1.7];

stackShape="heart";

difference() {
    union() {
        mainShape();
        topShape();
    }
    bottomShape();
    textCutout();
    magnetCutout();
}
    
module mainShape() {
    minkowski() {
        heart(10, 0.1, 1);
        translate([1,1,0])
        sphere(1);
    }
}

module topShape() {
    if (stackShape == "heart") {
        translate([1.0,1.0,1.3])
        difference() {
            heart(9.3, 1, 1.0);
            heart(7.9, 4, 1.8);
        }
    }
    else if (stackShape == "circle") {
        translate([2,2,1.3]) {
            difference() {
                  cylinder(h=1, d=11.1, center=true);
                  cylinder(h=4, d=10.1, center=true);
            }
        }
    }
}

module bottomShape() {
    if (stackShape == "heart") {
        translate([1,1,-1]) {
            difference() {
                heart(10, 2, 0.8);
                heart(7.4, 3, 2);
            }
        }
    }
    else if (stackShape == "circle") {
        translate([2,2,-1]) {
            difference() {
                cylinder(h=2, d=12.1, center=true);
                cylinder(h=3, d=9.4, center=true);
            }
        }
    }
}

module textCutout() {
    if (includeText) {
        translate([TextDistance,TextDistance,-2])
            rotate([0,0,-45])
                printText(d=4, scale=.6);
    }
}

module magnetCutout() {
    if (includeMagnet) {
        translate(magnetPosition) {
            cylinder(d=magnetDiameter, h=3, center=true);
        }
    }
}

module heart(d, h, e) {
    translate([d/2+e,0,0])
        cylinder(d=d, h=h, center=true);
    translate([0,d/2+e,0])
        cylinder(d=d, h=h, center=true);
    cube([d,d,h], center=true);
    translate([e,0,0])    
        cube([d,d,h], center=true);
    translate([0,e,0])
        cube([d,d,h], center=true);
}

module printText(d, scale) {
    linear_extrude(d)
        text(text = Text, font = Font, size=TextHeight, halign="center", valign="center");
}
