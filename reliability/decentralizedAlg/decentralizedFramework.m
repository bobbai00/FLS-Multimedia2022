function decentralizedFramework()

doReset = false;
silent = false;

MTTFofFlsInMinute = 6000.0; %minutes
MTTRofFlsInMinute = 1 / 60; %minutes
% pathPrefix = '/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/TestClip/';
pathPrefix = '/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/PrincetonClip/';
% pathPrefix = '/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/RoseClip/';

pointCloudName = "pt1510.ptcld";
filePath = strcat(pathPrefix, pointCloudName);
isFromPrinceton = 1;
G = 20;
Delta = 0;
pointCloudId = 1;
T = 2*G;

pointCloud=loadPointCloud(filePath, pointCloudId, isFromPrinceton);

fprintf("Test FilePath: %s\n", filePath);
fprintf("Number of illuminating FLSs in a group: %d\n", G)
fprintf("GroupFormationAlgorithm: centralized, StandbyFirstDynamicGAlgorithm\n");
startTime = datetime('now');

[~,~,~,cubeList] = spaceDivision(pointCloud, T, false);

spaceDivisionFinishTime = datetime('now');

% debug for cube
% fprintf("\n\n Cubes: \n");

pointInTotal = 0;
cardIndex = 0;
for i=1:size(cubeList, 2)
    cube = cubeList(i);
    if ~cube.isDisabled()
        cardinalityArr(cardIndex+1) = cube.cardinality();
        cardIndex = cardIndex+1;
        pointInTotal = pointInTotal + cube.cardinality();
    end
    % fprintf('cube: %d, cardinality: %d, parent: %d, children: [%s]\n', cube.identity, cube.cardinality(), cube.parentID, join(string(cube.childrenIDs), ','));
end

fprintf("total cardinality: %d\n", pointInTotal);
% drawHistogramForCube(cardinalityArr, pointCloudName, T);
% histForCubeCardinality = drawHistogram(cardinalityArr, "histogram of cubes' cardinality", 'cardinality of cube', 'count of cubes');

% schedulerForTenRounds = flsScheduler(1, 1000, 10, 1, G, cubeList, pointCloud.vertexList);
% schedulerForTenRounds.start();

maxRounds = 150;
isUsingCubePriority = 1;
M = 15;
isUsingHeuristic = 1;
whichTypeOfHeuristicToUse = 2;
hopsForThirdType = 1;
resultFilePrefix = "/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/reliability/decentralizedAlg/results/race-car-1510/heuristic3/heuristic-T40-G20-D0-R150-M15";

totalNumOfPoints = pointInTotal;

scheduler = flsScheduler(isUsingCubePriority, M, isUsingHeuristic, whichTypeOfHeuristicToUse, hopsForThirdType, totalNumOfPoints, maxRounds, 1, G, Delta, cubeList, pointCloud.vertexList);
scheduler.start();
% 
% schedulerFor20Rounds = flsScheduler(1, 1000, 20, 1, G, cubeList, pointCloud.vertexList);
% schedulerFor20Rounds.start();
reportDecentralizedStats(resultFilePrefix, scheduler.latestCliqueAtEachRound, G);


% rootCubeID = 1;
% 
% groupFormationStartTime = datetime('now');
% % [reliabilityGroups, verticesHaveNoGroup] = centralizedGroupFormation(pointCloud, cubeList, rootCubeID, G);
% reliabilityGroups = centralizedGroupFormationNeighbor(pointCloud, cubeList, G, Delta);
% 
% % debug for groups
% % fprintf("\n\n Reliability Groups: \n");
% % for i=1:size(reliabilityGroups, 2)
% %     group = reliabilityGroups(i);
% %     fprintf('belonging cube id: %d; number of FLSs in it: %d\n', group.cubeID, size(group.assignedFLSs, 2));
% % end
% groupFormationEndTime = datetime('now');
% 
% 
% reportReliabilityGroupStats(reliabilityGroups, pointCloud.vertexList, G, MTTFofFlsInMinute, MTTRofFlsInMinute);
% 
% % print time statistics
% fprintf("space division start time: %s\n", datetime(startTime));
% fprintf("space division finish time: %s\n", datetime(spaceDivisionFinishTime));
% fprintf("group formation start time: %s\n", datetime(groupFormationStartTime));
% fprintf("group formation finish time: %s\n", datetime(groupFormationEndTime));
% spaceDivisionTimeInSeconds = seconds(spaceDivisionFinishTime - startTime);
% groupFormationTimeInSeconds = seconds(groupFormationEndTime - groupFormationStartTime);
% overallTimeInSeconds = seconds(spaceDivisionFinishTime - startTime + groupFormationEndTime - groupFormationStartTime);
% fprintf("Overall time consumption: %f seconds\nSpace Division Time: %f seconds\nGroup Formation Time: %f seconds\n", overallTimeInSeconds, spaceDivisionTimeInSeconds, groupFormationTimeInSeconds);

end

