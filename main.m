clear;
clc;
close all;

var = 1;
calculateCameraParams = 0;
calculateExtrinsic = 0;
display = 0;
num_conics = 2;
num_views = 2;
Conics = ones(3,3);
max = 10^10;
epsilon = 1e-2;
%%
if var == 1
    image1 = imread('Photo/set5/image1.jpg');
    image2 = imread('Photo/set5/image2.jpg');
    
    calibrationImages = imageDatastore('Photo/calibrazione');
    
    if calculateCameraParams == 1
        cameraParams = calibrationFunction(calibrationImages);
        save cameraParameters.mat -mat
    else
        load cameraParameters.mat;
    end
    
    if calculateExtrinsic == 1
        images = [image1 image2];
        [P1, P2] = cameraExtrinsics(images, cameraParams.Intrinsics, display);
    else 
        load cameraProjections.mat P1 P2;
    end

    image1 = undistortImage(image1, cameraParams);
    image2 = undistortImage(image2, cameraParams);
   %% 
    imshow(image1);
    hold on;
    
    [x, y] = getpts;
    scatter(x, y, 100, 'filled');
    C1_1 = leastSquaresConic(x, y);

    [x, y] = getpts;
    scatter(x, y, 100, 'filled');
    C2_1 = leastSquaresConic(x, y);
    
    Conics(:,:) = C1_1;
    Conics= [Conics C2_1];

    hold off;

    imshow(image2);
    hold on;
    
    [x, y] = getpts;
    scatter(x, y, 100, 'filled');
    C1_2 = leastSquaresConic(x, y);
    
    [x, y] = getpts;
    scatter(x, y, 100, 'filled');
    C2_2 = leastSquaresConic(x, y);
    
    Conics= [Conics C1_2];
    Conics= [Conics C2_2];
    
    hold off;

    %draw Conics
    %drawConic(C1_1,C1_2, image1);
    %drawConic(C2_1,C2_2, image2);
      
else
    P1 = [1.393757 -0.244708 -14.170794 368.0;
        10.624195 2.396275 -0.433595 202.0;
        0.002859 0.011811 -0.003481 1.0];

    P2 = [1.374060 -0.612998 -14.189693 371.0;
        10.979978 -1.621189 -0.469463 207.0;
        0.007648 0.010572 -0.003449 1.0];

    Q1 = [-0.0013 0.5*10^(-5) -0.00023 0.0058;
        0.5*10^(-5) -0.000078 -0.00034 0.0033;
        -0.00023 -0.00034 -0.0014 0.011;
        0.0058 0.0033 0.011 -0.038];

    Plane1_paper = [-0.021 -0.16 -0.092 1.0].';

    Q2 = [1.0 0.0 0.0 -9.0;
        0.0 1.0 0.0 -2.0;
        0.0 0.0 1.0 -10.0;
        -9.0 -2.0 -10.0 85.0];


    Plane2_paper = [-0.196589 -0.812143 0.239359 1.0].';

    %using conic deriving from Q1 and Plane1

    M1 = getPlaneSpan(Plane1_paper);
    C_space1 = M1.' * Q1 * M1;

    %try to project to Image
    % assuming world reference frame aligned with the plane containing the
    % conic -> points on plane are [x y 0 w].'
    % I need 3 point correspondences from plane to image
    
    P1_plane = [P1*M1(:,1) P1*M1(:,2) P1*M1(:,3)];
    P2_plane = [P2*M1(:,1) P2*M1(:,2) P2*M1(:,3)];

    C1_1 = inv(P1_plane).' * C_space1 * inv(P1_plane);
    C2_1 = inv(P2_plane).' * C_space1 * inv(P2_plane);

    

    %using conic deriving from Q2 and Plane2

    M2 = getPlaneSpan(Plane2_paper);
    C_space2 = M2.' * Q2 * M2;

    %try to project to Image
    % assuming world reference frame aligned with the plane containing the
    % conic -> points on plane are [x y 0 w].'
    % I need 3 point correspondences from plane to image

    P1_plane = [P1*M2(:,1) P1*M2(:,2) P1*M2(:,3)];
    P2_plane = [P2*M2(:,1) P2*M2(:,2) P2*M2(:,3)];

    C1_2 = inv(P1_plane).' * C_space2 * inv(P1_plane);
    C2_2 = inv(P2_plane).' * C_space2 * inv(P2_plane);
  

    n_sample_points = 30;
    noise = 2;

    C1_1 = addNoise2Conic(C1_1, n_sample_points, noise);
    C1_2 = addNoise2Conic(C1_2, n_sample_points, noise);
    C2_1 = addNoise2Conic(C2_1, n_sample_points, noise);
    C2_2 = addNoise2Conic(C2_2, n_sample_points, noise);

    Conics= [C1_1 C1_2 C2_1 C2_2];

 
