function [llArray, hlArray, dlArray, cubes] = spaceDivision(pointCloud, cubeCapacity, silent)

addpath(genpath([pwd, filesep, 'classes' ]));
addpath(genpath([pwd, filesep, 'util' ]));

maxCardinality=3;
if cubeCapacity < maxCardinality
    outputT= ['Maximum cardinality of a cube must at least ', num2str(maxCardinality), '. ', num2str(cubeCapacity), ' was specified as input.  Change it to 5 or higher.'];
    disp(outputT);
end

maxL = pointCloud.maxL;
maxH = pointCloud.maxH;
maxD = pointCloud.maxD;
minL = pointCloud.minL;
minH = pointCloud.minH;
minD = pointCloud.minD;

if ~silent
    outputT= [' Length = [', num2str(minL), ', ', num2str(maxL), ']' ];
    disp(outputT);
    outputT= [' Height = [', num2str(minH), ', ', num2str(maxH), ']' ];
    disp(outputT);
    outputT= [' Depth = [', num2str(minD), ', ', num2str(maxD), ']' ];
    disp(outputT);
end

cubeID=1;

% Here is the first cube for the entire point set.
o1=oneCube(cubeID,cubeCapacity);

o1.widthLineSegment=[0.0,maxL+1.0];
o1.heightLineSegment=[0.0,maxH+1.0];
o1.depthLineSegment=[0.0,maxD+1.0];

cubes(cubeID) = o1;

% Construct array of line segments for the first cube
llArray=lineSegment(0,maxL+1);
hlArray=lineSegment(0,maxH+1);
dlArray=lineSegment(0,maxD+1);

% Initialize all line segments with cube id 1
llArray(1).addCube(cubeID);
hlArray(1).addCube(cubeID);
dlArray(1).addCube(cubeID);


