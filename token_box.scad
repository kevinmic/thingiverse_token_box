// smalltoken_diameter=19.5;
// largetoken_diameter=25.5;

/* [Global] */
part = "all"; // [all:Bottom/Top/Spacer, bottom:Bottom of Box, top:Top of Box, spacer:Token Spacer

/* [Box Settings] */
// Shape of the token
token_shape = "circle"; // [circle:Circle Tokens, square:Square Tokens, hexagon:6 Sided Token, octagon:Stop Sign Token]
// How many token groups
number_of_token_groups=3; 
// How many tokens per group
number_of_tokens_per_group=20; 
// How many tokens between spacers
number_of_tokens_between_spacers=5; 

/* [Token Settings] */
// Token Diameter
token_diameter=19.5; 
// Token Width
token_width=2.3; 

/* [Other] */
// Gap between top and bottom
lid_gap=0.5; 


/* [Hidden] */
$fn=50;
spacerGap=0.95; // Spacer Gap percentage
wallThickness=2; // Changing this will likly cause problems.
roundEdgesDiameter=2;  // Changing this will likly cause problems.
boxLipDepth=3;  // Changing this might cause problems.

// How many token spacers need to be printer per group
numberOfTokenSpacers=floor((number_of_tokens_per_group-1)/number_of_tokens_between_spacers);
// Total Cylinder Length
cylinderLength=token_width * number_of_tokens_per_group + // tokens
       token_width * numberOfTokenSpacers; // token spacers
// Total Box Length
boxLength =cylinderLength + wallThickness * 2 - roundEdgesDiameter; // end walls
// Total Box Width
boxWidth=token_diameter * number_of_token_groups +
      wallThickness * 2 + // left and right side
      wallThickness * (number_of_token_groups-1) // between cylinders
      - roundEdgesDiameter; 
height=roundEdgesDiameter/2 + token_diameter/2 - roundEdgesDiameter;  
boxLipThickness=wallThickness + roundEdgesDiameter/2; // This would normally be wallThickness but the minkowski applies a half a roundEdgesDiameter to the outside of everything.


echo("numberOfTokenSpacers:", numberOfTokenSpacers);
echo("cylinderLength:", cylinderLength);
echo("boxLength:", boxLength);
echo("boxWidth:", boxWidth);
echo("height:", height);
echo("boxLipThickness:", boxLipThickness);

print_part();

module print_part() {
    if (part == "all") {
            bottomContainer();
            translate([boxLength-roundEdgesDiameter+10,0,-roundEdgesDiameter]) {
                difference() {
                    topContainer();
                    //translate([0,0,-height-1.5]) rotate([0,180,90]) scale([0.5,0.5,2]) import("descent.stl");
                }
            }

            translate([-(boxLength*.6+token_diameter/2),0,-height-roundEdgesDiameter*2]) tokenSpacer();
    }
    if (part == "bottom") {
        bottomContainer();
    }
    if (part == "top") {
        difference() {
            topContainer();
            //translate([0,0,-height-1.5]) rotate([0,180,90]) scale([0.5,0.5,2]) import("descent.stl");
        }
    }
    if (part == "spacer") {
        tokenSpacer();
    }
}
    

module tokenSpacer() {
    width=token_width*spacerGap;
    diameter=token_diameter-lid_gap;
    removeTop=1;
    translate([0,0,width/2]) {
        difference() {
            union() {
                
printShape(diameter=diameter, height=width);
                translate([0,diameter/2,0]) rotate([90,90,0]) 
                    notch(diameter, width);
            }
            // Cut off half the circle + remove top so we can place a rounded top
            translate([0,-diameter/2+removeTop,0])
                cube([diameter+1, diameter, width+2], center=true);
        }
        // Curve the top edge
        intersection() {
            translate([0,removeTop,0]) rotate([0,90,0]) {
                cylinder(d=width, h=diameter, center=true);
            }
            printShape(diameter=diameter, height=width);
        }
    }
}

module topContainer() {
    difference() {
        boxWithShapeRemoved(boxLength, boxWidth, height+.2, notches=false, extraHeight=boxLipDepth);
        translate([0,0,0]) {
            rotate([180,0,0]) {
                difference() {
                    bottomCube(boxLength-boxLipThickness+lid_gap, boxWidth-boxLipThickness+lid_gap, 5);
                }
            }
        }
    }
    // TODO: Remove magic 0.6 and .9
    translate([0,0,boxLipDepth-.9])
        // TODO: Remove magic 0.5 and .4
        cylinderRing(boxLength+lid_gap+1, boxWidth+lid_gap+1, .6, false);        
    
}

module bottomContainer() {
    difference() {
        // Extra height to handle notches
        boxWithShapeRemoved(boxLength, boxWidth, height + wallThickness, notches=true);
        
        // Create a lip on the top
        translate([0,0,-boxLipDepth]) {
            rotate([180,0,0]) {
                difference() {
                    bottomCube(boxLength+5, boxWidth+5, 5);
                    translate([0,0,2])
                        bottomCube(boxLength-boxLipThickness, boxWidth-boxLipThickness, 20);   
                }
            }
        }
        // TODO: Remove magic numbers (2, 0.5)
        translate([0,0,-boxLipDepth+.9])
            cylinderRing(boxLength-wallThickness/2+2, boxWidth-wallThickness/2+2, .6);        
    }
}

module boxWithShapeRemoved(length, width, height, notches=false, extraHeight=0) {
    difference() {
            // create the bottom cube
        bottomCube(length, width, height, extraHeight);

        // Remove the token space
        translate([0,-token_diameter/2*(number_of_token_groups)-(number_of_token_groups-1)*wallThickness/2,0]) {
            for (i=[0:1:number_of_token_groups-1]) {
                translate([0,(token_diameter/2 + token_diameter*i + wallThickness*i),0])
                    printShapeWithNotches(diameter=token_diameter, length=cylinderLength, notches=notches);
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


module printShapeWithNotches(diameter, length, notches) {
    translate([-length/2,0,0]) { 
        rotate([0,90,0]) translate([0,0,length/2])
            printShape(diameter=diameter, height=length);

        if (notches) {
            for (i=[1:1:numberOfTokenSpacers]) {
                translate([i * (number_of_tokens_between_spacers+1) * token_width - token_width/2, 0, -diameter/2])
                    notch(diameter, token_width);
            }
        }
    }
}

module notch(diameter, width) {
    cube([width,diameter/3,wallThickness*2], center=true);
}

module printShape(diameter, height) {
    if (token_shape == "circle") {
        cylinder(d=diameter, h=height, center=true);
    }
    if (token_shape == "square") {
        cube([diameter, diameter, height], center=true);
    }
    if (token_shape == "hexagon") {
        rotate([0,0,30])
            cylinder(d=diameter, h=height, center=true, $fn=6);
    }
    if (token_shape == "octagon") {
        rotate([0,0,22.5])
            cylinder(d=diameter, h=height, center=true, $fn=8);
    }
}
            
module cylinderRing(length, width, diameter) {
    scale([1,1,3]) {
        union() {
            translate([0,width/2,0]) rotate([0,90,0]) cylinder(d=diameter, h=length, center=true);
            translate([0,-width/2,0]) rotate([0,90,0]) cylinder(d=diameter, h=length, center=true);
            translate([length/2,0,0]) rotate([90,90,0]) cylinder(d=diameter, h=width, center=true);
            translate([-length/2,0,0]) rotate([90,90,0]) cylinder(d=diameter, h=width, center=true);
        }
    }

}
