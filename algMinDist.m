function output = algMinDist(vertexList, silent, detectConflicts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Implements the MinDist algorithm. Inputs:     %
%   vertexList:                                               %
%   Use ReadPrincetonFile.m in cnvPrincetonShapeToPtCloud to  %
%   obtain vertexList and provide as input.This implementation%
%   does not use a file as input to avoid the overhead of disk%
%   I/O in order to time the execution of the algorithm.      %
%                                                             %
%   silent: true or false                                     %
%   False if interested in seeing the output.                 %
%   True if timing the execution time.  Output to screen is   %
%   a time consuming operation that will not be performed by  %
%   the orchestrator.                                         %
%                                                             %
%   detectConflicts:  true or false                           %
%   It checks to see if the flight path of the FLSs from a    %
%   dispatcher to its coordinate intersects another.  With    %
%   minDist, there are no such intersections.  It is here only%
%   for sanity check and to verify nothing is out of place.   %
%                                                             %
%   Identify the number of dispatchers and their location     %
%   using the dispatchers variable below.                     %
%                                                             % 
% Dependencies: distanceCells, distTrigFace.m, surfaceVs      %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath([pwd, filesep, 'util' ]));

dispatcherRate=10; %10 FLSs per second
output=1;

dispatchers=zeros(8,3);
dispatchers(1,:)=[0,0,0];
dispatchers(2,:)=[100,0,0];
dispatchers(3,:)=[100,0,100];
dispatchers(4,:)=[100,100,0];
dispatchers(5,:)=[0,0,100];
dispatchers(6,:)=[0,100,0];
dispatchers(7,:)=[0,100,100];
dispatchers(8,:)=[100,100,100];

numDispatchers = size(dispatchers,1);
totalDistance = 0;
distance=zeros(numDispatchers,1);
points=zeros(numDispatchers,1);

dimRow=true;
vertexCount = size(vertexList,2);
faceCount = [];
edgeCount = [];
rowCount = 1;
faceList{1} = [];
faceColorList{1} = [];

multiplier=1;

VertexToDispatcher=zeros(8,1);
VdistanceToDispatcher=zeros(8,1);

for v=1:size(vertexList,2)
    min = realmax;
    dtgt=-1;
    for d=1:numDispatchers
        deltai = distanceCells(vertexList{v}, dispatchers(d,:));
        if deltai < min
            min = deltai;
            dtgt = d;
        end
    end
    points(dtgt)=points(dtgt)+1;
    VertexToDispatcher(dtgt, points(dtgt))=v;  % register id of vertex
    VdistanceToDispatcher(dtgt, points(dtgt))=min; % and its distance

    distance(dtgt)=distance(dtgt)+min;
    totalDistance=totalDistance+min;

end
if ~silent
    points
    distance
    m=max(points);
    outputT= ['Number of vertices = ', num2str(size(vertexList,2))];
    disp(outputT);
    displaytime = m/dispatcherRate;
    outputT= ['Display Time = ', num2str(displaytime), ' Seconds'];
    disp(outputT);
    outputT= ['Total distance = ',num2str(totalDistance), ' Cells'];
    disp(outputT);
end

if detectConflicts
    shortestPath(dispatchers,VertexToDispatcher,VdistanceToDispatcher,vertexList);
    % dimensionPaths(dispatchers,VertexToDispatcher,VdistanceToDispatcher,vertexList);
end

end