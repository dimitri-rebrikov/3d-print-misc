include <polyedge.scad>

bl=44.5;
bd=10.5;
g=1;
br=bd/2;
wall=1.68;


module bat() {
    circle(d=bd);
}

module bats() {
    translate([0,bd*2,0]) bat();
    translate([-bd*3.8,-bd*1,0]) bat();
     translate([-1,-bd,0]) bat();
}

module funnel2d() {
    minkowski() {
        circle(br);
        polygon([ 
            [0,0],[br,0],
            [bd,bd],
            [bd,bd*2],
            [bd,bd*4],
            [bd,bd*5],
            
            [-bd*4,bd*5],
            [-bd*4,bd*4],
            [-bd,bd*3],
            [0,bd*2]
        ]);
    };

    minkowski() {
        circle(br);
        polygon([
            [0,0],[br,0],
            [-2,-bd]
        ]);
    };
    translate([-1.8,-bd*0.9,0])
    minkowski() {
        circle(br);
        polygon([
            [0,0],[-bd*4,-bd*5*0.05],
            [-bd*4,-bd*5*0.05-g],[0,-g]
        ]);
    };
}

module side2d() {
    minkowski() {
        circle(br);
        polygon([
            [-bd*4.3,-bd*1.4],[bd+br,-bd*1.4],
            [bd+br,bd*4.5],[-bd*4.5,bd*4.5],
            [-bd*2.8,-bd*1.25]
        ]);
    };
}

module body2d() {
    difference() {
        side2d();
        funnel2d();
    }
}

module body() {
    linear_extrude(bl+g) {
        body2d();
    }
}

module side() {
    linear_extrude(wall) {
        side2d();
    }
}

//funnel2d();
//body2d();
//bats();
translate([0,0,wall]) body();
side();