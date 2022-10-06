clear;
clc;

var = 1;
calculateCameraParams = 0;
display = 0;

if var == 1
    image1 = imread('Photo/set4/image2.jpg');
    image2 = imread('Photo/set4/image5.jpg');
    
    calibrationImages = imageDatastore('Photo/calibrazione');
    
    if calculateCameraParams == 1
        cameraParams = calibrationFunction(calibrationImages);
        save saved_variables cameraParams -mat
    else
        load saved_cameraParameters.mat;
    end

    [P1, P2] = findExtrinsicParams(cameraParams, display);
    
    %intrinsic = findIntrinsic(calibrationImages);
    
    imshow(image1);
    hold on;
    
    [x, y] = getpts;
    scatter(x, y, 100, 'filled');
    C1 = leastSquaresConic(x, y);

    hold off;

    imshow(image2);
    hold on;
    
    [x, y] = getpts;
    scatter(x, y, 100, 'filled');
    
    C2 = leastSquaresConic(x, y);
    
    hold off;

    %draw Conics
    drawConic(C1, image1);
    drawConic(C2, image2);
      
else
    P1 = [1.393757 -0.244708 -14.170794 368.0;
        10.624195 2.396275 -0.433595 202.0;
        0.002859 0.011811 -0.003481 1.0];

    P2 = [1.374060 -0.612998 -14.189693 371.0;
        10.979978 -1.621189 -0.469463 207.0;
        0.007648 0.010572 -0.003449 1.0];

    Q1 = [-0.0013 0.4710^-5 -0.00023 0.0058;
        0.4710^-5 -0.000078 -0.00034 0.0033;
        -0.00023 -0.00034 -0.0014 0.011;
        0.0058 0.0033 0.011 -0.038];

    Plane1 = [-0.021 -0.16 -0.092 1.0].';

    Q2 = [1.0 0.0 0.0 -9.0;
        0.0 1.0 0.0 -2.0;
        0.0 0.0 1.0 -10.0;
        -9.0 -2.0 -10.0 85.0];

    Plane2 = [-0.196589 -0.812143 0.239359 1.0].';
    
    Point1 = [748/21 1 1 1].';
    Point2 = [769/21 1 71/92 1].';
    Point3 = [748/21 2 -17/23 1].';

    M1 = [Point1 Point2 Point3];
    
    C1 = M1.' * Q1 * M1;

    x = sym('x',[1 4]).';
    assume(x ~= 0);

    eqns = Plane2.' * x == 0;

    point = solve(eqns, x);
    point = [point.x1 point.x2 point.x3 point.x4];

    Point1 = point.';
    Point2 = [point(1)+1 point(1,2) point(1,3)+(-Plane2(1,1))/Plane2(3,1) 1].';
    Point3 = [point(1) point(1,2)+1 point(1,3)+(-Plane2(2,1))/Plane2(3,1) 1].';
    

    M2 = double([Point1 Point2 Point3]);
    
    C2 = M2.' * Q2 * M2;

    for i=1:3
        for j=1:3
            C1(i,j) = C1(i,j)/C1(3,3);
            C2(i,j) = C2(i,j)/C2(3,3);
        end
    end

    %drawconic( C1, [ -100 100 -100 100 ], [ 0.1 0.1 ], 'b-' ), grid;
    %drawconic( C2, [ -100 100 -100 100 ], [ 0.1 0.1 ], 'b-' ), grid; 

end
%%

A = P1.' * C1 * P1;
B = P2.' * C2 * P2;

lambda = computeLambda(A, B);

C = A + lambda*B;

save saved_variables C1 C2 C P1 P2 -mat
%%

e = eigs(C);

%equation = mu^2 + a_lam_coeffs(4)*mu + a_lam_coeffs(3) == 0;

%sols = solve(equation, mu);
I = eye(4);

bho1 = C - e(1)*I;
bho2 = C - e(2)*I;

v1 = null(bho1);
v2 = null(bho2);

%{
eqns1 = [bho1(1,:)*v1 == 0, bho1(2,:)*v1 == 0, bho1(3,:)*v1 == 0, bho1(4,:)*v1 == 0];
v1 = solve(eqns1, v1);

eqns2 = [bho1(1,:)*v1 == 0, bho1(2,:)*v1 == 0, bho1(3,:)*v1 == 0, bho1(4,:)*v1 == 0];
v2 = solve(eqns2, v2);
%}

Plane1 = sqrt(e(1)) * v1 + sqrt(e(2)) * v2;
Plane2 = sqrt(e(1)) * v1 - sqrt(e(2)) * v2;

projection_centre1 = null(P1);
projection_centre2 = null(P2);

side1_plane1 = projection_centre1.' * Plane1;
side2_plane1 = projection_centre2.' * Plane1;

side1_plane2 = projection_centre1.' * Plane2;
side2_plane2 = projection_centre2.' * Plane2;

if side1_plane1*side2_plane1 > 0
    Conic = conePlaneIntersection(A, Plane1);
else 
    if side1_plane2 * side2_plane2 > 0
        Conic = conePlaneIntersection(A, Plane2);
    else
        %give an error message
    end
end

%display result







