function output = workflowMinDist(silent, detectConflicts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  This workflow executes the MinDist algorithm. %
%   It is trival to change this workflow to run the           %
%   QuotaBalanced algorithm (not provided).  Its input are:   %
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
%                                                             % 
% Dependencies: distanceCells, distTrigFace.m, surfaceVs      %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add path to the subfolder containing the cnvPrincetonShapeToPtCld and
% utility functions
addpath(['./cnvPrincetonShapeToPtCloud'])
addpath(['./util'])

PrincetonShapeFile='/Users/flyinglightspec/src/benchmark/db/15/m1559/m1559.off';
PtCldFile = './pt1559.ptcld';

while ~isfile(PrincetonShapeFile)
    prompt = "Provide a valid path to a Princeton Shape file: ";
    PrincetonShapeFile = input(prompt,"s");
end

if isfile(PrincetonShapeFile)
    outputT= ['Convert Princeton Shape file ', PrincetonShapeFile, ' to a point cloud file ', PtCldFile ];
    disp(outputT);

    cnvPrincetonShapeToPtCld(PrincetonShapeFile, PtCldFile);
    [vertexList, minW, maxW, minH, maxH, minD, maxD] = readPrincetonFile(PtCldFile);

    outputT= ['Running algMinDist using ', PtCldFile ];
    disp(outputT);

    algMinDist(vertexList, false, false);

    outputT= ['Success!  MinDist executed successfully. '];
    disp(outputT);
else
    outputT= ['Error, the specified input file ', PrincetonShapeFile, ' does not exist. ' ];
    disp(outputT);
end

end