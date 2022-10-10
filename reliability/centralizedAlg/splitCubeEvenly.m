function [twoNewCubes, newTgtCube, minDim] = splitCubeEvenly(tgtCube, dimID, vertexList, newCubeID1 ...
    , newCubeID2, cubeCapacity, newEltIdx)
    minVariance = realmax;

    minDim = 0;

    for dim = 1:3
        copyOfTarget = oneCube(tgtCube.identity, tgtCube.maxVertices);
        copyOfTarget.widthLineSegment = tgtCube.widthLineSegment;
        copyOfTarget.heightLineSegment = tgtCube.heightLineSegment;
        copyOfTarget.depthLineSegment = tgtCube.depthLineSegment;
        copyOfTarget.assignedVertices = tgtCube.assignedVertices;
        copyOfTarget.numVertices = tgtCube.numVertices;
        copyOfTarget.numNeighbors = tgtCube.numNeighbors;
        copyOfTarget.neighbors = tgtCube.neighbors;
        copyOfTarget.colorCheckSum = tgtCube.colorCheckSum;
        copyOfTarget.positionCheckSum = tgtCube.positionCheckSum;
        [twoCube, nt] = splitCube(copyOfTarget, dim, vertexList, newCubeID1, newCubeID2, cubeCapacity, newEltIdx);
        varForDim = var([twoCube(1).cardinality(), twoCube(2).cardinality()]);
        if varForDim < minVariance
            minVariance = varForDim;
            twoNewCubes = twoCube;
            newTgtCube = nt;
            minDim = dim;
        end
    end
end