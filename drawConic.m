function drawConic(C)
    im = zeros(3000, 3000);
    for i=1:3000
        for j=1:3000
            im(i,j)=[j i 1]*C*[j i 1]';
        end
    end

    imshow(im > 0);
end