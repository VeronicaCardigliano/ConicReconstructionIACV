function C = getConicMatrix(x,y)
    A = [x.^2 x.*y y.^2 x y ones(size(x))];
    N = null(A);

    cc = N(:, 1);
    [a, b, c, d, e, f] = deal(cc(1), cc(2), cc(3), cc(4), cc(5), cc(6));
    C = [a b/2 d/2; b/2 c e/2; d/2 e/2 f];
end