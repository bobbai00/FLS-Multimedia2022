function [TravelPaths, totalIntraTravelDistance, totalInterTravelDistance, totalIntraFlights, totalInterFlights, ColorChanges] = algCubeChangeIntRAFirst(diffTable, leadCloudPoint, derivedCloudPoint, sanityChk, silent)
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

totalInterCubePosition = 0;
totalInterCubeColor = 0;
totalInterCubePosCol = 0;
totalInterTravelDistance = 0;


zeroCubeIDs = table2array( immutableDiffTable(:,2) );


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
        if size(remSrcPts,2) > 0 && ~silent
            outputT= sprintf('Warning, remSrcPts remaining.');
            disp(outputT);
        end
        if size(remDestPts,2) > 0 && ~silent
            outputT= sprintf('Warning, remDestPts remaining.');
            disp(outputT);
        end
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

        totalIntraFlights=totalIntraFlights+size(flightPaths,2);
        totalIntraTravelDistance = totalIntraTravelDistance + travelDistance;
    end

    if sanityChk
        vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
        zTbl2 = vT2(vT2.diffVertices==0,2);
        zCubes = table2array( zTbl2(:,1) );
        if size(zeroCubeIDs,1)-i ~= size(zCubes,1)
            [leadColor2, derColor2, mLD2, missingPts2] = shiftedPoints(zeroCubeIDs(i), leadCloudPoint, derivedCloudPoint);
            error('Error, abnormal activity.  Number of cubes with changes increased!?!  Expecting ',num2str(size(zeroCubeIDs,1)-i) ,' observed ',num2str(size(zCubes,1)))
        end
    end
    % How many collisons are incurred by these travel paths?
end



diffTable(diffTable.diffVertices==0,:)=[];
permDiffTable=diffTable;

