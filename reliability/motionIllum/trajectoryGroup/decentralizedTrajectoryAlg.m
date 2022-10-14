function reliabilityGroups = decentralizedTrajectoryAlg(filePrefix, vertexList, cubeList, travelPaths, G1, Delta1, G2, Delta2, maxRounds)

    [motionRCubes, staticRCubes] = generateRCubesForPointClouds(vertexList, cubeList, travelPaths);

    flsScheduler = motionFlsScheduler(size(vertexList, 2), 1, G1, Delta1, G2, Delta2, vertexList, staticRCubes, motionRCubes);
    flsScheduler.start();

    reportDecentralizedStats(filePrefix, flsScheduler.latestCliqueAtEachRound, G1);

end