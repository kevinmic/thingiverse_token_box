// smallmax_token_diameter=19.5;
// largemax_token_diameter=25.5;

// TODO: Play with images, Play with preview rotation

/* [Global] */
part = "all"; // [all:Bottom/Top/Spacer, bottom:Bottom of Box, top:Top of Box, spacer:Token Spacer

// List of [["Shape", Diameter]].   Possible shapes are circle, square, hexagon, octagon]
tokensList = [["circle",30], ["square",10], ["hexagon",19.5], ["octagon", 30], ["rectangle", [20,20]]];

// How many tokens per group
number_of_tokens_per_group=34; 
// How many tokens between spacers
number_of_tokens_between_spacers=5; 

/* [Other] */
// Token Width
max_token_width=2.3; 
// Gap between top and bottom
lid_gap=0.5; 
$fn=50;

/* [Hidden] */
// Index locations inside tokensList
sIndex=0;
dIndex=1;

// How many token groups
number_of_token_groups=len(tokensList); 
max_token_diameter=maxTokenHeight(v=tokensList); 

spacerGap=0.95; // Spacer Gap percentage
wallThickness=2; // Changing this will likly cause problems.
roundEdgesDiameter=2;  // Changing this will likly cause problems.
boxLipDepth=3;  // Changing this might cause problems.

// How many token spacers need to be printer per group
numberOfTokenSpacers=floor((number_of_tokens_per_group-1)/number_of_tokens_between_spacers);
// Total Cylinder Length
cylinderLength=max_token_width * number_of_tokens_per_group + // tokens
       max_token_width * numberOfTokenSpacers; // token spacers
// Total Box Length
boxLength = cylinderLength + wallThickness * 2 - roundEdgesDiameter; // end walls
// Total Box Width
boxWidth=sumTokenWidths(tokensList) +
      wallThickness * 2 + // left and right side
      wallThickness * (number_of_token_groups-1) // between cylinders
      - roundEdgesDiameter; 
height=roundEdgesDiameter/2 + max_token_diameter/2 - roundEdgesDiameter;  
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

            translate([-(boxLength*.6+max_token_diameter/2),0,-height-roundEdgesDiameter*2]) tokenSpacer();
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
    translate([0,-sumTokenWidths(v=tokensList)/2,0]) {
        for (i=[0:1:number_of_token_groups-1]) {
            translate([0,sumToTokenWidths(v=tokensList,maxI=i)/2 + i*4,0.9]) {
                tokenSpacerParamsDefined(token=tokensList[i], width=max_token_width*spacerGap);
            }
        }
    }
}

module tokenSpacerParamsDefined(token, width) {
    removeTop=1;
    diameter = tokenDiameter(token)-lid_gap;
    height = tokenHeight(token);

    difference() {
        union() {                
            // todo
            printShape(token=token, height=width, isSpacer=true);
            translate([0,height/2,0]) rotate([90,90,0]) 
                notch(diameter, width);
        }
        // Cut off half + remove top so we can place a rounded top
        translate([0,-diameter/2+removeTop,0])
            cube([diameter+1, diameter, width+2], center=true);
    }
    // Curve the top edge
    intersection() {
        translate([0,removeTop,0]) rotate([0,90,0]) {
            cylinder(d=width, h=diameter, center=true);
        }
        printShape(token=token, height=width, isSpacer=true);
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
    translate([0,0,boxLipDepth-.9])
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
        translate([0,-sumTokenWidths(v=tokensList)/2-(number_of_token_groups-1)*wallThickness/2,0]) {
            for (i=[0:1:number_of_token_groups-1]) {
                translate([0,(tokenDiameter(tokensList[i])/2 + rsumTokenWidths(v=tokensList, i=i-1) + wallThickness*i),0])
                    printShapeWithNotches(token=tokensList[i], length=cylinderLength, notches=notches);
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


module printShapeWithNotches(token, length, notches) {
    diameter = tokenDiameter(token);
    height = tokenHeight(token);
    translate([-length/2,0,0]) { 
        rotate([0,90,0]) translate([0,0,length/2])
            printShape(token=token, height=length);

        if (notches) {
            for (i=[1:1:numberOfTokenSpacers]) {
                translate([i * (number_of_tokens_between_spacers+1) * max_token_width - max_token_width/2, 0, -height/2])
                    notch(diameter, max_token_width);
            }
        }
    }
}

module notch(diameter, width) {
    cube([width,diameter/3,wallThickness*2], center=true);
}

module printShape(token, height, isSpacer=false) {
    shape=token[sIndex];
    diameter=tokenDiameter(token)-(isSpacer?lid_gap:0);
    if (shape == "circle") {
        cylinder(d=diameter, h=height, center=true);
    }
    if (shape == "square") {
        cube([diameter, diameter, height], center=true);
    }
    if (shape == "rectangle") {
        if (isSpacer) {
            rotate([0,0,90])
                cube([tokenHeight(token), diameter, height], center=true);
        }
        else {
            cube([tokenHeight(token), diameter, height], center=true);
        }
    }
    if (shape == "hexagon") {
        if (isSpacer) {
            cylinder(d=diameter, h=height, center=true, $fn=6);
        }
        else {
            rotate([0,0,30])
                cylinder(d=diameter, h=height, center=true, $fn=6);
        }
    }
    if (shape == "octagon") {
        intersection() {
            cube([diameter, diameter, height], center=true);
            rotate([0,0,45]) cube([diameter, diameter, height], center=true);
        }
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

function sumTokenWidths(v, i = 0, r = 0) = i < len(v) ? sumTokenWidths(v, i + 1, r + tokenDiameter(v[i])) : r;
function sumToTokenWidths(v, i = 0, r = 0, maxI) = i < maxI ? sumToTokenWidths(v=v, i=i + 1, r=r + tokenDiameter(v[i]), maxI=maxI) : r;
function rsumTokenWidths(v, i, r = 0) = i >= 0 ? rsumTokenWidths(v, i - 1, r + tokenDiameter(v[i])) : r;


function maxTokenHeight(v, i = 0, m = 0) = i < len(v) ? maxTokenHeight(v, i + 1, m < tokenHeight(v[i]) ? tokenHeight(v[i]) : m) : m;
function tokenDiameter(token) = token[sIndex] == "rectangle"? token[dIndex][0] : token[dIndex];
function tokenHeight(token) = token[sIndex] == "rectangle"? token[dIndex][1] : token[dIndex];