if ~isempty(diffTable)
    done=false;

    fPcntr=0;
    fP={};
    while ~done
        ptsNotProcessed=0;
        tgtCubeID = table2array( diffTable(1,2) );
        diff = table2array( diffTable(1,1) );
        % Find the cube's points that changed colors and/or position
        [leadColor, derColor, chgPts, primMissingPts] = shiftedPoints(tgtCubeID, leadCloudPoint, derivedCloudPoint);
        numProcessedPts = 0;
        processedPts = [];
        if size(primMissingPts,2) > 0
            % Find those neighbors with missing points, negative vertices
            cv = cell2mat( table2cell( diffTable(diffTable.diffVertices<0,2) ) );

            %if ~silent
            %    size(diffTable)
            %end
            % These are candidate cubes for points if they are neighbors of
            % the current cube
            candidateCubes = intersect(cv,leadCloudPoint.cubes(tgtCubeID).neighbors);
            %if size(candidateCubes,1) > 0
            if ~isempty(candidateCubes)
                %For each cube, find the points that changed color and/or position
                allChgPts=[];

                finalTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
                finalRID = 0;

                for j=1:size(candidateCubes,1)
                    canCubeID=candidateCubes(j);
                    [leadColor, derColor, chgPts, missingPts] = shiftedPoints(canCubeID, leadCloudPoint, derivedCloudPoint);
                    %cubeCandidates=cell2mat( table2cell( diffTable(diffTable.cubeid==canCubeID,1) ) );
                    distanceTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
                    rowindex=0;

                    % NO changes allowed.  Consult with comments in
                    % algCubeChangeInterFirst before even thinking about making
                    % changes

                    if size(chgPts,2) > 0
                        for i=1:size(chgPts,2)
                            minDistance = intmax;
                            destIDX=-1;
                            for j=1:size(primMissingPts,2)
                                dist = distanceCells(cell2mat( leadCloudPoint.vertexList( chgPts(i) ) ), cell2mat( derivedCloudPoint.vertexList( primMissingPts(j) ) ));
                                if dist < minDistance
                                    minDistance = dist;
                                    destIDX=j;
                                end
                            end
                        end
                        rowindex=rowindex+1;
                        distanceTbl(rowindex,:)={minDistance, chgPts(i), primMissingPts(destIDX),canCubeID};
                    end

                    for i=1:rowindex
                        finalRID=finalRID+1;
                        finalTbl(finalRID,:)=distanceTbl(i,:);
                    end
                end
                finalTbl=sortrows(finalTbl,1,'ascend');

                %finalTbl=distTwoPtArraysOPT(chgPts, primMissingPts, leadCloudPoint, derivedCloudPoint);

                tempTPidx=0;
                tempTravelPath={};

                % Iterate points and construct flight paths
                % Do it for the missing points of the tgtCubeID
                for q=1:min(diff,size(primMissingPts,2))
                    if size(finalTbl,1) > 0
                        % Take the first row with minimum distance
                        tgtDestRow=finalTbl(1,:);
                        %tgtDestRow=finalTbl(finalTbl.srcVID==primMissingPts(q),:);
                        %tgtDestRow=tgtDestRow(1,:);
                        dist=cell2mat( table2cell( tgtDestRow(1,1) ) );
                        srcPt=cell2mat( table2cell( tgtDestRow(1,2) ) );
                        destPt=cell2mat( table2cell( tgtDestRow(1,3) ) );
                        cid=cell2mat( table2cell( tgtDestRow(1,4) ) );

                        %Check if srcPt is a member of the primMissingPts
                        if intersect(primMissingPts,srcPt) ~= srcPt
                            error('Error, srcPt is missing:  Sanity check failed.  Time to debug.');
                        end

                        % FLS flys from the cid to tgtCubeID
                        % cid has more elements
                        % tgtCubeID has fewer elements
                        % FLS is at srcPt and its target is destPt
                        % tempTPidx=tempTPidx+1;
                        % tempTravelPath{tempTPidx}=horzcat(cid, destPt, leadCloudPoint.vertexList( destPt ), tgtCubeID, srcPt, derivedCloudPoint.vertexList( srcPt ) );

                        TPidx=TPidx+1;
                        TravelPaths{TPidx}= horzcat(cid, srcPt, leadCloudPoint.vertexList( srcPt ), tgtCubeID, destPt, derivedCloudPoint.vertexList( destPt ) );


                        fPcntr=fPcntr+1;
                        fP{fPcntr} = TravelPaths{TPidx};

                        % Remove the old point from the cid
                        leadCloudPoint.rmPoint(cid, srcPt);

                        % Add the vertex
                        leadCloudPoint.addPoint(tgtCubeID, derivedCloudPoint.vertexList( destPt ));

                        % printout the impacted cube
                        % leadCloudPoint.cubes(tgtCubeID)

                        % Remove the src and dest points from further consideration
                        % If it is not discarded then it will generate
                        % duplicate coordinate
                        finalTbl(finalTbl.srcVID==srcPt,:)=[];
                        finalTbl(finalTbl.destVID==destPt,:)=[];

                        numProcessedPts = numProcessedPts+1;
                        processedPts(numProcessedPts)=srcPt;

                        totalInterFlights=totalInterFlights+1;
                        totalInterTravelDistance = totalInterTravelDistance + dist;

                        % Adjust the diffTable
                        numPts=cell2mat( table2cell( diffTable(diffTable.cubeid==cid,1) ) )+1;
                        if numPts == 0
                            diffTable(diffTable.cubeid==cid,:)=[];
                            permDiffTable(permDiffTable.cubeid==cid,:)=[];
                            finalTbl(finalTbl.cubeid==cid,:)=[];
                        else
                            diffTable(diffTable.cubeid==cid,1)=num2cell(numPts);
                            permDiffTable(permDiffTable.cubeid==cid,1)=num2cell(numPts);
                        end
                    else
                        if ptsNotProcessed == 0
                            ptsNotProcessed = min(diff,size(primMissingPts,2))-q+1;
                        end

                        if ~silent
                            outputT= ['Warning:  algCubeChange exhausted candidate points in FinalTbl with ', num2str(ptsNotProcessed), ' points remaining from the tgtCubeID. The idea is to make a second pass.'];
                            disp(outputT);
                        end

                        % Exit for loop.  No more points will be assigned
                        % by iterating hopelessly.
                        q=min(diff,size(primMissingPts,2));
                    end
                end

            end
        end

        % Remove this row from further consideration for Pass 1 for loop
        diffTable(diffTable.cubeid==tgtCubeID,:)=[];

        % Remove from the permenant diff table if we are done with this cube
        if diff==size(processedPts,2)
            permDiffTable(permDiffTable.cubeid==tgtCubeID,:)=[];
        else
            if ptsNotProcessed > 0
                % Adjust the entry for this cube in permDiffTable
                permDiffTable(permDiffTable.cubeid==tgtCubeID,1)=num2cell(ptsNotProcessed);
                outputT= ['Missing Code:  Points not processed is ', num2str(ptsNotProcessed), '. I think the permtable should be updated here.  At some point these numbers are not useful.  Hence, software is NOT written.  Lets revisit.'];
                disp(outputT);
            end
            outputT= ['Continuation of previous warning:  number of either partially or complete cubes that were not processed is ', num2str(size(permDiffTable,1)-size(diffTable,1)), '. The idea is to make a second pass.'];
            disp(outputT);
        end

        if height(permDiffTable) == 0
            done = true;
        elseif isempty(diffTable)
            done = true;
        elseif table2array( diffTable(1,1) ) < 0
            done = true;
        end
    end
end

if ~silent
    outputT= ['Out of 1st Pass:  number of either partially or complete cubes that were not processed is ', num2str((size(permDiffTable,1)-size(diffTable,1)) + size(diffTable,1)), '. The idea is to make a second pass.'];
    disp(outputT);


    totalInterCubePosition
    totalInterCubeColor
    totalInterCubePosCol
    totalInterTravelDistance
end

%permDiffTable = diffTable;

