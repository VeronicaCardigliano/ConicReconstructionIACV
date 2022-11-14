function [P1, P2] = computeCameras(image1, image2, cameraParams, firstCamera)
    intrinsics = cameraParams.Intrinsics;
    
    image1 = undistortImage(image1, intrinsics);
    image2 = undistortImage(image2, intrinsics);

    % Detect feature points
    imagePoints1 = detectMinEigenFeatures(im2gray(image1), MinQuality = 0.1);

    % Create the point tracker
    tracker = vision.PointTracker(MaxBidirectionalError=1, NumPyramidLevels=5);
    
    % Initialize the point tracker
    imagePoints1 = imagePoints1.Location;
    initialize(tracker, imagePoints1, image1);
    
    % Track the points
    [imagePoints2, validIdx] = step(tracker, image2);
    matchedPoints1 = imagePoints1(validIdx, :);
    matchedPoints2 = imagePoints2(validIdx, :);

    % Estimate the fundamental matrix
    [E, epipolarInliers] = estimateEssentialMatrix(...
        matchedPoints1, matchedPoints2, intrinsics, Confidence = 99.99);
    
    % Find epipolar inliers
    inlierPoints1 = matchedPoints1(epipolarInliers, :);
    inlierPoints2 = matchedPoints2(epipolarInliers, :);

    %for conic reconstruction


    relPose = estrelpose(E, intrinsics, inlierPoints1, inlierPoints2);

    if ~exist("firstCamera", "var")
        tform = rigidtform3d;
    else
        tform = rigidtform3d(intrinsics.K \ firstCamera);
    end

    P1 = cameraProjection(intrinsics, tform);

    tform2 = rigidtform3d(tform.A * pose2extr(relPose).A);
    P2 = cameraProjection(intrinsics, tform2);




