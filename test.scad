smallTokenDiameter=11.5;
largeTokenDiameter=25.5;

wallThickness=2;
tokensBetweenSpacers=5;
tokenDiameter=largeTokenDiameter;
tokenWidth=2.3;
numberOfTokensPerBox=20;
numberOfBoxes=2;


numberOfTokenSpacers=floor((numberOfTokensPerBox-1)/tokensBetweenSpacers);
length=tokenWidth * numberOfTokensPerBox + tokenWidth * numberOfTokenSpacers + wallThickness * 2;
width=tokenDiameter * numberOfBoxes +
      wallThickness * 2 + // left and right side
      wallThickness/2 * (numberOfBoxes-1); // center spacers
height=tokenDiameter/2 + wallThickness * 2;  // Extra thick on bottom to deal with spacers

echo("numberOfTokenSpacers:", numberOfTokenSpacers);
echo("length:", length);
echo("width:", width);
echo("height:", height);


difference() {
    translate([0, 0, -height])
        cube([length, width, height], center=false);

    translate([wallThickness,wallThickness,0]) {
        for (i=[0:1:numberOfBoxes-1]) {
            translate([0,(tokenDiameter/2 + tokenDiameter*i + wallThickness*i/2),0])
                cylinderWithNotches(diameter=tokenDiameter, length=length-wallThickness*2);
        }
    }
}

module cylinderWithNotches(diameter, length ) {
    rotate([0,90,0])
        cylinder(d=diameter,h=length);

    for (i=[1:1:numberOfTokenSpacers]) {
        translate([i * (tokensBetweenSpacers+1) * tokenWidth - tokenWidth/2, 0, -diameter/2])
            cube([tokenWidth,diameter/3,wallThickness*2], center=true);
    }
}
