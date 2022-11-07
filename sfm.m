clc;
clear;

load Photo/calibrazione_tom/camera_tom.mat

image1 = imread('Photo/set5/image1.jpg');
image2 = imread('Photo/set5/image2.jpg');

%%
figure
imshowpair(image1, image2, 'montage'); 
title('Original Images');

%%

intrinsics = cameraParams.Intrinsics;

image1 = undistortImage(image1, intrinsics);
image2 = undistortImage(image2, intrinsics);
%%
figure 
imshowpair(image1, image2, 'montage');
title('Undistorted Images');

%%

% Detect feature points
imagePoints1 = detectMinEigenFeatures(im2gray(image1), MinQuality = 0.1);
%%
% Visualize detected points
figure
imshow(image1, InitialMagnification = 50);
title('150 Strongest Corners from the First Image');
hold on
plot(selectStrongest(imagePoints1, 150));

%%

% Create the point tracker
tracker = vision.PointTracker(MaxBidirectionalError=1, NumPyramidLevels=5);

% Initialize the point tracker
imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, image1);

% Track the points
[imagePoints2, validIdx] = step(tracker, image2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);
%%
% Visualize correspondences
figure
showMatchedFeatures(image1, image2, matchedPoints1, matchedPoints2);
title('Tracked Features');

%%

% Estimate the fundamental matrix
[E, epipolarInliers] = estimateEssentialMatrix(...
    matchedPoints1, matchedPoints2, intrinsics, Confidence = 99.99);

% Find epipolar inliers
inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);
%%
% Display inlier matches
figure
showMatchedFeatures(image1, image2, inlierPoints1, inlierPoints2);
title('Epipolar Inliers');
%%

%for conic reconstruction

relPose = estrelpose(E, intrinsics, inlierPoints1, inlierPoints2);
P1 = cameraProjection(intrinsics, rigidtform3d);
P2 = cameraProjection(intrinsics, pose2extr(relPose));

