function selectionPool = heuristicOnlyCube(cubeList, cubeID, vidToFid)
    
    cube = cubeList(cubeID);
    
    vertices = cube.assignedVertices;

    selectionPool = [];
    for i = 1:size(vertices, 2)
        vid = vertices(i);
        selectionPool(i) = vidToFid(vid);
    end
    
    selectionPool = unique(selectionPool(:).');
end

