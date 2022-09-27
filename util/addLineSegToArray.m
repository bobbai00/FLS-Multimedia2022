function output = addLineSegToArray(lineArray, ls)
% Iterate the array and identify which line segment contains the point
seg1 = ls.minInclusive;
seg2 = ls.maxExclusive;

% if seg1 == seg2
%     error("Segment should not have equal endpoint")
% end

index = -1;

for i=1:size(lineArray,2)
    min=lineArray(i).minInclusive;
    max=lineArray(i).maxExclusive;
    if (seg1 == min && seg2 == max)
        index = i;
        break;
    end
end

if index == -1
    sz = size(lineArray,2);
    lineArray(sz+1) = ls;
else
    lineArray(index).addCube(ls.cubeIds(1));
end

output=lineArray;
end