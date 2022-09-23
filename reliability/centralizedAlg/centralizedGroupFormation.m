function [reliabilityGroups, verticesHaveNoGroup] = centralizedGroupFormation(pointCloud, cubeList, currentCubeID, G)

vertexList = pointCloud.vertexList;
cube = cubeList(currentCubeID);

verticesHaveNoGroup = cube.assignedVertices;
reliabilityGroups = [];

if (cube.hasChildren())
    childrenIDs = cube.childrenIDs;
    
    for i = 1:size(childrenIDs, 2)
        cid = childrenIDs(i);
        [rg, uv] = centralizedGroupFormation(pointCloud, cubeList, cid, G);
        reliabilityGroups = [reliabilityGroups, rg];
        verticesHaveNoGroup = [verticesHaveNoGroup, uv];
    end
end

% update cube
cube = cube.updateVerticesFromChildren(verticesHaveNoGroup, vertexList);

if (cube.numVertices < G && cube.parentID ~= -1)
    return;
end

% [rg, verticesHaveNoGroup] = gfGroupFirstBruteForce(cube, G, vertexList);
[rg, verticesHaveNoGroup] = gfStandbyFirst(cube, G, vertexList);

reliabilityGroups = [reliabilityGroups, rg];
end

