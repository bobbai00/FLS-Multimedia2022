function [TravelPaths, totalIntraTravelDistance, totalInterTravelDistance, totalIntraFlights, totalInterFlights, ColorChanges] = algInterCubeFirstPTs(diffTable, leadCloudPoint, derivedCloudPoint, sanityChk, silent)
% Verify the input cloud points have the same grid structure on them.
if size(leadCloudPoint.cubes) ~= size(derivedCloudPoint.cubes)
    error('Error, lead and derived cloud points must have the same grid.')
end

immutableDiffTable=diffTable;

% Distance table schema
sz = [ 1 4];
varTypes=["double","int64","int64","int64"];
varNames=["distance","srcVID","destVID","cubeid"];

TPidx=0;
TravelPaths={};

CCidx=0;
ColorChanges={};

% Compute intra-cube position/color/position+color changes
% 1. Identify rows with zero change in number of vertices
% 2. Classify the change for position/color/position+color
% 3. Generate output file
% zeroTable = immutableDiffTable(immutableDiffTable.diffVertices==0,2);
% zeroCubeIDs = table2array( zeroTable(:,1) );

zeroTable = immutableDiffTable(:,2);
zeroCubeIDs = table2array( zeroTable(:,1) );

% Identify which vertex moved?
% Identify which vertex changed color?
deltaIntraPosition = {};
deltaIntraColor = {};
deltaIntraPosCol = {};

totalPosChgs=0;
posVIDs=[];

IntraPositionIDX=0;
IntraColorIDX=0;
IntraPosColIDX=0;

totalIntraCubePosition = 0;
totalIntraCubeColor = 0;
totalIntraCubePosCol = 0;

totalIntraFlights=0;
totalInterFlights=0;

numCollisions = 0;
numIntraCTP=0;
intraCubeTravelPaths = {};
totalIntraTravelDistance=0;
missingPts=[];
%{
for i=1:size(zeroCubeIDs,1) % zeroCubeIDs is a column vector and 1 has the number of vectors
    tgtCubeID=zeroCubeIDs(i);
    tgtCubeID
    [leadColor, derColor, mLD, missingPts] = shiftedPoints(zeroCubeIDs(i), leadCloudPoint, derivedCloudPoint);
    % If size(mLD) equals size(delPts) then delPts is meaningless/discard.

    totalIntraCubePosition = totalIntraCubePosition + size(mLD,2);
    totalIntraCubeColor = totalIntraCubeColor + size(leadColor,2);
    %totalIntraCubePosCol = totalIntraCubePosCol + size(movCol,2);

    if size(leadColor,2) > 0
        if size(leadColor,2) ~= size(derColor,2)
            error('Error, number of points that change colors should be the same in lead and derived cloud points.');
        end
        for k=1:size(leadColor,2)
            % Iterate elements and generate new color paths
            srcPt = leadColor(k);
            destPt = derColor(k);

            leadCloudPoint.replacePoint(tgtCubeID, srcPt, leadCloudPoint.vertexList(srcPt), derivedCloudPoint.vertexList(destPt));

            CCidx=CCidx+1;
            ColorChanges{CCidx}=horzcat(tgtCubeID, srcPt, leadCloudPoint.vertexList( srcPt ), tgtCubeID, destPt, derivedCloudPoint.vertexList(destPt) );
        end
        totalIntraCubeColor = totalIntraCubeColor + size(leadColor,2);
    end

    if size(mLD,2) > 0
        %[derColor, derPts] = shiftedPoints(zeroCubeIDs(i), derivedCloudPoint, leadCloudPoint);

        % Two Policies:
        % 1. Use color to match points of mLD to derPts
        % 2. Compute the shortest distance between earch points of mLD and each point of derPts
        % Assign the point combination that results in the smallest difference.
        %[flightPaths, travelDistance, remPts] = mapPointsShortestDistance(mLD, missingPts, leadCloudPoint, derivedCloudPoint, tgtCubeID, tgtCubeID);
        [flightPaths, travelDistance, remSrcPts, remDestPts] = mapPointsShortestDist2(mLD, missingPts, leadCloudPoint, derivedCloudPoint, tgtCubeID, tgtCubeID);
        % Accept these flightPaths
        for q=1:size(flightPaths,2)
            TPidx=TPidx+1;
            TravelPaths{TPidx}= flightPaths{q};

            numIntraCTP=numIntraCTP+1;
            intraCubeTravelPaths{numIntraCTP} = flightPaths{q};

            srcPt=cell2mat(flightPaths{q}(2));
            leadCloudPoint.replacePoint(tgtCubeID, srcPt, flightPaths{q}(3), flightPaths{q}(6));
        end
        totalIntraFlights = totalIntraFlights + size(flightPaths,2);
        totalIntraTravelDistance = totalIntraTravelDistance + travelDistance;
    end

    if sanityChk
        vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
        zTbl2 = vT2(vT2.diffVertices==0,2);
        zCubes = table2array( zTbl2(:,1) );
        if size(zeroCubeIDs,1)-i ~= size(zCubes,1)
            error('Error, abnormal activity.  Number of cubes with changes increased!?!  This should never happen....')
        end
    end
    % How many collisons are incurred by these travel paths?
end
totalIntraCubePosition
totalIntraCubeColor
totalIntraCubePosCol
totalIntraTravelDistance

if sanityChk
    vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint,silent);
    zTbl2 = vT2(vT2.diffVertices==0,2);
    zCubes = table2array( zTbl2(:,1) );
    if size(zCubes,1) ~=0
        error('Error, expecting zero cubes with intra changes.  Number of cubes with intra changes is ', num2str(size(zCubes,1)))
    end
