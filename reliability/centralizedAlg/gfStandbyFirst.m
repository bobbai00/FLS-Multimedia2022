function [reliabilityGroups, verticesHaveNoGroup] = gfStandbyFirst(cube, G, vertexList)

reliabilityGroups = [];
verticesHaveNoGroup = [];

if size(cube.assignedVertices, 2) == 0
    return;
end
% pick the coordinate of standby first
coordinateOfStandby = findCenterCoordinate(cube.widthLineSegment, cube.heightLineSegment, cube.depthLineSegment);
verticesWithDistance = [];

locationOfStandby = [coordinateOfStandby(1), coordinateOfStandby(2), coordinateOfStandby(3)];
for i=1:size(cube.assignedVertices, 2)
    indexOfV = cube.assignedVertices(i);
    coordinateOfV = vertexList{indexOfV};
    locationOfV = [coordinateOfV(1), coordinateOfV(2), coordinateOfV(3)];

    distBetweenVandStandby = pdist([locationOfV;locationOfStandby]);
    verticesWithDistance = [verticesWithDistance, [indexOfV;distBetweenVandStandby]];
end

sortedVerticesWithDistance = sortrows(verticesWithDistance', 2)';

groupedFLSIndexList = [];

dist = 0.0;
for i=1:size(sortedVerticesWithDistance, 2)
    p = sortedVerticesWithDistance(1, i);
    distance = sortedVerticesWithDistance(2, i);
    if (i <= G || cube.parentID == -1)
        groupedFLSIndexList(i) = p;
        dist = dist + distance;
    else
        verticesHaveNoGroup = [verticesHaveNoGroup, p];
    end
end

group = reliabilityGroup(cube.identity, G, groupedFLSIndexList, vertexList);
group.totalStandbyFlsFlyingDistance = dist;
group.standbyFLSCoordinate = coordinateOfStandby;
reliabilityGroups = group;
end