end
%%

range = 1*[-10 10 -10 10 -10 10];

figure

fileID = fopen("Conic_and_Planes.txt", "w");

for i=1:(num_views - 1)                                              
    for j=1:num_conics                                           
        for k=i+1:num_views
            for w=1:num_conics
                first_idx = (i - 1) * num_conics * 3 + 1 + (j - 1) * 3; %-1 and +1 for stupid MATLAB indexing starting with 1
                second_idx = (k - 1) * num_conics * 3 + 1 + (w - 1) * 3;
                C1 = Conics(:,first_idx:first_idx+2);
                C2 = Conics(:, second_idx:second_idx+2);
    
                A = P1.' * C1 * P1;
                B = P2.' * C2 * P2;
        
                lambda = computeLambda(A, B);
                delta = computeDelta(A, B);           
    
                disp(delta);

                if abs(delta) < epsilon                
    
                    C = A + lambda*B;
                    
                    %save saved_variables C1 C2 C P1 P2 -mat
                    
                    e = eigs(C);
                    
                    I = eye(4);
                    
                    if e(1)>0 && e(2)<0
                        % Singular values of A less than 0.001 are treated as zero (tolerance)
                        v1 = null(C - e(1)*I, 0.0001);
                        v2 = null(C - e(2)*I, 0.0001);
                        
                        Plane1 = sqrt(e(1)) * v1 + sqrt(-e(2)) * v2;
                        Plane2 = sqrt(e(1)) * v1 - sqrt(-e(2)) * v2;
                    else
                        % Singular values of A less than 0.001 are treated as zero (tolerance)
                        v1 = null(C - e(2)*I, 0.0001);
                        v2 = null(C - e(1)*I, 0.0001);
                        
                        Plane1 = sqrt(e(2)) * v1 + sqrt(-e(1)) * v2;
                        Plane2 = sqrt(e(2)) * v1 - sqrt(-e(1)) * v2;
                    end
                    
                    o1 = null(P1);
                    o2 = null(P2);
        
                    o1 = o1 / o1(4);
                    o2 = o2 / o2(4);
                    
                    %num_plane = selectPlane(o, o_p, Plane1, Plane2);
                    
                    dist_o1_plane1 = o1.' * Plane1;
                    dist_o2_plane1 = o2.' * Plane1;
                    
                    dist_o1_plane2 = o1.' * Plane2;
                    dist_o2_plane2 = o2.' * Plane2;
        
                    
                    
                    if (dist_o1_plane1*dist_o2_plane1) > 0
                        Conic = conePlaneIntersection(A, Plane1);
                        plotSurfaceIntersection(A, "A",  Plane1, range, fileID)
                        plotSurfaceIntersection(B, "B", Plane1, range, fileID)
                        hold on
                        %plotPlaneSurface(Plane1, range, 10)
                        %plotQuadricSurface(A, range)
                        %plotQuadricSurface(B,range)
                        %plotSurfaceIntersection(Q1, Plane1_paper, range)
                    else 
                        if (dist_o1_plane2 * dist_o2_plane2) > 0
                            Conic = conePlaneIntersection(A, Plane2);
                            plotSurfaceIntersection(A, "A",  Plane2, range, fileID)
                            plotSurfaceIntersection(B, "B",  Plane2, range, fileID)
                            hold on
                            %plotPlaneSurface(Plane2, range, 10)
                            %plotQuadricSurface(A, range)
                            %plotQuadricSurface(B,range)
                            %plotSurfaceIntersection(Q1, Plane1_paper, range)
                        else
                            %give an error message
                        end
                    end
                end
            end
        end
    end
end

fclose(fileID);

% plotQuadricSurface(Q1, range)
% plotPlaneSurface(Plane1_paper, range, 10)
% plotQuadricSurface(Q2, range)
% plotPlaneSurface(Plane2_paper, range, 10)
