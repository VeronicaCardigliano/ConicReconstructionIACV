function cameraParams = calibrationFunction(images)

[imagePoints,boardSize] = detectCheckerboardPoints(images.Files);

squareSize = 13; 
worldPoints = generateCheckerboardPoints(boardSize,squareSize);
I = readimage(images,9);
imageSize = [size(I,1),size(I,2)];
cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
                                       'ImageSize',imageSize);

figure; 
J = readimage(images,1);
imshow(J); 
hold on;
plot(imagePoints(:,1,1), imagePoints(:,2,1),'go');
plot(cameraParams.ReprojectedPoints(:,1,1),cameraParams.ReprojectedPoints(:,2,1),'r+');
legend('Detected Points','ReprojectedPoints');
hold off;

end