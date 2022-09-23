function centralizedFramework(filePath, G, pointCloudId)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
doReset = false;
silent = false;

pathPrefix = '/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/TestClip/';
% pathPrefix = '/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/RoseClip/';


filePath = strcat(pathPrefix, filePath);

pointCloud=loadPointCloud(filePath, pointCloudId);

[~,~,~,cubeList] = spaceDivision(pointCloud, G, false);

% debug for cube
% fprintf("\n\n Cubes: \n");
% for i=1:size(cubeList, 2)
%     cube = cubeList(i);
% 
%     fprintf('cube: %d, cardinality: %d, parent: %d, children: [%s]\n', cube.identity, cube.cardinality(), cube.parentID, join(string(cube.childrenIDs), ','));
% end

rootCubeID = 1;

[reliabilityGroups, verticesHaveNoGroup] = centralizedGroupFormation(pointCloud, cubeList, rootCubeID, G);

% if (size(verticesHaveNoGroup, 2) > 0)
%     error("ERROR! There are FLSs that are not being grouped\n");
% end

% debug for groups
% fprintf("\n\n Reliability Groups: \n");
% for i=1:size(reliabilityGroups, 2)
%     group = reliabilityGroups(i);
%     group.calculateDistanceBetweenStandby(pointCloud.vertexList);
%     fprintf('belonging cube id: %d; distance among standby: %f; distance among FLSs: %f\n', group.cubeID, group.distanceBetweenStandby, group.weight);
% end

reportReliabilityGroupStats(reliabilityGroups, pointCloud.vertexList, G);

end

