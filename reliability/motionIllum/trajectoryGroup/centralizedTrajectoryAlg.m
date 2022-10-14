function reliabilityGroups = centralizedTrajectoryAlg(vertexList, cubeList, travelPaths, G1, Delta1, G2, Delta2)
    [motionRCubes, staticRCubes] = generateRCubesForPointClouds(vertexList, cubeList, travelPaths);

    reliabilityGroupForStaticCubes = formGroupForCubesAndNeighbors(vertexList, staticRCubes, G1, Delta1);
    reliabilityGroupForMotionCubes = formGroupForCubesAndNeighbors(vertexList, motionRCubes, G2, Delta2);

    reliabilityGroups = [reliabilityGroupForStaticCubes, reliabilityGroupForMotionCubes];
end