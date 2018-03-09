// TODO: Play with images, Play with preview rotation

/* [Global] */
part = "top"; // [all:bottom/top/spacer, bottom:Bottom of Box, top:Top of Box, spacer:Token Spacer

// List of [[Shape, Diameter]].   Examples - ["circle",20], ["square",20] , ["hexagon",20], ["octagon", 20], ["rectagle", [width, height]], ["diamond", [width, height]]
//tokensList = [["rectangle",[29.8, 25.5],2], ["octagon", 19.2], ["hexagon", 19.2], ["rectangle", [21.7, 19.4]], ["circle", 22.5], ["circle",19.2]];
tokensList = [["circle",25.7], ["circle",25.7], ["octagon",25.7]];

// How many tokens per group
number_of_tokens_per_group=20; 
// How many tokens between spacers (0 if you don't want spacers)
number_of_tokens_between_spacers=4; 

/* [Other] */
// Token Width
max_token_width=2.3; 
// Gap between top lid and bottom
lid_gap=0.6; 
$fn=50;

/* [Hidden] */
// Index locations inside tokensList
sIndex=0;
dIndex=1;
numberOfSpacersIndex=2;

// How many token groups
number_of_token_groups=len(tokensList); 
max_token_height=maxTokenHeight(v=tokensList); 
max_token_diameter=maxTokenDiameter(v=tokensList); 

keyHole=true;
keyHoleDiameter=15;

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
height=roundEdgesDiameter/2 + max_token_height/2 - roundEdgesDiameter;  
boxLipThickness=wallThickness + roundEdgesDiameter/2; // This would normally be wallThickness but the minkowski applies a half a roundEdgesDiameter to the outside of everything.

// Change this for putting a stencil on top of the lid box.   About a 2mm thick stl is what is expected.
surface_image_stl="descent/descent.stl";
surface_image_rotate=[0,180,90];
surface_image_translate=[0,0,-height-1.5];
surface_image_scale=[0.7,0.7,2];

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
        }
    }
    if (part == "spacer") {
        tokenSpacer();
    }
}

module tokenSpacer() {
    translate([0,-sumTokenHeights(v=tokensList)/2,0]) {
        for (i=[0:1:number_of_token_groups-1]) {
            if (tokenSpacers(tokensList[i]) > 0) {
                translate([0,sumToTokenHeights(v=tokensList,maxI=i)/2 + i*4,0.9]) {
                    tokenSpacerParamsDefined(token=tokensList[i], width=max_token_width*spacerGap);
                }
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
            printShape(token=token, height=width, isSpacer=true);
            translate([0,wallThickness,0]) rotate([90,90,0]) 
                notch(diameter, width, height, spacer=true);
        }
        // Cut off half + remove top so we can place a rounded top
        translate([0,-diameter+removeTop,0])
            cube([diameter*2, diameter*2, width+2], center=true);
    }
    // Curve the top edge
    intersection() {
        translate([0,removeTop,0]) rotate([0,90,0]) {
            cylinder(d=width, h=diameter*2, center=true);
        }
        printShape(token=token, height=width, isSpacer=true);
    }
}

module topContainer() {
    difference() {
        union() {
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
        
        printLidImage();
    }
}

module printLidImage() {
    if (surface_image_stl && surface_image_stl != "") {
        translate(surface_image_translate) rotate(surface_image_rotate) scale(surface_image_scale) import(surface_image_stl);
    }
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
   
        if (keyHole && boxLength > keyHoleDiameter) {
            translate([0,boxWidth/2+2.5,-3])
                rotate([90,0,0])
                    cube([keyHoleDiameter, 4, 4], h=4, center=true);
            translate([0,-(boxWidth/2+2.5),-3])
                rotate([90,0,0])
                    cube([keyHoleDiameter, 4, 4], h=4, center=true);
        }
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
    numberOfTokensPerSpacerForThisToken = tokenSpacers(token);
    numberOfSpacers = floor(length / ((numberOfTokensPerSpacerForThisToken+1) * max_token_width));

