function selectionPool = heuristic(cubeList, cubeID, vidToFid, heuristicToUse, hops)
    
    cube = cubeList(cubeID);
    if cube.isDisabled()
        error("cube should not be disabled when calling this");
    end

    if heuristicToUse == 1
        selectionPool = heuristicOnlyCube(cubeList, cubeID, vidToFid);
    elseif heuristicToUse == 2
        selectionPool = heuristicCubeAndOneNeighbor(cubeList, cubeID, vidToFid);
    else
        selectionPool = heuristicCubeAndNeighborWithHops(cubeList, cubeID, vidToFid, hops);
    end
end
