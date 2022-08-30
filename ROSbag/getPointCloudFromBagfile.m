function [xyz, rgba] = getPointCloudFromBagfile(path, sid, pid)

bag = rosbag(path).select('Topic', sid);
msgs = bag.readMessages;
xyz = [];
rgba = [];

for i=1:length(msgs)
    if ~mod(i, 1000)
        disp(i);
    end

    coord = [];
    color = [];
    lastCoord = 0;
    lastColor = 0;

    wip = msgs{i}.Whatispresent;
    coords = msgs{i}.Coordinate;
    colors = msgs{i}.Color;
    durs = msgs{i}.Duration;

    for j=1:length(durs)
        if char(wip(j)) == 'B'
            lastCoord = coords(j);
            lastColor = colors(j);
        elseif char(wip(j)) == 'C'
            lastColor = colors(j);
        else
            lastCoord = coords(j);
        end

        if durs(j).Start <= pid && pid < durs(j).End
            coord = [
                    lastCoord.X
                    lastCoord.Y
                    lastCoord.Z
                ];
            color = [
                    lastColor.R
                    lastColor.G
                    lastColor.B
                    lastColor.A
                 ];
            break;
        end
    end
    xyz(i,:) = coord;
    rgba(i,:) = color;
end
fileID = fopen('exp.ply','w');
fprintf(fileID, 'ply\nformat ascii 1.0\nelement vertex %d\nproperty float x\nproperty float y\nproperty float z\nproperty uchar red\nproperty uchar green\nproperty uchar blue\nproperty uchar alpha\nelement face 0\nproperty list uchar int vertex_indices\nend_header\n', length(msgs));
for i=1:length(xyz)
    fprintf(fileID,'%f %f %f %d %d %d %d\n', xyz(i,1), xyz(i,2), xyz(i,3), rgba(i,1), rgba(i,2), rgba(i,3), rgba(i,4));
end
fclose(fileID);
end

