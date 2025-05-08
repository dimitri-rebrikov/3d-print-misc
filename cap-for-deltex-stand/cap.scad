iw1 = 78;
iw2 = 68;
iw3 = 37;
iw4 = 14;
ih1 = 74;
ih2 = 9;
ih3 = 6;

cr1 = 5.5;
cr2 = 13;
cw1 = 70 + cr1 * 2;
ch1 = 5;

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
    linear_extrude(5) {
        insert2d();
    }
}

module insert3d_small() {
    resize([iw1-10,(ih1)-10,0]) {
        insert3d();
    }
}

module cap() {
    difference() {
        union() {
            cylinder(ch1, r=cr2);
            translate([cw1, 0, 0]) cylinder(ch1, r=cr2);
            translate([0,-cr2,0]) cube([cw1, cr2*2, ch1]);
        }
        union() {
            cylinder(ch1, r=cr1);
            translate([cw1, 0, 0]) cylinder(ch1, r=cr1);
        }
    }
}

//difference() {
//insert3d();
//translate([5,3,0]) insert3d_small();
//}

cap();