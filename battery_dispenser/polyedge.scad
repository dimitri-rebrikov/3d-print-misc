
// Copyright (c) 2024 Robert Eisele ( https://raw.org ). All rights reserved.
// Licensed under the MIT license.

// https://raw.org/code/openscad-polygons-with-rounded-corners/


// Example: polyedge([ [x, y, t], ...]);
// The parameter t has the following options:
// = 0: If t is zero (or left out), the edge is becoming a normal sharp edge like in polygon()
// > 0: If t is positive, the edge will get a round corner with radius t
// < 0: If t is negative, the edge will get an inset of length -t from the original edge


function normalize (v) = v / norm(v);
function sgn(a, b) = sign(a[0] * b[1] - a[1] * b[0]);

module polyedge(pts, $fn=$fn) {

    polygon([for (L1 = [
        for (i = [1 : len(pts)])
        let(
            f = $fn == 0 ? 10 : $fn,
            A = pts[(i - 1)],
            B = pts[(i + 0) % len(pts)],
            C = pts[(i + 1) % len(pts)],

            r = B[2],
            S = [B[0], B[1]],
            a = normalize([A[0] - B[0], A[1] - B[1]]),
            b = normalize([C[0] - B[0], C[1] - B[1]]))

             (len(B) == 2 || B[2] == 0)
                ? [ S ]
                : (r < 0 
                    ? [ S - a * r, S - b * r ]
                    : [let(
                        w = r * sqrt(2 / (1 - a * b) - 1),
                        X = a * w,
                        Y = b * w,
                        M = (a + b) * (r / sqrt(1 - pow(a * b, 2))),
                        b1 = atan2(X[1] - M[1], X[0] - M[0]),
                        b2 = atan2(Y[1] - M[1], Y[0] - M[0]),
                        phi = sgn(a, b) * (sgn(a, b) * (b1 - b2) + 360) % 360,
                        segs = ceil(abs(phi) * f / 360)) 
                            for (j = [0 : segs]) 
                                B + M + [
                                    r * cos(b1 - j / segs * phi), 
                                    r * sin(b1 - j / segs * phi)]])]) for (L2 = L1) L2]); 
}
