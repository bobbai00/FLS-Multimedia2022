function distanceTbl = distTwoPtSetsOPT(srcPts, destPts, leadCloudPoint, derivedCloudPoint)

sz = [ 1 5];
varTypes=["double","int64","int64","int64","int64"];
varNames=["distance","srcVID","destVID","srcCubeid","destCubeid"];
distanceTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
rowindex=0;

finalTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
fTblIDX=0;

if size(srcPts,2) > 0
    for i=1:size(srcPts,2)
        minDistance = intmax;
        destIDX=-1;
        srcP=srcPts{i}(1);
        srcCube=srcPts{i}(2);
        for j=1:size(destPts,2)
            destP=destPts{j}(1);
            destCube=destPts{j}(2);
            dist = distanceCells(cell2mat( leadCloudPoint.vertexList( srcP ) ), cell2mat( derivedCloudPoint.vertexList( destP ) ));
            % Insert the point pair in a table
            rowindex=rowindex+1;
            distanceTbl(rowindex,:)={dist, srcP,destP,srcCube, destCube};
        end
    end
    % Sort the table
    distanceTbl=sortrows(distanceTbl,1,'ascend');
    % Maintain the shortest distance for each destPts

    %for i=1:size(srcPts,2)
    while size(distanceTbl,1) > 0
        tgtDestRow=distanceTbl(1,:);
        fTblIDX=fTblIDX+1;
        finalTbl(fTblIDX,:)=tgtDestRow;

        tgtS=cell2mat( table2cell( tgtDestRow(1,2) ) );
        distanceTbl(distanceTbl.srcVID==tgtS,:)=[];

        tgtD=cell2mat( table2cell( tgtDestRow(1,3) ) );
        %tgtV = table2array( diffTable(1,2) );
        distanceTbl(distanceTbl.destVID==tgtD,:)=[];
    end
end
distanceTbl=finalTbl;
end