function [P1, P2] = findExtrinsicParams(cameraParams)
firstImg = imread('Photo\image1.jpg');
secondImg = imread('Photo\image2.jpg');

imshow(firstImg);
hold on;

[x, y] = getpts;
pointsImage1 = [x, y];
scatter(x, y, 100, 'filled');

hold off;

[rotationMatrix,translationVector] = extrinsics(...
    pointsImage1,pointsImage1,cameraParams);

P1 = cameraMatrix(cameraParams,rotationMatrix,translationVector);

imshow(secondImg);
hold on;

[x, y] = getpts;
pointsImage2 = [x, y];
scatter(x, y, 100, 'filled');

hold off;

[rotationMatrix,translationVector] = extrinsics(...
    pointsImage2,pointsImage1,cameraParams);

P2 = cameraMatrix(cameraParams,rotationMatrix,translationVector);
end