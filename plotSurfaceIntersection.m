function plotSurfaceIntersection(Q,plane)

a = Q(1,1);
b = Q(2,2);
c = Q(3,3);
d = 0.5*Q(1,2);
e = 0.5*Q(1,3);
f = 0.5*Q(2,3);
g = 0.5*Q(1,4);
h = 0.5*Q(2,4);
l = 0.5*Q(3,4);

a_p = plane(1);
b_p = plane(2);
c_p = plane(3);
d_p = plane(4);


quadric = @(x,y,z)(a*x.^2 + b*y.^2 + c*z.^2 + d*x.*y + e*x.*z + f*y.*z + g*x + h*y + l*z + 1);
plane = @(x,y,z)(a_p*x + b_p*y + c_p*z + d_p);

range = [-10 10 -10 10 -10 10];

figure

[~, hel_q] = imsurf(quadric, range);
[~, hel_p] = imsurf(plane, range);
intercurve(hel_q, hel_p)
hold on
fimplicit3(quadric, range, 'EdgeColor','none',"FaceColor","cyan" , "FaceAlpha",0.6)
fimplicit3(plane, 'EdgeColor','none',"FaceColor","yellow", "FaceAlpha",0.3);
