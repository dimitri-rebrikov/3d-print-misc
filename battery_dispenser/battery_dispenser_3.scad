

module funnel2d_rs() {
    mx = 50;
    steps = 50;
    polygon([
        for (a = [1 :mx/steps: mx]) [ log(2,a)*5, a-1],
        [log(2,mx)*5, 0]
    ]);
}

module funnel2d_lts() {
    mx = 20;
    steps = 50;
    polygon([
        [0,10],
        for (a = [1 :mx/steps: mx]) [ -a+1, log(2,a)*4+20],
        [-mx+1,0]
    ]);
}


funnel2d_rs();
funnel2d_lts();