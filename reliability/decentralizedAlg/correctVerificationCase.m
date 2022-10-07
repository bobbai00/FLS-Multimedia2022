function correctVerificationCase()
    vertexList = {
        [1,   2, 3, 0, 0, 0, 255]
        [1,   2, 3, 0, 0, 0, 255]
        [2,   2, 3, 0, 0, 0, 255]
        [2.0, 2, 3, 0, 0, 0, 255]
        [2.25,2, 3, 0, 0, 0, 255]
    
        [1, 100, 1, 0, 0, 0, 255]
        [1, 100, 2, 0, 0, 0, 255]
        [1, 100, 2, 0, 0, 0, 255]
        [1, 100, 2, 0, 0, 0, 255]
        [1, 100, 3.75, 0, 0, 0, 255]


        [100, 1, 3, 0, 0, 0, 255]
        [100, 2, 3, 0, 0, 0, 255]
        [100, 2, 3, 0, 0, 0, 255]
        [100, 2, 3, 0, 0, 0, 255]
        [100, 4.75, 3, 0, 0, 0, 255]
       };
    
    cubeList = [
        oneCube(1, 3) oneCube(2, 5) oneCube(3, 7)
    ];

%     cubeList(1).assignNeighbor(2);
    cubeList(1).assignNeighbor(3);

%     cubeList(2).assignNeighbor(1);
    cubeList(2).assignNeighbor(3);

    cubeList(3).assignNeighbor(1);
    cubeList(3).assignNeighbor(2);

    for i = 1:15
        v = vertexList{i};
        if i <= 3
            cubeIndex = 1;
        elseif i <= 8
            cubeIndex = 2;
        else
            cubeIndex = 3;
        end

        cubeList(cubeIndex).assignVertex(i, v(1), v(2), v(3), v(4), v(5), v(6), v(7));
    
    end
    G = 3;
    Delta = 0;
    maxRounds = 1000;

    isUsingHeuristic = 1;
    whichTypeOfHeuristicToUse = 1;
    hopsForThirdType = 1;

    totalNumOfPoints = 15;
    scheduler = flsScheduler(isUsingHeuristic, whichTypeOfHeuristicToUse, hopsForThirdType, totalNumOfPoints, maxRounds, 1, G, Delta, cubeList, vertexList);

    scheduler.start();
    
    filePrefix = "results/verifcase/G5D0/heu1";
    
    reportTestCaseStats(filePrefix, scheduler.latestCliqueAtEachRound, G, scheduler.cliqueList);


end
