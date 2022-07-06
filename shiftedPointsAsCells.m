function [leadColorCells, derColorCells, modPtsCells, missingPtsCells] = shiftedPointsAsCells(tgtCubeID, srcCloudPoint, destCloudPoint)
%This function is the same as shiftedPoints where its output is formatted
%differently
[leadColor, derColor, modPts, missingPts] = shiftedPoints(tgtCubeID, srcCloudPoint, destCloudPoint);

%Convert each entry into of these arrays into cells.
leadColorCells = diffArrayToCellsWithCubeIDs(tgtCubeID, leadColor);
derColorCells = diffArrayToCellsWithCubeIDs(tgtCubeID, derColor);
modPtsCells = diffArrayToCellsWithCubeIDs(tgtCubeID, modPts);
missingPtsCells = diffArrayToCellsWithCubeIDs(tgtCubeID, missingPts);
end