end
%}

totalInterCubePosition = 0;
totalInterCubeColor = 0;
totalInterCubePosCol = 0;
totalInterTravelDistance = 0;

diffTable(diffTable.diffVertices==0,:)=[];
permDiffTable=diffTable;

done=false;

fPcntr=0;
fP={};

if ~isempty(diffTable)
    terminate=false;
    while ~terminate
        % Pass 2 is as follows:
        % Compute the position of missing points from  cubes that lost FLSs
        cubesWithLostPts = cell2mat( table2cell( diffTable(diffTable.diffVertices>0,2) ) );
        missPts=[];
        addPts=[];

        for i=1:size(cubesWithLostPts)
            lCid=cubesWithLostPts(i);
            [leadColor, derColor, chgPtsWLPT, missPtsWLPT] = shiftedPointsAsCells(lCid, leadCloudPoint, derivedCloudPoint);
            %missPts=[missPts setdiff(missPtsWLPT,missPts)];
            missPts = [missPts missPtsWLPT];

            % NEW
            %addPts = [addPts chgPtsWLPT];
        end

        % Compute the position of add points for cubes that gained FLSs
        cubesWithAddPts = cell2mat( table2cell( diffTable(diffTable.diffVertices<0,2) ) );

        for i=1:size(cubesWithAddPts)
            lCid=cubesWithAddPts(i);
            [leadColor, derColor, chgPtsWA, missPtsWA] = shiftedPointsAsCells(lCid, leadCloudPoint, derivedCloudPoint);
            %addPts=[addPts setdiff(missPtsWA,addPts)];
            addPts=[addPts chgPtsWA];

            % NEW
            %missPts = [missPts missPtsWA];
        end

        % Compute the distance between the two sets and their flight patterns
        if size(missPts,2)>0 && size(addPts,2)>0
            distanceT = distTwoPtSetsOPT(addPts, missPts, leadCloudPoint, derivedCloudPoint);
            distanceT=sortrows(distanceT,1,'ascend');

            done = false;
            %%%diffTable = permDiffTable;
            while ~done
                % Get the first row of distance Table
                % Make it into a flight path
                % Find the impacted cubes in diffTable and adjust their number of
                % missing vertices
                % If diffTable is empty then done is true
                % If permDiffTable is empty then done is true
                tgtDestRow=distanceT(1,:);
                %tgtDestRow=finalTbl(finalTbl.srcVID==primMissingPts(q),:);
                %tgtDestRow=tgtDestRow(1,:);
                dist=cell2mat( table2cell( tgtDestRow(1,1) ) );
                srcPt=cell2mat( table2cell( tgtDestRow(1,2) ) );
                destPt=cell2mat( table2cell( tgtDestRow(1,3) ) );
                tgtCubeID=cell2mat( table2cell( tgtDestRow(1,4) ) );
                cid=cell2mat( table2cell( tgtDestRow(1,5) ) );

                totalInterFlights=totalInterFlights+1;
                totalInterTravelDistance=totalInterTravelDistance+dist;

                TPidx=TPidx+1;
                TravelPaths{TPidx}= horzcat(tgtCubeID, srcPt, derivedCloudPoint.vertexList( srcPt ), cid, destPt, leadCloudPoint.vertexList( destPt ) );

                % Fix the cube as well
                % Remove the old point from the lead cloud and its tgtCubeID
                leadCloudPoint.rmPoint(tgtCubeID, srcPt);

                % Add the point to the lead cloud and its Cube cid
                leadCloudPoint.addPoint(cid, derivedCloudPoint.vertexList( destPt ));

                % Remove this candidate point from the list of candidate.
                distanceT(distanceT.srcVID==srcPt,:)=[];
                distanceT(distanceT.destVID==destPt,:)=[];

                % Adjust the diffTable
                numPts=cell2mat( table2cell( diffTable(diffTable.cubeid==tgtCubeID,1) ) )+1;
                if numPts == 0
                    diffTable(diffTable.cubeid==tgtCubeID,:)=[];
                    distanceT(distanceT.srcCubeid==tgtCubeID,:)=[];
                else
                    diffTable(diffTable.cubeid==tgtCubeID,1)=num2cell(numPts);
                end

                % Adjust the diffTable
                numPts=cell2mat( table2cell( diffTable(diffTable.cubeid==cid,1) ) )-1;
                if numPts == 0
                    diffTable(diffTable.cubeid==cid,:)=[];
                    distanceT(distanceT.destCubeid==cid,:)=[];
                else
                    diffTable(diffTable.cubeid==cid,1)=num2cell(numPts);
                end

                if height(diffTable) == 0
                    done = true;
                elseif height(distanceT) == 0
                    done = true;
                end
            end
        end
        if height(diffTable) == 0
            terminate = true;
        elseif table2array( diffTable(1,1) ) < 0
            terminate = true;
        elseif table2array( diffTable(:,1) ) > 0
            terminate = true;
        end
    end
