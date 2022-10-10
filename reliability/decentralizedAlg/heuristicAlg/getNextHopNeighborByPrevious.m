function neighborOfNextHop = getNextHopNeighborByPrevious(previousCubeIDs, hops, cubeList, isVisited)
    neighborOfNextHop = [];
    index = 1;
    
    for i = size(previousCubeIDs, 2)
        cubeid = previousCubeIDs(i);
        cube = cubeList(cubeid);

        neighborIDs = cube.neighbors;
        for j = size(neighborIDs, 2)
            nid = neighborIDs(j);
            if ~isVisited(nid)
                neighborOfNextHop(index) = nid;
                index = index + 1;
                isVisited(nid) = 1;
            end
        end
    end

end