function r = setNeighborForRCubes(cubes)

    for p = 1:size(cubes, 2) - 1
        for q = p+1:size(cubes, 2)
            cubep = cubes(p);
            cubeq = cubes(q);

            output = areTwoCubesNeighbors(cubep, cubeq);
            if output == 1
                cubes(p).assignNeighbor(cubes(q));
                cubes(q).assignNeighbor(cubes(p));
            end
        end
    end

    r = cubes;
end