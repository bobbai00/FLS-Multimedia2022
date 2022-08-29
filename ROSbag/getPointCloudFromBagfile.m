function [ply] = getPointCloudFromBagfile(path, sid, pid)

bag = rosbag(path).select('Topic', sid);
msgs = bag.readMessages;
ply = [];

for i=1:length(msgs)
    pt = [];
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
            pt = [pt [
                        lastCoord.X
                        lastCoord.Y
                        lastCoord.Z
                        lastColor.R
                        lastColor.G
                        lastColor.B
                        lastColor.A
                      ]
                   ];
            break;
        end
    end
    ply = [ply pt];
end

end

