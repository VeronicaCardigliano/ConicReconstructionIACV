function plotPlaneSurface(plane, range,n)
a = plane(1);
b = plane(2);
c = plane(3);
d = plane(4);

gv = linspace(-range/2,range/2,n);
[x,y,z] = meshgrid(gv,gv,gv);
F = a*x+b*y+c*z+d;
isosurface(x,y,z,F,0)
alpha(0.5)
