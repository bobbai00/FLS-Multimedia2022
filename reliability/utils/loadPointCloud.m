function pointCloud = loadPointCloud(filePath, pointCloudId, isFromPrinceton)

addpath(genpath([pwd, filesep, 'util' ]));

outputT= ['Processing ', filePath ];
disp(outputT);
if ~isFromPrinceton
    [vertexList, minW, maxW, minH, maxH, minD, maxD] = readPLYfile(filePath);
    pointCloud = CloudPoint(pointCloudId,filePath,vertexList,minW,maxW,minH,maxH,minD,maxD);

else
    [vertexList, minW, maxW, minH, maxH, minD, maxD] = readPrincetonFile(filePath);
    for i = 1:size(vertexList, 2)
        vertexList{i}(4) = 128;
        vertexList{i}(5) = 128;
        vertexList{i}(6) = 128;
        vertexList{i}(7) = 255;
    end
    pointCloud = CloudPoint(pointCloudId,filePath,vertexList,minW,maxW,minH,maxH,minD,maxD);
end

end

