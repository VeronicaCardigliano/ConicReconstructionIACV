function coeffs = extractCoefficients(Quadric)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
a = Quadric(1,1);
b = Quadric(1,2);
c = Quadric(1,3);
d = Quadric(1,4);
e = Quadric(2,2);
f = Quadric(2,3);
g = Quadric(2,4);
h = Quadric(3,3);
i = Quadric(3,4);
l = Quadric(4,4);

coeffs = [a e h b c f d g i l];
end