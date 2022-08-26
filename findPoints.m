function points = findPoints(element)
p1 = [element.x1(1) element.x2(1) element.x3(1) 1];
p2 = [element.x1(1) element.x2(1) element.x3(2) 1];
p3 = [element.x1(1) element.x2(2) element.x3(1) 1];
p4 = [element.x1(1) element.x2(2) element.x3(2) 1];
p5 = [element.x1(2) element.x2(1) element.x3(1) 1];
p6 = [element.x1(2) element.x2(1) element.x3(2) 1];
p7 = [element.x1(2) element.x2(2) element.x3(1) 1];
p8 = [element.x1(2) element.x2(2) element.x3(2) 1];

points = [p1; p2; p3; p4; p5; p6; p7; p8];
end