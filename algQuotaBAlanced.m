function output = algQuotaBalanced(vertexList, silent, detectConflicts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Implements the QuotaBalanced algorithm.       %
%   Inputs: vertexList, silent, detectConflicts are as follows%
%   vertexList:                                               %
%   Use ReadPrincetonFile.m in cnvPrincetonShapeToPtCloud to  %
%   obtain the MATLAB variable vertexList and provide it as   %
%   input to this implementation.  We do not use a file as    %
%   input to avoid the overhead of disk                       %
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
%   dispatcher to its coordinate intersects another.  Unlike  %
%   minDist, there are potential intersections because the    %
%   flight paths from different dispatchers may be crossing   %
%   one another.                                              %
%                                                             %
%   Identify the number of dispatchers and their location     %
%   using the dispatchers variable below.                     %
%                                                             % 
% Dependencies: distanceCells, distTrigFace.m, surfaceVs      %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dispatcherRate=10; %10 FLSs per second
output=1;

numDispatchers=8;  %4;
dispatchers=zeros(numDispatchers,3);
dispatchers(1,:)=[0,0,0];
dispatchers(2,:)=[100,0,0];
dispatchers(3,:)=[100,0,100];
dispatchers(4,:)=[0,0,100];
dispatchers(5,:)=[0,100,0];
dispatchers(6,:)=[100,100,0];
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


numpoints = size(vertexList,2);
varpi = (numpoints/(numDispatchers*dispatcherRate)) + zeros(numDispatchers,1);
speed = 4; %speed of each FLS in number of cells per second

dispatcherV = [1:numDispatchers];
pointsAssigned = 0;

VertexToDispatcher=zeros(8,1);
VdistanceToDispatcher=zeros(8,1);

dispatcherReset=0;

for v=1:size(vertexList,2)
    min = realmax;
    dtgt=-1;
    for elt=1:size(dispatcherV,2)
        d = dispatcherV(elt);
        deltai = distanceCells(vertexList{v}, dispatchers(d,:));
        if deltai < min
            min = deltai;
            dtgt = d;
        end
    end

    points(dtgt)=points(dtgt)+1; % points is initialized to zero
    VertexToDispatcher(dtgt, points(dtgt))=v;  % register id of vertex
    VdistanceToDispatcher(dtgt, points(dtgt))=min; % and its distance

    distance(dtgt)=distance(dtgt)+min;
    totalDistance=totalDistance+min;
    timeToTravel = min/speed;
    varpi(dtgt)=varpi(dtgt)-timeToTravel;

    pointsAssigned = pointsAssigned+1;

    if varpi(dtgt) <= 0
        %outputT= ['Removing dispatcher ', num2str(dtgt)];
        %disp(outputT);
        dispatcherV=dispatcherV(dispatcherV~=dtgt);
    end

    % If there are no dispatchers then reset quotas and continue
    if isempty(dispatcherV)
        numpoints = numpoints - pointsAssigned;
        dispatcherV = [1:numDispatchers];
        varpi = (numpoints/(numDispatchers*dispatcherRate)) + zeros(numDispatchers,1);
        dispatcherReset = dispatcherReset + 1;
    end
end

if ~silent
    points
    distance
    m=max(points);
    displaytime = m/dispatcherRate;

    outputT= ['Number of vertices = ', num2str(size(vertexList,2))];
    disp(outputT);
    outputT= ['Num of times dispatcher vector is reset = ', num2str(dispatcherReset)];
    disp(outputT);
    outputT= ['Display Time = ', num2str(displaytime), ' Seconds'];
    disp(outputT);
    outputT= ['Total distance = ',num2str(totalDistance), ' Cells'];
    disp(outputT);
end

if detectConflicts
    % dispatcherInternalCrashes(dispatchers,tgtDispatcher,VertexToDispatcher,VdistanceToDispatcher,vertexList);
    shortestPath(dispatchers,VertexToDispatcher,VdistanceToDispatcher,vertexList);
    % dimensionPaths(dispatchers,VertexToDispatcher,VdistanceToDispatcher,vertexList);
end
