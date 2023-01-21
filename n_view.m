clc
clear

load Photo\calibrazione_tom\camera_tom.mat;

im1 = imread("Photo\set5\image1.jpg");
im2 = imread("Photo\set5\image2.jpg");
% im3 = imread("Photo\set7\im3.jpg");
% im4 = imread("Photo\set7\im4.jpg");
% im5 = imread("Photo\set7\im5.jpg");
% im6 = imread("Photo\set7\im6.jpg");
%%
images = [im1, im2];
n_views = 2;

Cameras = zeros([3 4*n_views]);
[height, width, ~] = size(im1);
for i=1:n_views-1

    img_start1 = (i-1)*width + 1;
    img_end1 = img_start1 + width - 1;

    img_start2 = i * width + 1;
    img_end2 = img_start2 + width - 1;

    figure;
    grid on
    axis equal

    if i==1
        [P1, P2] = computeCameras(images(:,img_start1:img_end1), images(:,img_start2:img_end2), cameraParams);
        
    else
        [P1, P2] = computeCameras(images(:,img_start1:img_end1), images(:,img_start2:img_end2), cameraParams, P2);

    end

    start_idx = (i - 1) * 4 + 1;
    Cameras(:, start_idx:start_idx+7) = [P1 P2];
end

hold off;

%%

im1 = undistortImage(im1, cameraParams.Intrinsics);
im2 = undistortImage(im2, cameraParams.Intrinsics);
% im3 = undistortImage(im3, cameraParams.Intrinsics);
% im4 = undistortImage(im4, cameraParams.Intrinsics);
% im5 = undistortImage(im5, cameraParams.Intrinsics);
% im6 = undistortImage(im6, cameraParams.Intrinsics);

images = [im1, im2];
%%



n_conics = 1;
Conics = zeros([3 n_views*n_conics*3]);

for i=1:n_views
    img_start = (i-1)*width + 1;
    img_end = img_start + width - 1;

    figure;
    imshow(images(:,img_start:img_end));
    hold on;

    for j=1:n_conics
        
        [x, y] = getpts();
        C = leastSquaresConic(x,y);

        conic_idx = (i-1)*3*n_conics + 1 + (j-1)*3;

        Conics(:, conic_idx:conic_idx+2) = C;
        %drawConic(C, images(:,img_start:img_end));
    end

    hold off;

end

%%
epsilon=1e-5;
fileID = fopen("Conic_and_Planes.txt", "a+");

if n_views == 2
    deltaMatrix = zeros([n_conics n_conics]);
end

figure
for i=1:(n_views - 1)                                              
    for j=1:n_conics                                           
        %for k=i+1:n_views
            for w=1:n_conics
                first_idx = (i - 1) * n_conics * 3 + 1 + (j - 1) * 3; %-1 and +1 for stupid MATLAB indexing starting with 1
                second_idx = (i) * n_conics * 3 + 1 + (w - 1) * 3;
                C1 = Conics(:,first_idx:first_idx+2);
                C2 = Conics(:, second_idx:second_idx+2);
    
                P1_idx = (i - 1)*4 + 1;
                P1 = Cameras(:, P1_idx:P1_idx+3);

                P2_idx = (i)*4 + 1;
                P2 = Cameras(:, P2_idx:P2_idx+3);

                A = P1.' * C1 * P1;
                B = P2.' * C2 * P2;
        
                lambda = computeLambda(A, B);
                delta = computeDelta(A, B);           
    
                disp ["delta"]
                disp(delta);

                if n_views == 2
                    deltaMatrix(j,w) = delta;
                end

                if abs(delta) < epsilon                
    
                    C = A + lambda*B;
                    
                    %save saved_variables C1 C2 C P1 P2 -mat
                    
                    e = eigs(C);

                    disp ["e3/e2"]
                    disp(e(3)/e(2))
                    
                    I = eye(4);
                    
                    if e(1)>0 && e(2)<0
                        % Singular values of A less than 0.0001 are treated as zero (tolerance)
                        v1 = null(C - e(1)*I, 0.0001);
                        v2 = null(C - e(2)*I, 0.0001);
                        
                        Plane1 = sqrt(e(1)) * v1 + sqrt(-e(2)) * v2;
                        Plane2 = sqrt(e(1)) * v1 - sqrt(-e(2)) * v2;
                    else 
                        if e(1) < 0 && e(2) > 0
                            % Singular values of A less than 0.0001 are treated as zero (tolerance)
                            v1 = null(C - e(2)*I, 0.0001);
                            v2 = null(C - e(1)*I, 0.0001);
                            
                            Plane1 = sqrt(e(2)) * v1 + sqrt(-e(1)) * v2;
                            Plane2 = sqrt(e(2)) * v1 - sqrt(-e(1)) * v2;
                        
                        else
                            disp ["Autovalori hanno stesso segno!!!"]
                            break
                        end
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
        
                    rangeK = 10;
                    range = rangeK*[-3 1 -3 1 0 3];
                    
                    if (dist_o1_plane1*dist_o2_plane1) > 0
                        Conic = conePlaneIntersection(A, Plane1);
                        plotSurfaceIntersection(A,'A', Plane1, range, fileID)
                        plotSurfaceIntersection(B,'B', Plane1, range, fileID)

                        hold on
                        %plotPlaneSurface(Plane1, range, 10)
                        %plotQuadricSurface(A, range)
                        %plotQuadricSurface(B,range)
                    else 
                        if (dist_o1_plane2 * dist_o2_plane2) > 0
                            Conic = conePlaneIntersection(A,'A', Plane2, fileID);
                            plotSurfaceIntersection(A,'A', Plane2, range, fileID)
                            plotSurfaceIntersection(B,'B', Plane2, range, fileID)
                            hold on
                            %plotPlaneSurface(Plane2, range, 10)
                            %plotQuadricSurface(A, range)
                            %plotQuadricSurface(B,range)
                        else
                            %give an error message
                        end
                    end
                end
            end
        %end
    end
end






