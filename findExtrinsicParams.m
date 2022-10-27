function [P1, P2] = findExtrinsicParams(cameraParams, display)

firstImg = imread('Photo/set4/image2.jpg');
secondImg = imread('Photo/set4/image5.jpg');

intrinsics = cameraParams.Intrinsics;

[firstImg,newOrigin] = undistortImage(firstImg,intrinsics,OutputView='full');
[imagePoints,~] = detectCheckerboardPoints(firstImg);

if display == 1
    figure(1);
    imshow(firstImg);
    hold on;
    
    for i=1:length(imagePoints)
        plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
    end
    
    hold off;
end

imagePoints = imagePoints+newOrigin;

boardSize = [10 14];

pointsToNan = [55 129];

for i=1:length(pointsToNan)
    imagePoints(pointsToNan(i),:) = nan;
end

pointsToEliminate = [1 11 21 31 41 51 61 71 81 91 101 111 121];

for i=1:length(pointsToEliminate)
    imagePoints(pointsToEliminate(i)+1-i,:) = [];
end

if display == 1
    imshow(firstImg);
    hold on;
    
    for i=1:length(imagePoints)
        plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
    end
    
    hold off;
end

squareSize = 26; 
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

i = 1;
len = length(imagePoints);
while i <= len
    if isnan(imagePoints(i,:))
        imagePoints(i,:) = [];
        worldPoints(i,:) = [];
        len = len - 1;
    else
        i = i + 1;
    end

end

camExtrinsics = estimateExtrinsics(imagePoints,worldPoints,intrinsics);

if display == 1
    zCoord = zeros(size(worldPoints,1),1);
    worldPoints = [worldPoints zCoord];
    
    projectedPoints = world2img(worldPoints, camExtrinsics, intrinsics);
    
    hold on
    plot(projectedPoints(:,1),projectedPoints(:,2),'g*-');
    legend('Projected points');
    hold off
end

P1 = cameraProjection(intrinsics,camExtrinsics);

[secondImg,newOrigin] = undistortImage(secondImg,cameraParams,'OutputView','full');
[imagePoints, boardSize] = detectCheckerboardPoints(secondImg);

if display == 1
    figure(2);
    imshow(secondImg);
    hold on;
    
    for i=1:length(imagePoints)
        plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
    end
    
    hold off;
end

imagePoints = imagePoints+newOrigin;

worldPoints = generateCheckerboardPoints(boardSize,squareSize);

i = 1;
len = length(imagePoints);
while i <= len
    if isnan(imagePoints(i,:))
        imagePoints(i,:) = [];
        worldPoints(i,:) = [];
        len = len - 1;
    else
        i = i + 1;
    end

end

camExtrinsics = estimateExtrinsics(imagePoints,worldPoints,intrinsics);

if display == 1
    zCoord = zeros(size(worldPoints,1),1);
    worldPoints = [worldPoints zCoord];
    
    projectedPoints = world2img(worldPoints, camExtrinsics, intrinsics);
    
    hold on
    plot(projectedPoints(:,1),projectedPoints(:,2),'g*-');
    legend('Projected points');
    hold off
end

P2 = cameraProjection(intrinsics, camExtrinsics);
end