function K = findIntrinsic(images)

imOrig = readimage(images,9);
originalPoints = ones([4 3]);

imshow(imOrig);
hold on;

[x, y] = getpts;
originalPoints(:,1) = x;
originalPoints(:,2) = y;
scatter(x, y, 100, 'filled');

hold off;

Hs = zeros([3 24]);

count = 1;

for i=1:8
  
    image = readimage(images,i);
    points = ones([4 3]);

    imshow(image);
    hold on;
    
    [x, y] = getpts;
    points(:,1) = x;
    points(:,2) = y;
    scatter(x, y, 100, 'filled');
    
    hold off;

    H = homographyEstimation(originalPoints.', points.');
    
    Hs(:,count:count+2) = H;
    count = count + 3;
end

circularPoints = zeros([16 3]);
I = [1 1i 0];
J = [1 -1i 0];

a = 1;
b = 1;

for j=1:length(Hs)/3
    circularPoints(a, :) = I * Hs(:,b:b+2);
    circularPoints(a, :) = circularPoints(a,:) / circularPoints(a, 3);
    circularPoints(a+1, :) = J * Hs(:,b:b+2);
    circularPoints(a+1, :) = circularPoints(a+1,:) / circularPoints(a+1, 3);
    a = a + 2;
    b = b + 3;
end


w = getConicMatrix(circularPoints(:,1), circularPoints(:,2));
DIAC = inv(w);

K = chol(DIAC);

end