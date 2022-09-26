function newCube = mergeCubes(cubes, cubeIds, vertexList)
    
    vertices = [];
    for i = 1:size(cubeIds, 2)
        cid = cubeIds(i);
        cube = cubes(cid);
        if cube.isDisabled()
            error("cube shouldn't be disabled");
        end
        
        vertices = [vertices, cube.assignedVertices];
        cubes(cid).disable();
    end

    vertices = unique(vertices(:).');
    newCubeId = size(cubes, 2) + 1;
    newCube = oneCube(newCubeId, size(vertices, 2));

    for i = 1:size(vertices, 2)
        vid = vertices(i);
        V = vertexList(vertices(i));
        currV = V{1};
        newCube.assignVertex(vid, currV(1), currV(2), currV(3), currV(4), currV(5), currV(6), currV(7));
    end
end

