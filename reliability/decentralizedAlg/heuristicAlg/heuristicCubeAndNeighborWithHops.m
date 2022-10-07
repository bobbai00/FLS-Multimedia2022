function selectionPool = heuristicCubeAndNeighborWithHops(cubeList, cubeID, vidToFid, hopThreshold)
    selectionPool = [];

    cube = cubeList(cubeID);
    
    neighborsCubeIDs = cube.neighbors;

    isVisited = zeros(1, size(cubeList, 2), 'int8');
    isEnqueued = zeros(1, size(cubeList, 2), 'int8');
    hops = zeros(1, size(cubeList, 2), 'int32');

    q = queue();

    q = q.pushBack(cubeID);
    isEnqueued(cubeID) = 1;
    % doing a bfs
    while ~q.isEmpty()
        tid = q.front();
        q = q.pop();
        cube = cubeList(tid);

        if isVisited(tid) || cube.isDisabled()
            isVisited(tid) = 1;
            continue;
        end

        isVisited(tid) = 1;
        hop = hops(tid);

        if hop > hopThreshold
            continue;
        end


        
        vertices = cube.assignedVertices;
        for i = 1:size(vertices, 2)
            vid = vertices(i);
            fid = vidToFid(vid);
            selectionPool = [selectionPool, fid];
        end

        neighborIDs = cube.neighbors;

        for i = 1:size(neighborIDs, 2)
            nid = neighborIDs(i);
            
            if ~isEnqueued(nid)
                q = q.pushBack(nid);
                hops(nid) = hop + 1;
                isEnqueued(nid) = 1;
            end
        end
    end

    selectionPool = unique(selectionPool(:).');
end

