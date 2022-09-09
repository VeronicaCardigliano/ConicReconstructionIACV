function [P1, P2] = findExtrinsicParams(cameraParams)
firstImg = imread('Photo\set4\image2.jpg');
secondImg = imread('Photo\set4\image5.jpg');
%{
img3 = imread('Photo\set4\image3.jpg');
img4 = imread('Photo\set4\image4.jpg');
img5 = imread('Photo\set4\image5.jpg');


%1
[imagePoints,~] = detectCheckerboardPoints(firstImg);

figure(1);
imshow(firstImg);
hold on;

for i=1:length(imagePoints)
    plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
end

hold off;

%2
[imagePoints,~] = detectCheckerboardPoints(secondImg);

figure(2);
imshow(secondImg);
hold on;

for i=1:length(imagePoints)
    plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
end

hold off;

%3
[imagePoints,~] = detectCheckerboardPoints(img3);

figure(3);
imshow(img3);
hold on;

for i=1:length(imagePoints)
    plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
end

hold off;

%4
[imagePoints,~] = detectCheckerboardPoints(img4);

figure(4);
imshow(img4);
hold on;

for i=1:length(imagePoints)
    plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
end

hold off;

%5
[imagePoints,~] = detectCheckerboardPoints(img5);

figure(5);
imshow(img5);
hold on;

for i=1:length(imagePoints)
    plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
end

hold off;
%}

[imagePoints,~] = detectCheckerboardPoints(firstImg);

figure(1);
imshow(firstImg);
hold on;

for i=1:length(imagePoints)
    plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
end

hold off;

boardSize = [10 14];

pointsToNan = [55 129];

for i=1:length(pointsToNan)
    imagePoints(pointsToNan(i),:) = nan;
end

pointsToEliminate = [1 11 21 31 41 51 61 71 81 91 101 111 121];

for i=1:length(pointsToEliminate)
    imagePoints(pointsToEliminate(i)+1-i,:) = [];
end

imshow(firstImg);
hold on;

for i=1:length(imagePoints)
    plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
end

hold off;

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

[rotationMatrix,translationVector] = extrinsics(imagePoints, worldPoints, cameraParams);

zCoord = zeros(size(worldPoints,1),1);
worldPoints = [worldPoints zCoord];

projectedPoints = worldToImage(cameraParams,rotationMatrix,translationVector,worldPoints);
hold on
plot(projectedPoints(:,1),projectedPoints(:,2),'g*-');
legend('Projected points');
hold off

P1 = cameraMatrix(cameraParams,rotationMatrix,translationVector);

[imagePoints,~] = detectCheckerboardPoints(secondImg);

imshow(secondImg);
hold on;

for i=1:length(imagePoints)
    plot(imagePoints(i,1), imagePoints(i,2), 'r+', 'MarkerSize', 10, 'LineWidth', 1);
end

hold off;

worldPoints = generateCheckerboardPoints(boardSize,squareSize);

pointsToNan = [14];

for i=1:length(pointsToNan)
    imagePoints(pointsToNan(i),:) = nan;
end

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

[rotationMatrix,translationVector] = extrinsics(imagePoints, worldPoints, cameraParams);

zCoord = zeros(size(worldPoints,1),1);
worldPoints = [worldPoints zCoord];

projectedPoints = worldToImage(cameraParams,rotationMatrix,translationVector,worldPoints);
hold on
plot(projectedPoints(:,1),projectedPoints(:,2),'g*-');
legend('Projected points');
hold off

P2 = cameraMatrix(cameraParams,rotationMatrix,translationVector);
end