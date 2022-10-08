function [twoNewCubes, newTgtCube, minDim] = splitCubeEvenly(tgtCube, dimID, vertexList, newCubeID1 ...
    , newCubeID2, cubeCapacity, newEltIdx)
    minVariance = realmax;

    minDim = 0;
    for dim = 1:3
        [twoCube, nt] = splitCube(tgtCube, dim, vertexList, newCubeID1, newCubeID2, cubeCapacity, newEltIdx);
        varForDim = var([twoCube(1).cardinality(), twoCube(2).cardinality()]);
        if varForDim < minVariance
            minVariance = varForDim;
            twoNewCubes = twoCube;
            newTgtCube = nt;
            minDim = dim;
        end
    end
end