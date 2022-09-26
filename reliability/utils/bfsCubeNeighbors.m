function cubeIndexListToBeMerged = bfsCubeNeighbors(cubeID, cubes, threshold)
    cubeIndexListToBeMerged = [];
    
    c = cubes(cubeID);
    if c.isDisabled() 
        return;
    end
    
    q = queue();

    q = q.pushBack(cubeID);
    
    sumOfPoints = 0;
    
    isVisited = zeros(1, size(cubes, 2));
    

    while ~q.isEmpty()
        tid = q.front();
        q = q.pop();
        cube = cubes(tid);
        
        if isVisited(tid) || cube.isDisabled()
            isVisited(tid) = 1;
            continue;
        end

        isVisited(tid) = 1;
        
        sumOfPoints = sumOfPoints + cube.numVertices;
        cubeIndexListToBeMerged = [cubeIndexListToBeMerged, tid];
        if sumOfPoints >= threshold
            break;
        end

        neighborIDs = cube.neighbors;
        neighborIDsWithNumVertices = [];

        for i = 1:size(neighborIDs, 2)
            cid = neighborIDs(i);
            nc = cubes(cid);
            
            if nc.isDisabled()
                continue;
            end
            neighborIDsWithNumVertices = [neighborIDsWithNumVertices, [cid;nc.numVertices]];
        end

        if size(neighborIDsWithNumVertices, 2) == 0
            continue;
        end
        
        sortedNeighborIDs = sortrows(neighborIDsWithNumVertices', 2)';
        
        for i = 1:size(sortedNeighborIDs, 2)
            nid = sortedNeighborIDs(1, i);
            q = q.pushBack(nid);
        end
    end

    if sumOfPoints < threshold
        cubeIndexListToBeMerged = [];
    end
end

