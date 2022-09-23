function pointCloud = loadPointCloud(filePath, pointCloudId)

addpath(genpath([pwd, filesep, 'util' ]));

outputT= ['Processing ', filePath ];
disp(outputT);
[vertexList, minW, maxW, minH, maxH, minD, maxD] = readPLYfile(filePath);
pointCloud = CloudPoint(pointCloudId,filePath,vertexList,minW,maxW,minH,maxH,minD,maxD);
end

