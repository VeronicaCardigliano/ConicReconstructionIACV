function Conic = conePlaneIntersection(Cone,Plane)

    M = getPlaneSpan(Plane);

    Conic = M.' * Cone * M;
    
end