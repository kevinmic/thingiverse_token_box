$fn=50;
smallTokenDiameter=19.5;
largeTokenDiameter=25.5;

tokensBetweenSpacers=5;
tokenDiameter=smallTokenDiameter;
numberOfTokensPerBox=20;
numberOfBoxes=3;
gap=0.3;
spacerGap=0.95;
tokenWidth=2.3;


wallThickness=2;
roundEdgesDiameter=1;

numberOfTokenSpacers=floor((numberOfTokensPerBox-1)/tokensBetweenSpacers);
cylinderLength=tokenWidth * numberOfTokensPerBox + // tokens
       tokenWidth * numberOfTokenSpacers; // token spacers
boxLength = cylinderLength + wallThickness * 2; // end walls
boxWidth=tokenDiameter * numberOfBoxes +
      wallThickness * 2 + // left and right side
      wallThickness * (numberOfBoxes-1); // between cylinders
height=tokenDiameter/2 + wallThickness * 2;  // Extra thick on bottom to deal with spacers
boxLipThickness=wallThickness + roundEdgesDiameter/2; // This would normally be wallThickness but the minkowski applies a half a roundEdgesDiameter to the outside of everything.


echo("numberOfTokenSpacers:", numberOfTokenSpacers);
echo("cylinderLength:", cylinderLength);
echo("boxLength:", boxLength);
echo("boxWidth:", boxWidth);
echo("height:", height);

**bottomContainer();
translate([boxLength+5,0,0]) topContainer();
**translate([-(boxLength*.6+tokenDiameter/2),0,-height-roundEdgesDiameter]) tokenSpacer();

module tokenSpacer() {
    width=tokenWidth*spacerGap;
    diameter=tokenDiameter-gap;
    removeTop=1;
    translate([0,0,width/2]) {
        difference() {
            union() {
                cylinder(d=diameter, h=width, center=true);
                translate([0,diameter/2,0]) rotate([90,90,0]) 
                    notch(diameter, width);
            }
            // Cut off half the circle + remove top so we can place a rounded top
            translate([0,-diameter/2+removeTop,0])
                cube([diameter+1, diameter, width+2], center=true);
        }
        // Curve the top edge
        intersection() {
           translate([0,removeTop,0]) rotate([0,90,0]) cylinder(d=width, h=diameter, center=true);
            cylinder(d=diameter, h=width, center=true);
        }
    }
}

module topContainer() {
    difference() {
        boxWithCylinderRemoved(boxLength, boxWidth, height, notches=false, extraHeight=boxLipThickness+gap);
        translate([0,0,0]) {
            rotate([180,0,0]) {
                difference() {
                    bottomCube(boxLength-boxLipThickness+gap, boxWidth-boxLipThickness+gap, 5);
                }
            }
        }
    }
    // TODO: Remove magic 0.5 and .1
    translate([0,0,boxLipThickness-.1])
        // TODO: Remove magic 0.5 and .4
        cylinderRing(boxLength+gap-0.5, boxWidth+gap-0.5, .4, false);        
    
}

module bottomContainer() {
    difference() {
        boxWithCylinderRemoved(boxLength, boxWidth, height, notches=true);
        
        // Create a lip on the top
        translate([0,0,-3]) {
            rotate([180,0,0]) {
                difference() {
                    bottomCube(boxLength+5, boxWidth+5, 5);
                    translate([0,0,2])
                        bottomCube(boxLength-boxLipThickness, boxWidth-boxLipThickness, 20);   
                }
            }
        }
        // TODO: Remove magic 2.5
        translate([0,0,-2.5])
            cylinderRing(boxLength-wallThickness/2, boxWidth-wallThickness/2, .5, corners=true);        
    }
}

module boxWithCylinderRemoved(length, width, height, notches=false, extraHeight=0) {
    difference() {
            // create the bottom cube
        bottomCube(length, width, height, extraHeight);

        // Remove the token space
        translate([0,-tokenDiameter/2*(numberOfBoxes)-(numberOfBoxes-1)*wallThickness/2,0]) {
            for (i=[0:1:numberOfBoxes-1]) {
                translate([0,(tokenDiameter/2 + tokenDiameter*i + wallThickness*i),0])
                    cylinderWithNotches(diameter=tokenDiameter, length=cylinderLength, notches=notches);
            }
        }
    }
}



module bottomCube(length, width, height, extraHeight=0) {
    difference() {
        minkowski() {
            cube([length, width, height*2], center=true);
            sphere(roundEdgesDiameter);
        }        
        
        // cut the other cube in half
        translate([0, 0, height+extraHeight])
            cube([length*2, width*2, height*2], center=true);
    }
    
}


module cylinderWithNotches(diameter, length, notches) {
    translate([-length/2,0,0]) { 
        rotate([0,90,0])
            cylinder(d=diameter,h=length);

        if (notches) {
            for (i=[1:1:numberOfTokenSpacers]) {
                translate([i * (tokensBetweenSpacers+1) * tokenWidth - tokenWidth/2, 0, -diameter/2])
                    notch(diameter, tokenWidth);
            }
        }
    }
}

module notch(diameter, width) {
    cube([width,diameter/3,wallThickness*2], center=true);
}

module cylinderRing(length, width, diameter, corners=false) {
    scale([1,1,2]) {
        union() {
            translate([0,width/2,0]) rotate([0,90,0]) cylinder(d=diameter, h=length, center=true);
            translate([0,-width/2,0]) rotate([0,90,0]) cylinder(d=diameter, h=length, center=true);
            translate([length/2,0,0]) rotate([90,90,0]) cylinder(d=diameter, h=width, center=true);
            translate([-length/2,0,0]) rotate([90,90,0]) cylinder(d=diameter, h=width, center=true);

            if (corners) {
                translate([length/2-0.3,width/2-0.3,0]) rotate([45,90,0]) cylinder(d=diameter, h=5, center=true);
                translate([length/2-0.3,-(width/2-0.3),0]) rotate([-45,90,0]) cylinder(d=diameter, h=5, center=true);
                translate([-(length/2-0.3),width/2-0.3,0]) rotate([-45,90,0]) cylinder(d=diameter, h=5, center=true);
                translate([-(length/2-0.3),-(width/2-0.3),0]) rotate([45,90,0]) cylinder(d=diameter, h=5, center=true);
            }
        }
    }

}
