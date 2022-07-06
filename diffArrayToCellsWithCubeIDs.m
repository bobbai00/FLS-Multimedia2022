function cellArrayOutput = diffArrayToCellsWithCubeIDs(tgtCubeID, tgtArray)
cellArrayOutput={};
for i=1:size(tgtArray,2)

    cellElt=[];
    cellElt(1,1) = tgtArray(i);
    cellElt(1,2) = tgtCubeID;
    %cellElt={tgtArray(i), tgtCubeID}

    cellArrayOutput{end+1}=cellElt;
end
end