iw1 = 74;
iw2 = 68;
iw3 = 37;
iw4 = 13;
ih1 = 74;
ih2 = 9;
ih3 = 6;

cr1 = 6;
cr2 = 13;
cw1 = 70 + cr1 * 2;
ch1 = 28;

icoffset = 2.5;

$fn=50;

module insert2d() {
    polygon([
        [0,0], [(iw1-iw2)/2,0], 
        [(iw1-iw2)/2,-ih2], [(iw1-iw3)/2,-ih2],
        [(iw1-iw3)/2,-(ih2+ih3)], [(iw1-iw3)/2+iw3,-(ih2+ih3)],
        [(iw1-iw3)/2+iw3,-ih2], [(iw1-iw2)/2+iw2,-ih2],
        [(iw1-iw2)/2+iw2,0], [iw1,0],
        [(iw1-iw4)/2+iw4,ih1-ih2-ih3], [(iw1-iw4)/2,ih1-ih2-ih3]
        
    ]);
}

module insert3d() {
    translate([-iw1/2,0,0])
    linear_extrude(75) {
        insert2d();
    }
}

module outcut() {
    resize([iw1-2,(ih1)-2,0]) {
        insert3d();
    }
}

module cap() {
    translate([-cw1/2,0,0])
    difference() {
        union() {
            cylinder(ch1, r=cr2);
            translate([cw1, 0, 0]) cylinder(ch1, r=cr2);
            translate([0,-cr2+icoffset,0]) cube([cw1, cr2*2-icoffset, ch1]);
        }
        union() {
            cylinder(ch1, r=cr1);
            translate([cw1, 0, 0]) cylinder(ch1, r=cr1);
        }
    }
}

translate([0,ih2+ih3+icoffset-cr2,0])
insert3d();
cap();