smallTokenDiameter=19.5;
wallThickness=2;

tokensBetweenSpacers=5;
tokenDiameter=smallTokenDiameter;
tokenThickness=2.3;
numberOfTokens=20;


numberOfTokenSpacers=floor(numberOfTokens/tokensBetweenSpacers);
length=tokenThickness * numberOfTokens + tokenThickness * numberOfTokenSpacers + wallThickness * 2;
width=45;
height=13;

echo("numberOfTokenSpacers:", numberOfTokenSpacers);
echo("length:", length);
echo("width:", width);
echo("height:", height);

difference() {
    translate([length/2, 0, -height/2])
        cube([length, width, height], center=true);
    translate([0,11,0])
        cylinderWithNotches(diameter=smallTokenDiameter, length=length);
    translate([0,-11,0])
        cylinderWithNotches(diameter=smallTokenDiameter, length=length);
}

module cylinderWithNotches(diameter, length ) {

    adjustedLength = length - wallThickness*2;
    translate([wallThickness,0,0]) {
        rotate([0,90,0])
            cylinder(d=diameter,h=adjustedLength);

        for (d=[tokenThickness*tokensBetweenSpacers:tokenThickness*(tokensBetweenSpacers+1):adjustedLength-(tokenThickness*(tokensBetweenSpacers+1))]) {
            echo(d);
            translate([d+tokenThickness-tokenThickness/2, 0, -diameter/2])
                cube([tokenThickness,diameter/3,4], center=true);
        }
    }
}
