function C = leastSquaresConic(x,y)
    X = [x.^2 x.*y y.^2 x y];

    Y = -1 * ones(length(x), 1);

    cc = pinv(X)*Y;


    [a, b, c, d, e, f] = deal(cc(1), cc(2), cc(3), cc(4), cc(5), 1);
    C = [a b/2 d/2; b/2 c e/2; d/2 e/2 f];
end