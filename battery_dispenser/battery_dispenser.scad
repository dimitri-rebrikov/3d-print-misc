include <polyedge.scad>

battery_length=44.5;
battery_diameter=10.5;
batteries_in_row=5;
batteries_rows=4;
gap = 1;
tunnel_angle = 5;
funnel_angle = 45;
wall = 2;



tunnel_offset = battery_diameter + gap + wall + (sin(tunnel_angle) * battery_diameter);
width = battery_diameter*batteries_in_row + gap*2 + wall*2;
tunnel_upper_elevation = sin(tunnel_angle) * (width/2 - battery_diameter/2 - gap/2);
tunnel_lower_elevation = sin(tunnel_angle) * (width/2 + battery_diameter/2 + gap/2 + battery_diameter);
funnel_height = sin(funnel_angle) * width / 2 + battery_diameter;
height = tunnel_lower_elevation + tunnel_offset + funnel_height + battery_diameter*batteries_rows;



module front_side() {
    polyedge([ 
        [battery_diameter/2 + gap, tunnel_offset+tunnel_upper_elevation,2], 
        [width / 2, tunnel_offset, wall],  
        [width / 2, height, wall], 
        [width / 2 - wall, height, 0],
        [width / 2 - wall, tunnel_offset + funnel_height, battery_diameter],
        [battery_diameter/2 + gap/2, tunnel_offset+battery_diameter, battery_diameter], 
    ],$fn=50);
}

module back_side() {
    polyedge([
        [0,0,wall],
        [0,height,wall],
        [wall,height,0],
        [wall,tunnel_offset + funnel_height, battery_diameter],
        [width/2 - battery_diameter/2 - gap, tunnel_offset+battery_diameter, battery_diameter],
        [width/2 - battery_diameter/2 + wall - gap, tunnel_lower_elevation + wall, battery_diameter],
        [width + battery_diameter/2, wall,battery_diameter/2],
        [width + battery_diameter/2 + wall, wall + battery_diameter/2, wall/2],
         [width + battery_diameter/2 + wall*2 , wall + battery_diameter/2,wall/2],
        [width + battery_diameter/2 + wall, 0,battery_diameter/2]
        ],$fn=50);
}

module side() {
    polyedge([
        [0,0,wall],
        [0,height,wall],
        [width,height,wall],
        [width,tunnel_offset,wall],
        [width - battery_diameter,battery_diameter/2,battery_diameter/2],
        [width + battery_diameter/2,wall+battery_diameter/4,wall],
        [width + battery_diameter/2 + wall,wall+battery_diameter/2,wall/2],
        [width + battery_diameter/2 + wall*2,wall+battery_diameter/2,wall/2],
        [width + battery_diameter/2 + wall,wall,0]
        ],$fn=50);
}

module battery() {
    circle(d=battery_diameter);
}

module batteries() {
translate([width/2+ gap/2,battery_diameter + 6,0]) battery();
translate([width/2+ gap + 4,battery_diameter ,0]) battery();
translate([width/2+ 15, tunnel_offset/2 + 2.4,0]) battery();
translate([width+2, tunnel_offset/2 + gap,0]) battery();
}

module three_sides() {
    //translate([0,0,wall]) linear_extrude(height = 10) {
    //    batteries();
    //}
    linear_extrude(height = wall + battery_length + gap) {
        back_side();
        translate([width/2,0,0]) front_side();
    }
    linear_extrude(height = wall) 
        side();
}

module top_side() {
    mirror([1,0,0]) difference() {
        three_sides();
        translate([0,0,wall]) cube([width + battery_diameter, height, battery_length + gap]);
   } 
}

three_sides();
translate([-10,0,0]) 
    top_side();

