function output = cmpTwoFrameObjsAccurate(leadFrame, tgtDerivedFrame, silent)
% Identify number of cube elements that are different
numDiffCubes = 0;
diffCubes=[];
numPointsImpacted=0;

numDupsLead=0;
numDupsDer=0;

% Make a 1st pass, detect cubes that are different and make sure they are
% duplicate free
for i=1:size(leadFrame.cubes,2)
    cubeDiff = abs( leadFrame.cubes(i).numVertices - tgtDerivedFrame.cubes(i).numVertices );
    if leadFrame.cubes(i).numVertices == tgtDerivedFrame.cubes(i).numVertices && leadFrame.cubes(i).colorCheckSum == tgtDerivedFrame.cubes(i).colorCheckSum && leadFrame.cubes(i).positionCheckSum == tgtDerivedFrame.cubes(i).positionCheckSum
    else
        nd = leadFrame.cubes(i).removeDups(leadFrame.vertexList);
        numDupsLead= numDupsLead+nd;
        nd = tgtDerivedFrame.cubes(i).removeDups(tgtDerivedFrame.vertexList);
        numDupsDer= numDupsDer+nd;
    end
end

fcnt=0;
falseNeg=[];
% Make a 2nd pass to detect cubes that are different using their checksum
for i=1:size(leadFrame.cubes,2)
    cubeDiff = abs( leadFrame.cubes(i).numVertices - tgtDerivedFrame.cubes(i).numVertices );
    if leadFrame.cubes(i).numVertices == tgtDerivedFrame.cubes(i).numVertices && leadFrame.cubes(i).colorCheckSum == tgtDerivedFrame.cubes(i).colorCheckSum && leadFrame.cubes(i).positionCheckSum == tgtDerivedFrame.cubes(i).positionCheckSum
        fcnt=fcnt+1;
        falseNeg(fcnt)=i;
    else
        numDiffCubes = numDiffCubes + 1;
        diffCubes(numDiffCubes) = i;
        numPointsImpacted = numPointsImpacted + cubeDiff;
    end
end

%Make a 3rd pass of the false negative candidates and see if they are
%different
for i=1:fcnt
    tgtCubeID=falseNeg(fcnt);
    [leadColor, derColor, mLD, missingPts] = shiftedPoints(tgtCubeID, leadFrame, tgtDerivedFrame);
    if size(leadColor,2)>0 || size(derColor,2)>0  || size(mLD,2)>0 || size(missingPts,2)>0
        numDiffCubes = numDiffCubes + 1;
        diffCubes(numDiffCubes) = falseNeg(fcnt);
    end
end

diffNumV = abs( leadFrame.numVertices - tgtDerivedFrame.numVertices );

if ~silent
    outputT= ['Difference in TOTAL number of verticies = ', num2str(diffNumV) ];
    disp(outputT);
    outputT= ['# of Cubes with different number of vertices = ', num2str(numDiffCubes) ];
    disp(outputT);
    outputT= ['TOTAL number of verticies impacted across cubes = ', num2str(numPointsImpacted) ];
    disp(outputT);
end

if numDiffCubes > 0
    for i=1:numDiffCubes
        cid = diffCubes(i);
        % valdiff = abs( leadFrame.cubes(cid).numVertices - tgtDerivedFrame.cubes(cid).numVertices );
        valdiff = leadFrame.cubes(cid).numVertices - tgtDerivedFrame.cubes(cid).numVertices;
        if ~silent
        outputT= ['Difference = ', num2str(valdiff), ' Cube = ', num2str(diffCubes(i)), ' has ', num2str(leadFrame.cubes(diffCubes(i)).numVertices), ' elements from file 1 and ', num2str(tgtDerivedFrame.cubes(diffCubes(i)).numVertices),' elements from file 2.'];
        disp(outputT);
        end
    end
end

numelts = numDiffCubes;
sz = [ numelts 4];
varTypes=["int64","int64","int64","int64"];
varNames=["diffVertices","cubeid","LeadFVertices","DerivedFVertices"];
diffTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
for i=1:numelts
    cid = diffCubes(i);
    % valdiff = abs( leadFrame.cubes(cid).numVertices - tgtDerivedFrame.cubes(cid).numVertices );
    valdiff = tgtDerivedFrame.cubes(cid).numVertices - leadFrame.cubes(cid).numVertices;
        
    diffTbl(i,:)={valdiff,cid, leadFrame.cubes(cid).numVertices, tgtDerivedFrame.cubes(cid).numVertices};
end
output=sortrows(diffTbl,1,'descend'); %Sort in descending difference

if ~silent
    outputT= ['Number of duplicates in lead cloud point = ', num2str(numDupsLead) ];
    disp(outputT);
    outputT= ['Number of duplicates in derived cloud point = ', num2str(numDupsDer) ];
    disp(outputT);
end
end