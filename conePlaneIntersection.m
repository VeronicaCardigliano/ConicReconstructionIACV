function Conic = conePlaneIntersection(Cone,Plane)

    x = sym('x',[1 4]).';
    assume(x ~= 0);

    eqn = Plane.' * x == 0;

    point = solve(eqn, x);
    point = [point.x1 point.x2 point.x3 point.x4];

    Point1 = point.';
    Point2 = [point(1)+1 point(1,2) point(1,3)+(-Plane(1,1))/Plane(3,1) 1].';
    Point3 = [point(1) point(1,2)+1 point(1,3)+(-Plane(2,1))/Plane(3,1) 1].';

    M = double([Point1 Point2 Point3]);

    Conic = M.' * Cone * M;
    
end