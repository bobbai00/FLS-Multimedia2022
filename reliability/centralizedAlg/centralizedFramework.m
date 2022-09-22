function centralizedFramework(filePath,cubeCapacity,pointCloudId)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
doReset = false;
silent = false;

pathPrefix = '/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/RoseClip/';

filePath = strcat(pathPrefix, filePath);

pointCloud=loadPointCloud(filePath, pointCloudId);

pointCloud.createGrid(doReset, silent, cubeCapacity, 0, 0, 0, 0);

[~,~,~,cubes] = spaceDivision(pointCloud, cubeCapacity, false);

for i=1:size(cubes, 2)
    cube = cubes(i);

    fprintf('cube: %d, cardinality: %d, parent: %d, children: [%s]\n', cube.identity, cube.cardinality(), cube.parentID, join(string(cube.childrenIDs), ','));
end

end

