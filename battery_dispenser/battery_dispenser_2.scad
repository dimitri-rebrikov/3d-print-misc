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
    translate([-bd*3.1,-bd*1,0]) bat();
     translate([-2.6,-bd*0.8,0]) bat();
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
            
            [-bd*3,bd*5],
            [-bd*3,bd*3],
            [-bd,bd*2],
            [0.3,bd*1]
        ]);
    };

    minkowski() {
        circle(br);
        polygon([
            [0.3,0],[br,0],
            [-1.6,-bd*0.8]
        ]);
    };
    translate([-1.8,-bd*0.7,0])
    minkowski() {
        circle(br);
        polygon([
            [0,0],[-bd*3,-bd*5*0.07],
            [-bd*3,-bd*5*0.07-g],[0,-g]
        ]);
    };
}

module side2d() {
    minkowski() {
        circle(br);
        polygon([
            [-bd*3.3,-bd*1.3],[bd*1.2,-bd*1.3],
            [bd*1.2,bd*4.5],[-bd*3.2,bd*4.5],
            [-bd*3.2,bd*2.8],
            [-bd*1.8,-bd*1.25]
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