function plotQuadricSurface(Q, range)
Q = Q / Q(4,4);
a = Q(1,1);
b = Q(2,2);
c = Q(3,3);
d = 2*Q(1,2);
e = 2*Q(1,3);
f = 2*Q(2,3);
g = 2*Q(1,4);
h = 2*Q(2,4);
l = 2*Q(3,4);

%gv = linspace(-range/2,range/2,n);
%[x, y, z] = meshgrid(gv,gv,gv);
%F = a*x.^2 + b*y.^2 + c*z.^2 + d*x.*y + e*x.*z + f*y.*z + g*x + h*y + l*z + 1;

%isosurface(x,y,z,F,0)
F = @(x,y,z)(a*x.^2 + b*y.^2 + c*z.^2 + d*x.*y + e*x.*z + f*y.*z + g*x + h*y + l*z + 1);
fimplicit3(F, range, "EdgeColor","none")

alpha(0.5)