    translate([-length/2,0,0]) { 
        rotate([90,0,0]) rotate([0,90,0]) translate([0,0,length/2])
            printShape(token=token, height=length);

        if (notches && numberOfTokensPerSpacerForThisToken > 0) {
            for (i=[1:1:numberOfSpacers]) {
                translate([i * (numberOfTokensPerSpacerForThisToken+1) * max_token_width - max_token_width/2, 0, -wallThickness])
                    notch(diameter, max_token_width, height);
            }
        }
    }
}

module notch(diameter, width, height, spacer=false) {
    cube([width,diameter/3, height], center=true);
}

module printShape(token, height, isSpacer=false) {
    shape=token[sIndex];
    removeLidGap=isSpacer?lid_gap:0;
    diameter=tokenDiameter(token)-removeLidGap;
    tokenHeight=tokenHeight(token)-removeLidGap;
    if (shape == "circle") {
        cylinder(d=diameter, h=height, center=true);
    }
    if (shape == "square") {
        cube([diameter, diameter, height], center=true);
    }
    if (shape == "rectangle") {
        rotate([0,0,90])
            cube([tokenHeight, diameter, height], center=true);
    }
    if (shape == "hexagon") {
        hexagon(tokenHeight, height);
    }
    if (shape == "octagon") {
        octagon(diameter, height);
    }
    if (shape == "diamond") {
        diamond([diameter, tokenHeight, height], center=true);
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
function sumTokenHeights(v, i = 0, r = 0) = i < len(v) ? sumTokenHeights(v, i + 1, r + tokenHeight(v[i])) : r;
function sumToTokenHeights(v, i = 0, r = 0, maxI) = i < maxI ? sumToTokenHeights(v=v, i=i + 1, r=r + tokenHeight(v[i]), maxI=maxI) : r;


function maxTokenHeight(v, i = 0, m = 0) = i < len(v) ? maxTokenHeight(v, i + 1, m < tokenHeight(v[i]) ? tokenHeight(v[i]) : m) : m;

function maxTokenDiameter(v, i = 0, m = 0) = i < len(v) ? maxTokenDiameter(v, i + 1, m < tokenDiameter(v[i]) ? tokenDiameter(v[i]) : m) : m;

function tokenDiameter(token) = token[sIndex] == "rectangle" || token[sIndex] == "diamond" ? token[dIndex][0] : token[sIndex] == "hexagon" ? token[dIndex] * 1.15 : token[sIndex] == "octagon"? token[dIndex] * 1.085 : token[dIndex];

function tokenHeight(token) = token[sIndex] == "rectangle" || token[sIndex] == "diamond" ? token[dIndex][1] : token[sIndex] == "octagon" ? token[dIndex] * 1.085 : token[dIndex];

function tokenSpacers(token) = len(token) >= numberOfSpacersIndex+1 ? token[numberOfSpacersIndex] : number_of_tokens_between_spacers;

module diamond(p, center=false) {
    l=p[0];
    w=p[1];
    h=p[2];
    translate([center?-l/2:0,0,center?-h/2:0]) {
        CubePoints = [
          [ 0,  0,  0 ],  //0
          [ l/2,  -w/2,  0 ],  //1
          [ l,  0,  0 ],  //2
          [ l/2,  w/2,  0 ],  //3
          [ 0,  0,  h ],  //4
          [ l/2,  -w/2,  h ],  //5
          [ l,  0,  h ],  //6
          [ l/2,  w/2,  h ]]; //7

        /*  
        CubePoints = [
          [ 0,  0,  0 ],  //0
          [ l/2,  -w/2,  0 ],  //1
          [ l,  0,  0 ],  //2
          [ l/2,  w/2,  0 ],  //3
          [ 0,  0,  h ],  //4
          [ l/2,  -w/2,  h ],  //5
          [ l,  0,  h ],  //6
          [ l/2,  w/2,  h ]]; //7
        */
          
        CubeFaces = [
          [0,1,2,3],  // bottom
          [4,5,1,0],  // front
          [7,6,5,4],  // top
          [5,6,2,1],  // right
          [6,7,3,2],  // back
          [7,4,0,3]]; // left
           
        polyhedron( CubePoints, CubeFaces );
    }
}

module hexagon(tokenHeight, height) {
    // Taken from mcad
    // I have changed tokenDiameter to reflect the width of the hex token (wich is diamteter * 1.15).   But I don't want to use that when I actually generate the shape.   Instead I will use height which is the origional diameter.
    for (r = [-60, 0, 60]) rotate([0,0,r]) cube([tokenHeight/1.75, tokenHeight, height], true);
}

module octagon(diameter, height) {
    // Taken from mcad
    // I have changed tokenDiameter to reflect the width of the hex token (wich is diamteter * octagonDiameterFinder).   But I don't want to use that when I actually generate the shape.   Instead I will use height which is the origional diameter.
    rotate([0,0,20]) {
        intersection() {
            octagonDiameterFinder=1.085;
            cube([diameter/octagonDiameterFinder, diameter/octagonDiameterFinder, height], center=true);
            rotate([0,0,45]) cube([diameter/octagonDiameterFinder, diameter/octagonDiameterFinder, height], center=true);
        }
    }
}

