function P = calibrationFunction(images)

[imagePoints,boardSize] = detectCheckerboardPoints(images.Files);

squareSize = 12; 
worldPoints = generateCheckerboardPoints(boardSize,squareSize);
I = readimage(images,1); 
imageSize = [size(I,1),size(I,2)];
cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
                                       'ImageSize',imageSize);
imOrig = imread('Photo\calibrazione\image9.jpg');
figure; imshow(imOrig);
title('Input Image');

im = undistortImage(imOrig,cameraParams);

[imagePoints,boardSize] = detectCheckerboardPoints(im);

[rotationMatrix,translationVector] = extrinsics(...
    imagePoints,worldPoints,cameraParams);

P = cameraMatrix(cameraParams,rotationMatrix,translationVector);
end