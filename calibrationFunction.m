function cameraParams = calibrationFunction(images)

[imagePoints,boardSize] = detectCheckerboardPoints(images.Files);

squareSize = 13; 
worldPoints = generateCheckerboardPoints(boardSize,squareSize);
I = readimage(images,9);
imageSize = [size(I,1),size(I,2)];
cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
                                       'ImageSize',imageSize);

end