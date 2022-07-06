function [flightPaths, totalDistance, remSrcPts, remDestPts] = mapPointsShortestDist2(srcPts, destPts, leadCloudPoint, derivedCloudPoint, srcCubeID, destCubeID)
% This heuristic maps computes all possible pairing of srcPoints
% with destPoint.  It selects the pairing that results in shortest
% distance.

% output is an array of srcPoints/FLSs
% Each array entry has the srcPoint vertex id
% This array entry has two positions.  One from the srcFrame and
% a second from the derived frame.

%{
if size(srcPts,2) > size(destPts,2)
    error('Error in mapPointsShortestDistance.  The src has fewer points than dest points/FLSs.  This is not acceptable.')
end
%}

% Performance consideration:  Should the points be sorted along a
% dimension?

% The resulting schema is ["distance","srcVID","destVID","srcCubeid","destCubeid"];
distT = distTwoPtArraysOPT(srcPts, destPts, leadCloudPoint, derivedCloudPoint);
flightPaths={};

totalDistance=0;
remSrcPts=srcPts;
remDestPts=destPts;
if ~isempty(distT)
    pathIDX=0;
    done = false;

    for i=1:size(distT,1)
        tgtDestRow=distT(i,:);

        % tgtDestRow

        dist = cell2mat( table2cell( tgtDestRow(1,1) ) );
        srcPt=cell2mat( table2cell( tgtDestRow(1,2) ) );
        destPt=cell2mat( table2cell( tgtDestRow(1,3) ) );

        pathIDX = pathIDX + 1;
        flightPaths{pathIDX}=horzcat(srcCubeID, srcPt, leadCloudPoint.vertexList( srcPt ), destCubeID, destPt, derivedCloudPoint.vertexList( destPt ) );

        totalDistance = totalDistance + dist;

        remSrcPts = remSrcPts(remSrcPts ~= srcPt);
        remDestPts = remDestPts(remDestPts ~= destPt);
    end
end
end