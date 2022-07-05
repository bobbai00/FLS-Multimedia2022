function output = cnvPrincetonShapeToPtCld(PrincetonShapeFileName, pointCloudFileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Converts a shape from the Princeton Benchmark %
%               to a point cloud.  Each point identifies the  %
%               location of an FLS.  The output file is used  %
%               by the MinDist and QuotaBalanced algorithms,  %
%               see algMinDist.m and algQuotaBalanced.m to    %
%               disptach FLSs to illuminate the shape.        %
% Dependencies: distanceCells, distTrigFace.m, surfaceVs      %
% Author: Shahram Ghandeharizadeh                             %
% Date: July 4, 2022                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Include top folder for distanceCells
addpath(genpath([fileparts(pwd), filesep, 'util' ]));

dimRow=true;
vertexCount = [];
faceCount = [];
edgeCount = [];
rowCount = 1;
vertexList{1} = [];
faceList{1} = [];
faceColorList{1} = [];

fileID=fopen(PrincetonShapeFileName);

multiplier=100;

while (~feof(fileID))
    currLine = textscan(fileID,'%s',1,'Delimiter','\n');
    currRow = char(currLine{1});
    splittedRow = strsplit(currRow,' ');

    if (~strcmp(splittedRow(1),'#') && ~strcmp(splittedRow(1),'OFF'))

        splittedRow = str2double(splittedRow);

        if(dimRow)
            dimRow = false;
            vertexCount = splittedRow(1);
            faceCount = splittedRow(2);
            edgeCount = splittedRow(3);
        else
            if(rowCount <= vertexCount)
                vertexList{rowCount} = [splittedRow(1)*multiplier splittedRow(2)*multiplier splittedRow(3)*multiplier];
            end
            if(vertexCount < rowCount && (rowCount-vertexCount) <= faceCount)
                if(splittedRow(1) == 3)
                    faceList{rowCount-vertexCount} = [splittedRow(2) splittedRow(3) splittedRow(4)];
                    % faceColorList{rowCount-vertexCount} = [splittedRow(5) splittedRow(6) splittedRow(7) splittedRow(8)];
                end
                if(splittedRow(1) == 4)
                    faceList{rowCount-vertexCount} = [splittedRow(2) splittedRow(3) splittedRow(4) splittedRow(5)];
                    % faceColorList{rowCount-vertexCount} = [splittedRow(6) splittedRow(7) splittedRow(8) splittedRow(9)];
                end
            end

            rowCount = rowCount +1;

            % progress
            if(mod(rowCount,10000)==0)
                disp('.');
            end
        end
    end
end

disp 'Structure materialized in memory.';
disp '';

for i=1:size(vertexList,2)
    currV = vertexList{i};
end

xCoo = [];
yCoo = [];
zCoo = [];

if size(faceList,2)> 1
  for j=1:size(faceList,2)
    currF = faceList{j};

    for k=1:size(currF,2)
        xCoo = [xCoo vertexList{currF(k)+1}(1)];
        yCoo = [yCoo vertexList{currF(k)+1}(2)];
        zCoo = [zCoo vertexList{currF(k)+1}(3)];
    end
    xCoo = [xCoo xCoo(1)];
    yCoo = [yCoo yCoo(1)];
    zCoo = [zCoo zCoo(1)];

  end
end

fclose(fileID); %Close the input file

%return;

if size(faceList,2) < 2
    disp 'No triangle mesh to reduce to a point cloud.  Returning';
    return;
end

disp 'Generating point cloud';

% The following code implements illumination using FLSs
downWash = 1000; % size of downWash along a dimension in micrometers
displayDimSize = 1000*1000; %Size of a dimension
eltsPerDim = displayDimSize/downWash; %Number of elts per x, y, and z

%An FLS may occupy a cell of the displayGrid declared below
displayGrid = zeros(eltsPerDim,eltsPerDim,eltsPerDim); %Display Grid

%One corner cell of the grid is reserved for the dispatcher.
%Its coordinates are [1,1,1], [1,1,Max], [1,Max,1], [Max,1,1], [1,Max,Max],
%[Max,Max,1], [Max,1,Max], [Max,Max,Max]
Max=eltsPerDim;
dispatcherLocation=[1,1,1];

disp '>> Sort faces based on their distance from the dispatcher.';
%For each face, compute its distance from the dispatcher.  Store in a table.
sz = [ size(faceList,2) 2];
varTypes=["int64","double"];
varNames=["faceid","distance"];
sf = table('Size', sz, 'VariableTypes', varTypes,'VariableNames',varNames);
for j=1:size(faceList,2)
    currF = faceList{j};
    dist = distTrigFace(dispatcherLocation, vertexList{currF(1)+1}, vertexList{currF(2)+1}, vertexList{currF(3)+1});
    sf(j,:)={j,dist};
end

sortedFaces=sortrows(sf,2,'descend'); %Sort in descending distance

disp 'Process sorted faces';

%For each element of sortedFaces, get the shortest distance from the
%dispatcher to its vertices and compute location of its FLSs.
ptCloud=[];
for rowid=1:height(sortedFaces)
    sfaceid = sortedFaces(rowid,1); %This is the faceid
    sdist = sortedFaces(rowid,2); %distance from the dispatcher

    currFaceID=table2array(sfaceid);
    currF = faceList{currFaceID(1)};

    v1x = vertexList{currF(1)+1};
    v1y = vertexList{currF(2)+1}; 
    v1z= vertexList{currF(3)+1};

    pts = surfaceVs(v1x, v1y, v1z, threshold);
    ptCloud = [ptCloud; pts];
    
    if(mod(rowid,10)==0)
        disp('.');
    end
end

disp 'Eliminate duplicate entries from the point Cloud';

% Eliminate duplicate points
ptCloud=unique(ptCloud,'rows');

outputT= ['Generating point cloud file ' pointCloudFileName]
disp(outputT);

% Write the point cloud to a file
fid = fopen(pointCloudFileName,'w');
fprintf(fid,'OFF\n');
fprintf(fid,'%d 0 0 \n',size(ptCloud,1));
for j=1:size(ptCloud,1)
    % The following switch between y and z is intentional
    % It is to accomodate matlab 3D plot used in plotPtCld.m
    fprintf(fid,'%d %d %d\n',ptCloud(j,1), ptCloud(j,3), ptCloud(j,2) );
end

fclose(fid);

end