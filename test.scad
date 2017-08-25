smallTokenDiameter=11.5;
largeTokenDiameter=25.5;
wallThickness=2;

tokensBetweenSpacers=5;
tokenDiameter=smallTokenDiameter;
tokenWidth=2.3;
numberOfTokens=20;


numberOfTokenSpacers=floor(numberOfTokens/tokensBetweenSpacers);
length=tokenWidth * numberOfTokens + tokenWidth * numberOfTokenSpacers + wallThickness * 2;
width=tokenDiameter * 2 + wallThickness * 3;
height=smallTokenDiameter/2 + wallThickness * 2;  // Extra thick on bottom to deal with spacers

echo("numberOfTokenSpacers:", numberOfTokenSpacers);
echo("length:", length);
echo("width:", width);
echo("height:", height);


difference() {
    translate([length/2, 0, -height/2])
        cube([length, width, height], center=true);
    translate([wallThickness,(tokenDiameter/2+wallThickness/2),0])
        cylinderWithNotches(diameter=tokenDiameter, length=length-wallThickness*2);
    translate([wallThickness,-(tokenDiameter/2+wallThickness/2),0])
        cylinderWithNotches(diameter=tokenDiameter, length=length-wallThickness*2);
}

module cylinderWithNotches(diameter, length ) {
    rotate([0,90,0])
        cylinder(d=diameter,h=length);

    for (i=[1:1:numberOfTokenSpacers]) {
        translate([i * tokensBetweenSpacers * tokenWidth - tokenWidth/2, 0, -diameter/2])
            cube([tokenWidth,diameter/3,wallThickness*2], center=true);
    }
}
