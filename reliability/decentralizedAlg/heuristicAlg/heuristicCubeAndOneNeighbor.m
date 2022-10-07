function selectionPool = heuristicCubeAndOneNeighbor(cubeList, cubeID, vidToFid)
    selectionPool = [];
    selectionPool = [selectionPool, heuristicOnlyCube(cubeList, cubeID, vidToFid)];

    cube = cubeList(cubeID);
    
    neighborsCubeIDs = cube.neighbors;

    neighborIdWithNumberOfFLSs = [];
    for i = 1:size(neighborsCubeIDs, 2)
        neighborCubeID = neighborsCubeIDs(i);
        neighborCube = cubeList(neighborCubeID);

        if neighborCube.isDisabled()
            continue;
        end
        
        neighborIdWithNumberOfFLSs = [neighborIdWithNumberOfFLSs, [neighborCubeID;neighborCube.numVertices]];
    end
    
    sortedNeighborIDsWithNumberOfFLSs = sortrows(neighborIdWithNumberOfFLSs', 2)';
    
    neighborIDWithFewestNumberOfFLSs = sortedNeighborIDsWithNumberOfFLSs(1, 1);
    
    neighborWithFewestNumberOfFLSs = cubeList(neighborIDWithFewestNumberOfFLSs);
    
    vertices = neighborWithFewestNumberOfFLSs.assignedVertices;
    for i = 1:size(vertices, 2)
        vid = vertices(i);
        fid = vidToFid(vid);

        selectionPool = [selectionPool, fid];
    end

    selectionPool = unique(selectionPool(:).');
end