%Process and 
for i=1:size(pointCloud.vertexList,2)
    currV = pointCloud.vertexList{i};
    % Identify the cube that should hold this vertex using set intersection
    tgtCubeID = findCube(llArray, hlArray, dlArray, currV);
    % Check to see if the target cube overflows.  If so then split the cube
    tgtCube = cubes(tgtCubeID);
    if tgtCube.isDisabled()
        continue;
    end
    if tgtCube.isFull()
        % Construct the new cubeID
        cubeID = cubeID + 1;
        newCubeID1 = cubeID;
        cubeID = cubeID + 1;
        newCubeID2 = cubeID;
        % Dimension to split along
        dimID = mod(cubeID-1, 3)+1;
        % Split the cube into two to obtain a new object
        [twoCube, newTgtCube] = splitCube(tgtCube, dimID, pointCloud.vertexList, newCubeID1, newCubeID2, cubeCapacity, i);
        tgtCube = newTgtCube;
        % Repair the cubeArray
        cubes(twoCube(1).identity)=twoCube(1);
        cubes(twoCube(2).identity)=twoCube(2);
        cubes(tgtCube.identity)=newTgtCube;

        % Fix the line segments
        if dimID == 1
            % Find the index of the impacted line segment
            remlSegIdx = findLineSegIDX(llArray, tgtCube.widthLineSegment(1), tgtCube.widthLineSegment(2));
            remlSeg = llArray(remlSegIdx);

            % Remove it from the wlArray if this is the only line segment
            if size(remlSeg.cubeIds,2) == 1
                llArray(remlSegIdx) = [];
            else
                % Otherwise, remove the tgtCube from its cube list
                llArray(remlSegIdx).deleteCubeID(tgtCube.identity);
            end

            % Construct new line segments and assign to the array
            

            lsOne = lineSegment(twoCube(1).widthLineSegment(1), twoCube(1).widthLineSegment(2));
            lsOne.addCube(twoCube(1).identity);
            llArray = addLineSegToArray(llArray, lsOne);

            lsTwo = lineSegment(twoCube(2).widthLineSegment(1), twoCube(2).widthLineSegment(2));
            lsTwo.addCube(twoCube(2).identity);
            llArray = addLineSegToArray(llArray, lsTwo);


            tgtLSH1 = findLineSegIDX(hlArray, twoCube(1).heightLineSegment(1), twoCube(1).heightLineSegment(2));
            hlArray(tgtLSH1).addCube(twoCube(1).identity);

            tgtLSD1 = findLineSegIDX(dlArray, twoCube(1).depthLineSegment(1), twoCube(1).depthLineSegment(2));
            dlArray(tgtLSD1).addCube(twoCube(1).identity);

            tgtLSH2 = findLineSegIDX(hlArray, twoCube(2).heightLineSegment(1), twoCube(2).heightLineSegment(2));
            hlArray(tgtLSH2).addCube(twoCube(2).identity);

            tgtLSD2 = findLineSegIDX(dlArray, twoCube(2).depthLineSegment(1), twoCube(2).depthLineSegment(2));
            dlArray(tgtLSD2).addCube(twoCube(2).identity);
        elseif dimID ==2
            % Find the index of the impacted line segment
            remlSegIdx = findLineSegIDX(hlArray, tgtCube.heightLineSegment(1), tgtCube.heightLineSegment(2));
            remlSeg = hlArray(remlSegIdx);

            % Remove it from the hlArray if this is the only line segment
            if size(remlSeg.cubeIds,2) == 1
                hlArray(remlSegIdx) = [];
            else
                % Otherwise, remove the tgtCube from its cube list
                hlArray(remlSegIdx).deleteCubeID(tgtCube.identity);
            end

            % Construct new line segments and assign to the array
            lsOne = lineSegment(twoCube(1).heightLineSegment(1), twoCube(1).heightLineSegment(2));
            lsOne.addCube(twoCube(1).identity);
            hlArray = addLineSegToArray(hlArray, lsOne);


            lsTwo = lineSegment(twoCube(2).heightLineSegment(1), twoCube(2).heightLineSegment(2));
            lsTwo.addCube(twoCube(2).identity);
            hlArray = addLineSegToArray(hlArray, lsTwo);


            % Add the new cube to their corresponding width and height line
            % segments
            tgtLSW1 = findLineSegIDX(llArray, twoCube(1).widthLineSegment(1), twoCube(1).widthLineSegment(2));
            llArray(tgtLSW1).addCube(twoCube(1).identity);

            tgtLSD1 = findLineSegIDX(dlArray, twoCube(1).depthLineSegment(1), twoCube(1).depthLineSegment(2));
            dlArray(tgtLSD1).addCube(twoCube(1).identity);

            tgtLSW2 = findLineSegIDX(llArray, twoCube(2).widthLineSegment(1), twoCube(2).widthLineSegment(2));
            llArray(tgtLSW2).addCube(twoCube(2).identity);

            tgtLSD2 = findLineSegIDX(dlArray, twoCube(2).depthLineSegment(1), twoCube(2).depthLineSegment(2));
            dlArray(tgtLSD2).addCube(twoCube(2).identity);

            
        else
            % Find the index of the impacted line segment
            remlSegIdx = findLineSegIDX(dlArray, tgtCube.depthLineSegment(1), tgtCube.depthLineSegment(2));
            remlSeg = dlArray(remlSegIdx);

            % Remove it from the dlArray
            if size(remlSeg.cubeIds,2) == 1
                dlArray(remlSegIdx) = [];
            else
                % Otherwise, remove the tgtCube from its cube list
                dlArray(remlSegIdx).deleteCubeID(tgtCube.identity);
            end

            % Construct new line segments and assign to the array
            lsOne = lineSegment(twoCube(1).depthLineSegment(1), twoCube(1).depthLineSegment(2));
            lsOne.addCube(twoCube(1).identity);
            dlArray = addLineSegToArray(dlArray, lsOne);

            lsTwo = lineSegment(twoCube(2).depthLineSegment(1), twoCube(2).depthLineSegment(2));
            lsTwo.addCube(twoCube(2).identity);
            dlArray = addLineSegToArray(dlArray, lsTwo);

            % Add the new cube to their corresponding width and height line
            % segments
            tgtLSW1 = findLineSegIDX(llArray, twoCube(1).widthLineSegment(1), twoCube(1).widthLineSegment(2));
            llArray(tgtLSW1).addCube(twoCube(1).identity);

            tgtLSH1 = findLineSegIDX(hlArray, twoCube(1).heightLineSegment(1), twoCube(1).heightLineSegment(2));
            hlArray(tgtLSH1).addCube(twoCube(1).identity);

            tgtLSW2 = findLineSegIDX(llArray, twoCube(2).widthLineSegment(1), twoCube(2).widthLineSegment(2));
            llArray(tgtLSW2).addCube(twoCube(2).identity);

            tgtLSH2 = findLineSegIDX(hlArray, twoCube(2).heightLineSegment(1), twoCube(2).heightLineSegment(2));
            hlArray(tgtLSH2).addCube(twoCube(2).identity);
        end
    else
        %tgtCube.assignedVertices = i;
        tgtCube.assignVertex(i, currV(1), currV(2), currV(3), currV(4), currV(5), currV(6), currV(7));
    end
    % Otherwise, insert the vertex into the cube.
end

% Set the neighbor relationship
for p=1:size(cubes,2)-1
    for q=p+1:size(cubes,2)
        cubep = cubes(p);
        cubeq = cubes(q);
        
        if cubep.isDisabled() || cubeq.isDisabled()
            continue;
        end

        output = areTwoCubesNeighbors(cubep, cubeq);
        if output == 1
            cubes(p).assignNeighbor(q);
            cubes(q).assignNeighbor(p);
        end
    end
end

if ~silent
    reportCubeStats(cubes, cubeCapacity);
end
end
