function TwoDPoints = to2DPoints(ThreeDPoints, P)

TwoDPoints = zeros(length(ThreeDPoints), 3);

for i=1:length(ThreeDPoints)
    TwoDPoints(i, :) = P * ThreeDPoints(i, :).';
end

end