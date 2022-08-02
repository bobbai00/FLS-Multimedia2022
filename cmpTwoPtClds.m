function output = cmpTwoPtClds(PtCld1, PtCld2, silent)
% Construct a hash table on PtCld1.
% Probe with entries of PtCld2 and delete the found entry.
% Identify probed entries that do not match. 
% Identify entries that remain in the hash table as having no match.
hashMapOnLeadFrame = containers.Map('KeyType','char', 'ValueType','any');
chaosf = 0.001;

for i=1:size( PtCld1.vertexList, 2 )
    a1 = PtCld1.vertexList(i);
    b1 = a1{1};
    hval=utilHashFunction(b1);
    hashMapOnLeadFrame(hval)=PtCld1.vertexList(i);
end

colorChangedPoints = 0;
leadColor=[];
derColor=[];

numMissingPts=0;
missingPts=[];

for i=1:size( PtCld2.vertexList, 2 )
    deriveda1 = PtCld2.vertexList(i);
    derivedb1 = deriveda1{1};

    % probeKey = (multiplier1 * round(derivedb1(1),6) ) + (multiplier2 * round(derivedb1(2),6) ) + (multiplier3 * round(derivedb1(3),6) ) ;
    probeKey = utilHashFunction(derivedb1);

    if hashMapOnLeadFrame.isKey(probeKey)
        lV = hashMapOnLeadFrame(probeKey);
        leada1 = lV;
        leadb1 = leada1{1};
        leadWidth = leadb1(1);
        leadHeight = leadb1(2);
        leadDepth = leadb1(3);

        %%%if leadWidth == derivedb1(1) && leadHeight == derivedb1(2) && leadDepth == derivedb1(3)
        if abs(leadWidth-derivedb1(1))<chaosf && abs(leadHeight-derivedb1(2))<chaosf && abs(leadDepth-derivedb1(3)) <chaosf
            % Point did not move
            % Check if color changed
            leadRed = leadb1(4);
            leadGreen = leadb1(5);
            leadBlue = leadb1(6);
            leadAlpha = leadb1(7);
            if leadRed == derivedb1(4) && leadGreen == derivedb1(5) && leadBlue == derivedb1(6) && leadAlpha == derivedb1(7)
            else
                colorChangedPoints = colorChangedPoints + 1;
                leadColor(colorChangedPoints)=lV;
                derColor(colorChangedPoints)=destCloudPoint.cubes(tgtCubeID).assignedVertices(i);
            end
            remove(hashMapOnLeadFrame, probeKey); % Delete hashmap entry to find newly inserted points.
        end
    else
        numMissingPts=numMissingPts+1;
        missingPts(numMissingPts)=destCloudPoint.cubes(tgtCubeID).assignedVertices(i);
    end
end
if size( hashMapOnLeadFrame.values() , 2) > 0 || numMissingPts > 0
    outputT= ['Different point clouds.  Point cloud 2 has ', num2str(numMissingPts), ' different points.  Point cloud 1 has ', num2str(size( hashMapOnLeadFrame.values() , 2)), ' different points.' ];
    disp(outputT);
    %modPts=cell2mat( hashMapOnLeadFrame.values() );
else
    outputT= ['Identical point clouds.'];
    disp(outputT);
end
end
