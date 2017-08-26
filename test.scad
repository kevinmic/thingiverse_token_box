$fn=50;
smallTokenDiameter=11.5;
largeTokenDiameter=25.5;

wallThickness=2;
tokensBetweenSpacers=5;
tokenDiameter=largeTokenDiameter;
tokenWidth=2.3;
numberOfTokensPerBox=20;
numberOfBoxes=1;


numberOfTokenSpacers=floor((numberOfTokensPerBox-1)/tokensBetweenSpacers);
length=tokenWidth * numberOfTokensPerBox + // tokens
       tokenWidth * numberOfTokenSpacers + // token spacers
       wallThickness * 2; // end walls
width=tokenDiameter * numberOfBoxes +
      wallThickness * 2 + // left and right side
      wallThickness * (numberOfBoxes); // between tokens
height=tokenDiameter/2 + wallThickness * 2;  // Extra thick on bottom to deal with spacers

echo("numberOfTokenSpacers:", numberOfTokenSpacers);
echo("length:", length);
echo("width:", width);
echo("height:", height);

difference() {
    // create the bottom cube
    bottomCube(length, width, height);

    // Remove the token space
    translate([0,-tokenDiameter/2*(numberOfBoxes)-(numberOfBoxes-1)*wallThickness/2,0]) {
        for (i=[0:1:numberOfBoxes-1]) {
            translate([0,(tokenDiameter/2 + tokenDiameter*i + wallThickness*i),0])
                cylinderWithNotches(diameter=tokenDiameter, length=length-wallThickness*2);
        }
    }
    
    // Create a lip on the top
    translate([0,0,-3]) {
        rotate([180,0,0]) {
            difference() {
                bottomCube(length+5, width+5, 5);
                translate([0,0,2])
                    bottomCube(length-wallThickness*1.5, width-wallThickness*1.5, 20);   
            }
        }
    }
    
}



module bottomCube(length, width, height) {
    difference() {
        minkowski() {
            cube([length, width, height*2], center=true);
            sphere(1);
        }        
        
        translate([-10, -10, height])
            cube([length*2, width*2, height*2], center=true);
    }
    
}


module cylinderWithNotches(diameter, length) {
    translate([-length/2,0,0]) { 
        rotate([0,90,0])
            cylinder(d=diameter,h=length);

        for (i=[1:1:numberOfTokenSpacers]) {
            translate([i * (tokensBetweenSpacers+1) * tokenWidth - tokenWidth/2, 0, -diameter/2])
                cube([tokenWidth,diameter/3,wallThickness*2], center=true);
        }
    }
}
