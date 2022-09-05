function coeffs = findCoeffs(M1, mu)

coeffs = zeros(size(M1));

for i = 1:size(M1)
    temp = M1(i);
    coeffs(i) = subs(temp, mu, 1);
end
end