end

%SHAHRAM:  WE MUST MAKE ONE MORE PASS AND TAKE CARE OF INTRA-CHANGE
%CUBES THAT NOW HAVE INTER-CUBE CHANGES
vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
%zeroTable = vT2(vT2.diffVertices==0,2);
%zeroCubeIDs = table2array( zeroTable(:,1) );

zeroTable = vT2(:,2);
zeroCubeIDs = table2array( zeroTable(:,1) );

for i=1:size(zeroCubeIDs,1) % zeroCubeIDs is a column vector and 1 has the number of vectors
    tgtCubeID=zeroCubeIDs(i);
    [leadColor, derColor, mLD, missingPts] = shiftedPoints(zeroCubeIDs(i), leadCloudPoint, derivedCloudPoint);
    % If size(mLD) equals size(delPts) then delPts is meaningless/discard.

    totalIntraCubePosition = totalIntraCubePosition + size(mLD,2);
    totalIntraCubeColor = totalIntraCubeColor + size(leadColor,2);

    if size(leadColor,2) > 0
        if size(leadColor,2) ~= size(derColor,2)
            error('Error, number of points that change colors should be the same in lead and derived cloud points.');
        end
        for k=1:size(leadColor,2)
            % Iterate elements and generate new color paths
            srcPt = leadColor(k);
            destPt = derColor(k);
            leadCloudPoint.replacePoint(tgtCubeID, srcPt, leadCloudPoint.vertexList(srcPt), derivedCloudPoint.vertexList(destPt))

            CCidx=CCidx+1;
            ColorChanges{CCidx}=horzcat(tgtCubeID, srcPt, leadCloudPoint.vertexList( srcPt ), tgtCubeID, destPt, derivedCloudPoint.vertexList(destPt) );
        end

    end

    if size(mLD,2) > 0
        %[derColor, derPts] = shiftedPoints(zeroCubeIDs(i), derivedCloudPoint, leadCloudPoint);

        % Two Policies:
        % 1. Use color to match points of mLD to derPts
        % 2. Compute the shortest distance between earch points of mLD and each point of derPts
        % Assign the point combination that results in the smallest difference.
        %[flightPaths, travelDistance, remPts] = mapPointsShortestDistance(mLD, missingPts, leadCloudPoint, derivedCloudPoint, tgtCubeID, tgtCubeID);
        [flightPaths, travelDistance, remSrcPts, remDestPts] = mapPointsShortestDist2(mLD, missingPts, leadCloudPoint, derivedCloudPoint, tgtCubeID, tgtCubeID);
        % Accept these flightPaths
        for q=1:size(flightPaths,2)
            TPidx=TPidx+1;
            TravelPaths{TPidx}= flightPaths{q};

            numIntraCTP=numIntraCTP+1;
            intraCubeTravelPaths{numIntraCTP} = flightPaths{q};

            srcPt=cell2mat(flightPaths{q}(2));

            if sanityChk
                srcCube=cell2mat(flightPaths{q}(1));
                if tgtCubeID ~= srcCube
                    [leadColor2, derColor2, mLD2, missingPts2] = shiftedPoints(zeroCubeIDs(i), leadCloudPoint, derivedCloudPoint);
                    error('Error, very strange.  srcCube should be equal to tgtCubeID.  All the assigned vertices are WRONG.')
                end
            end

            leadCloudPoint.replacePoint(tgtCubeID, srcPt, flightPaths{q}(3), flightPaths{q}(6));

        end

        %{
        % Process the remPts 
        if size(remPts,2) > 0
            if size(missingPts,2) > size(mLD,2)
                % remaining points should be provided by the dispatcher
                % Add the point to the leadCloudPoint Vertex List
                for p=1:size(remPts,2)
                    derPt=remPts(p);
                    leadCloudPoint.addPoint(tgtCubeID, derivedCloudPoint.vertexList(derPt));
                end
            else
                % remaining points must fly back to the dispatcher
                for p=1:size(remPts,2)
                    srcPt=remPts(p);
                    leadCloudPoint.rmPoint(tgtCubeID, srcPt);
                end
            end
        end
        %}

        totalIntraFlights=totalIntraFlights+size(flightPaths,2);
        totalIntraTravelDistance = totalIntraTravelDistance + travelDistance;
    end

    if sanityChk
        vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
        zTbl2 = vT2(vT2.diffVertices==0,2);
        zCubes = table2array( zTbl2(:,1) );
        if size(zeroCubeIDs,1)-i ~= size(zCubes,1)
            [leadColor2, derColor2, mLD2, missingPts2] = shiftedPoints(zeroCubeIDs(i), leadCloudPoint, derivedCloudPoint);
            error('Error, abnormal activity.  Number of cubes with changes increased!?!  What is going on....')
        end
    end
    % How many collisons are incurred by these travel paths?
