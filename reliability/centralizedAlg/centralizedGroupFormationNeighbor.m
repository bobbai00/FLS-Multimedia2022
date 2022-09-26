function reliabilityGroups = centralizedGroupFormationNeighbor(pointCloud, cubes, G, Delta)

lowerBound = G-Delta;
upperBound = G+Delta;
vertexList = pointCloud.vertexList;

unqualifiedCubeIndexList = [];
reliabilityGroups = [];

cubeIDsForBuildingGroups = {};
for i = 1:size(cubes, 2)
    cube = cubes(i);
    numVertex = cube.numVertices;
    
    if cube.isDisabled()
        continue;
    end
    % if cube has number of vertices within [G-Delta, G+Delta]
    if numVertex >= lowerBound && cube.numVertices <= upperBound
        group = gfStandbyFirst(cube, upperBound, pointCloud.vertexList);
        reliabilityGroups = [reliabilityGroups, group];
        cubes(i).disable();
    else
        unqualifiedCubeIndexList = [unqualifiedCubeIndexList, [i;numVertex]];
    end    
end

if size(unqualifiedCubeIndexList, 2) == 0
    return;
end

sortedUnqualifiedCubeIndexList = sortrows(unqualifiedCubeIndexList', 2)';

for i = 1:size(sortedUnqualifiedCubeIndexList, 2)
    cubeID = sortedUnqualifiedCubeIndexList(1, i);
    uc = cubes(cubeID);
    if uc.isDisabled()
        continue;
    end
    idsCanBeMerged = bfsCubeNeighbors(cubeID, cubes, lowerBound);
    
    if size(idsCanBeMerged, 2) == 0
        fprintf("Thinking about adjust the lowerBound, current LB is %d, numVertices of this cube is %d\n", lowerBound, uc.numVertices);
        group = reliabilityGroup(cubeID, G, uc.assignedVertices, vertexList);
        reliabilityGroups = [reliabilityGroups, group];
    else
        newCube = mergeCubes(cubes, idsCanBeMerged, vertexList);
        cubes(newCube.identity) = newCube;
        group = reliabilityGroup(newCube.identity, G, newCube.assignedVertices, vertexList);
        reliabilityGroups = [reliabilityGroups, group];
    end
end
end

