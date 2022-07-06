function distanceTbl = distTwoPtArraysOPT(srcPts, destPts, leadCloudPoint, derivedCloudPoint)

sz = [ 0 4];
varTypes=["double","int64","int64","int64"];
varNames=["distance","srcVID","destVID","cubeid"];
distanceTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
rowindex=0;

finalTbl = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
fTblIDX=0;

if size(srcPts,2) > 0 && size(destPts,2) > 0
    for i=1:size(srcPts,2)
        %{
        minDistance = intmax;
        destIDX=-1;
        for j=1:size(srcPts,2)
            dist = distanceCells(cell2mat( leadCloudPoint.vertexList( destPts(i) ) ), cell2mat( derivedCloudPoint.vertexList( srcPts(j) ) ));
            if dist < minDistance
                minDistance = dist;
                destIDX=j;
            end
        end
        %}
        % Insert the point pair in a table
        for j=1:size(destPts,2)
            dist = distanceCells(cell2mat( leadCloudPoint.vertexList( srcPts(i) ) ), cell2mat( derivedCloudPoint.vertexList( destPts(j) ) ));
            
            rowindex=rowindex+1;
            distanceTbl(rowindex,:)={dist, srcPts(i), destPts(j),0};
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