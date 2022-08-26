clear;
clc;

var = 1;
var1 = 1;

if var == 1
    image1 = imread('Photo/image1.jpg');
    image2 = imread('Photo/image2.jpg');
    
    imgGray1 = rgb2gray(image1);
    imgGray2 = rgb2gray(image2);
    
    calibrationImages = imageDatastore('Photo/calibrazione');
    
    if var1 == 1
        P = calibrationFunction(calibrationImages);
    else
        P = 1.0e+05 * [0.0303 0.0001 -0.0000; 0.0002 0.0310 0.0000; 0.0153 0.0191 0.0000; 0.9280 2.1395 0.0017];
    end
    P = P.';
    
    if var1 == 1
        imshow(imgGray1);
        hold on;
        
        [x, y] = getpts;
        scatter(x, y, 100, 'filled');
        C1 = getConicMatrix(x, y);

        hold off;
    else
        C1 = [0.0000 -0.0000 -0.0015;
            -0.0000 0.0000 -0.0011;
            -0.0015 -0.0011 1.0000];
    end
    
    if var1 == 1
        imshow(imgGray2);
        hold on;
        
        [x, y] = getpts;
        scatter(x, y, 100, 'filled');
        
        C2 = getConicMatrix(x, y);
        
        hold off;
    else
        C2 = [0.0000 -0.0000 -0.0009;
            -0.0000 0.0000 -0.0020;
            -0.0009 -0.0020 1.0000];
    end
    
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
    
    x = sym('x',[1 4]).';
    assume(x(4) == 1);

    eqns = [x.' * Q1 * x == 0, Plane1.' * x == 0];

    A = solve(eqns, x);

    eqns = [x.' * Q2 * x == 0, Plane2.' * x == 0];

    B = solve(eqns, x);
   
    pointsA = findPoints(A);
    pointsB = findPoints(B);

    pointsA = to2DPoints(pointsA, P1);
    pointsB = to2DPoints(pointsB, P2);

    for i=1:length(pointsA)
        pointsA(i,:) = pointsA(i,:)/pointsA(i, 3);
    end

    for i=1:length(pointsB)
        pointsB(i,:) = pointsB(i,:)/pointsB(i, 3);
    end

    C1 = getConicMatrix(pointsA(:,1), pointsA(:,2));
    C2 = getConicMatrix(pointsB(:,1), pointsB(:,2));

end

A = P1.' * C1 * P1;
B = P2.' * C2 * P2;

syms lam;

C = A + lam*B;

a4_lam = det(C);

I = coeffs(a4_lam);

I(1) = [];
I(4) = [];

delta = I(2)^2 - 4*I(1)*I(3);

lambda = -I(2) / 2*I(1);

C = A + lambda*B;