end
totalIntraCubePosition
totalIntraCubeColor
totalIntraCubePosCol
totalIntraTravelDistance

% Fly additional FLSs back to a dispatcher
% Fly new FLSs to the points that remain

% Assume the dispatchers are at the bottom corners of a cuboid
dispatchers=zeros(4,3);
dispatchers(1,:)=[0,0,0];
dispatchers(2,:)=[100,0,0];
dispatchers(3,:)=[100,0,100];
dispatchers(4,:)=[0,0,100];

newFLSs=0;
newFLSDist=0;
vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
cubesToFlyTo = cell2mat( table2cell( vT2(vT2.diffVertices>0,2) ) );
for e=1:size(cubesToFlyTo)
    tgtCubeID=cubesToFlyTo(e);
    [leadColor, derColor, mLD, missingPts] = shiftedPoints(tgtCubeID, leadCloudPoint, derivedCloudPoint);
    % There should be only missingPts
    if size(mLD,2) ~=0
        error('Error, there should be no extra points in the lead Cloud Point; ', num2str(size(mLD,2)))
    end
    for i=1:size(missingPts,2)
        % Compute the shortest distance to a dispatcher
        tgtPt=missingPts(i);
        minDistance = realmax;
        dtgt=-1;
        currV=[derivedCloudPoint.vertexList{ tgtPt }(1), derivedCloudPoint.vertexList{ tgtPt }(2), derivedCloudPoint.vertexList{ tgtPt }(3)];
        for d=1:size(dispatchers,1)
            deltai = distanceCells(currV, dispatchers(d,:));
            if deltai < minDistance
                minDistance = deltai;
                dtgt = d;
            end
        end
        newFLSs = newFLSs + 1;
        newFLSDist = newFLSDist+minDistance;
        % Fly an FLS to the point
        leadCloudPoint.addPoint(tgtCubeID, derivedCloudPoint.vertexList( tgtPt ));

    end
end

% Sanity check is to verify no cubes with point
% changes remain.
if sanityChk
    vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
    zCubes = table2array( vT2(:,1) );
    if size(zCubes,1) ~=0
        error('Error, expecting zero cubes with point changes.  Number of cubes with changes is ', num2str(size(zCubes,1)))
    end
end

outputT= ['Success!  algInterCubeFirstPTs executed successfully.'];
disp(outputT);
outputT= ['Number of color changes (impacted FLSs): ', num2str(size(ColorChanges,2))];
disp(outputT);
outputT= ['Number of flight paths (impacted FLSs): ', num2str(size(TravelPaths,2))];
disp(outputT);
%outputT= ['Number of inter-cube flight paths (impacted FLSs): ', num2str( totalInterFlights )];
outputT= sprintf('\t Number of inter-cube flight paths (impacted FLSs): %d',totalInterFlights);
disp(outputT);
%outputT= ['Number of intra-cube flight paths (impacted FLSs): ', num2str( totalIntraFlights )];
outputT= sprintf('\t Number of intra-cube flight paths (impacted FLSs): %d',totalIntraFlights);
disp(outputT);
outputT= ['Total flight travel distance: ', num2str(totalIntraTravelDistance + totalInterTravelDistance)];
disp(outputT);
outputT= sprintf('\t Total inter-cube travel distance: %3.4f',totalInterTravelDistance);
disp(outputT);
outputT= sprintf('\t Total intra-cube travel distance: %3.4f',totalIntraTravelDistance);
disp(outputT);
outputT= ['Number of new FLSs: ', num2str(newFLSs)];
disp(outputT);
outputT= sprintf('\t Total travel distance: %3.4f',newFLSDist);
disp(outputT);
end