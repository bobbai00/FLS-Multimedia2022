function [motionRCubes, staticRCubes] = generateRCubesForPointClouds(vertexList, cubeList, travelPaths)

    motionRCubes = [];
    motionIndex = 1;

    staticRCubes = [];
    staticIndex = 1;
    index = 1;

    cidToMid = containers.Map('KeyType','int32','ValueType','int32');
    cidToSid = containers.Map('KeyType','int32','ValueType','int32');

    for i = 1:size(travelPaths, 2)
        tp = travelPaths{i};
        srcCid = tp(1);
        
        if isKey(cidToMid, srcCid) || isKey(cidToSid, srcCid)
            continue;
        end
        
        motionRc = reliabilityCube(index, cubeList, srcCid, 1, travelPaths, []);
        motionRCubes(motionIndex) = motionRc;
        motionIndex = motionIndex + 1;
        cidToMid(srcCid) = motionRc.identity;
        index = index + 1;
    
        staticRc = motionRc.getStaticReliabilityCube(index, cubeList);
        staticRCubes(staticIndex) = staticRc;
        staticIndex = staticIndex + 1;
        cidToSid(srcCid) = staticRc.identity; 
        index = index + 1;
    end

    for i = 1:size(cubeList, 2)
        cube = cubeList(i);
        cubeID = cube.identity;

        if isKey(cidToMid, cubeID) || isKey(cidToSid, cubeID)
            continue;
        end

        staticRc = reliabilityCube(index, cubeList, cubeID, 0, {}, cube.assignedVertices);
        staticRCubes(staticIndex) = staticRc;
        staticIndex = staticIndex + 1;

        cidToSid(srcCid) = staticRc.identity; 
        index = index + 1;
    end

    % set neighbors separately for motion rcubes and static rcubes
    motionRCubes = setNeighborForRCubes(motionRCubes);
    staticRCubes = setNeighborForRCubes(staticRCubes);
end