diffTable = permDiffTable;
if ~isempty(diffTable)
    terminate=false;
    while ~terminate
        % Pass 2 is as follows:
        % Compute the position of missing points from  cubes that lost FLSs
        cubesWithLostPts = cell2mat( table2cell( diffTable(diffTable.diffVertices>0,2) ) );
        missPts=[];
        for i=1:size(cubesWithLostPts)
            lCid=cubesWithLostPts(i);
            [leadColor, derColor, chgPtsWLPT, missPtsWLPT] = shiftedPointsAsCells(lCid, leadCloudPoint, derivedCloudPoint);
            %missPts=[missPts setdiff(missPtsWLPT,missPts)];
            missPts = [missPts missPtsWLPT];
        end

        % Compute the position of add points for cubes that gained FLSs
        cubesWithAddPts = cell2mat( table2cell( diffTable(diffTable.diffVertices<0,2) ) );
        addPts=[];
        for i=1:size(cubesWithAddPts)
            lCid=cubesWithAddPts(i);
            [leadColor, derColor, chgPtsWA, missPtsWA] = shiftedPointsAsCells(lCid, leadCloudPoint, derivedCloudPoint);
            %addPts=[addPts setdiff(missPtsWA,addPts)];
            addPts=[addPts chgPtsWA];
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


%{

%WE MUST MAKE ONE MORE PASS AND TAKE CARE OF INTRA-CHANGE
%CUBES THAT NOW HAVE INTER-CUBE CHANGES
%vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
%vT2=immutableDiffTable;
if sanityChk
    % Must recompute vT2 because the sanity check in the for loop counts
    % the number of elements in VT2, expecting this count to decrease by
    % one in each iteration.
    % immutableDiffTable has
    vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
end
zeroCubeIDs = table2array( immutableDiffTable(:,2) );


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
        if size(remSrcPts,2) > 0
            outputT= sprintf('Error, remSrcPts remaining.');
            disp(outputT);
        end
        if size(remDestPts,2) > 0
            outputT= sprintf('Error, remDestPts remaining.');
            disp(outputT);
        end
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

        totalIntraFlights=totalIntraFlights+size(flightPaths,2);
        totalIntraTravelDistance = totalIntraTravelDistance + travelDistance;
    end

    if sanityChk
        vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
        zTbl2 = vT2(vT2.diffVertices==0,2);
        zCubes = table2array( zTbl2(:,1) );
        if size(zeroCubeIDs,1)-i ~= size(zCubes,1)
            [leadColor2, derColor2, mLD2, missingPts2] = shiftedPoints(zeroCubeIDs(i), leadCloudPoint, derivedCloudPoint);
            error('Error, abnormal activity.  Number of cubes with changes increased!?!  Expecting ',num2str(size(zeroCubeIDs,1)-i) ,' observed ',num2str(size(zCubes,1)))
        end
    end
    % How many collisons are incurred by these travel paths?
end

if ~silent
    totalIntraCubePosition
    totalIntraCubeColor
    totalIntraCubePosCol
    totalIntraTravelDistance
end
%}

%{

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

missingPts=[];
addPts=[];
for i=1:size( leadCloudPoint.cubes, 2 )
    [leadColor, derColor, mLD, mPts] = shiftedPoints(i, leadCloudPoint, derivedCloudPoint);
    %missingPts=missingPts+size(mPts,2);
    %leadPts=leadPts+size(mLD,2);
    missingPts = [missingPts mPts];
    addPts=[addPts mLD];
end

if size(missingPts,2)>0
    [flightPaths, travelDistance, remSrcPts, remDestPts] = mapPointsShortestDist2(addPts, missingPts, leadCloudPoint, derivedCloudPoint, tgtCubeID, tgtCubeID);
    if size(remSrcPts,2) > 0
        outputT= sprintf('Error, remSrcPts remaining.');
        disp(outputT);
    end
    if size(remDestPts,2) > 0
        outputT= sprintf('Error, remDestPts remaining.');
        disp(outputT);
    end
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
    totalIntraFlights=totalIntraFlights+size(flightPaths,2);
    totalIntraTravelDistance = totalIntraTravelDistance + travelDistance;
end

%}


% Sanity check is to verify no cubes with point
% changes remain.
if sanityChk
    vT2 = cmpTwoFrameObjsAccurate(leadCloudPoint, derivedCloudPoint, silent);
    zCubes = table2array( vT2(:,1) );
    if size(zCubes,1) ~=0
        error('Error, expecting zero cubes with point changes.  Number of cubes with changes is ', num2str(size(zCubes,1)))
    end
end

if ~silent
    outputT= ['Success!  algCubeChangeInterFirst executed successfully.'];
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
    %{
    outputT= ['Number of new FLSs: ', num2str(newFLSs)];
    disp(outputT);
    outputT= sprintf('\t Total travel distance: %3.4f',newFLSDist);
    disp(outputT);
    %}
end
end